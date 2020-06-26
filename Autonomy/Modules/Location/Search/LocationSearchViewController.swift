//
//  LocationSearchViewController.swift
//  Autonomy
//
//  Created by Thuyen Truong on 4/10/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import SkeletonView
import SwiftRichString
import GooglePlaces

class LocationSearchViewController: ViewController {

    // MARK: - Properties
    fileprivate lazy var scrollView = makeScrollView()
    fileprivate lazy var searchBar = makeSearchBar()
    fileprivate lazy var searchTextField = makeSearchTextField()
    fileprivate lazy var clearButton = makeClearButton()
    fileprivate lazy var resultTableView = makeResultTableView()
    fileprivate lazy var resourceTagsView = TagListView()
    fileprivate lazy var resourcesView = makeResourcesView()
    fileprivate lazy var noPlacesMessageLabel = makeNoPlacesMessageLabel()

    fileprivate var bottomConstraint: Constraint?
    fileprivate lazy var thisViewModel: LocationSearchViewModel = {
        return viewModel as! LocationSearchViewModel
    }()

    fileprivate var scores = [Float?]()
    fileprivate var autoCompleteLocations: [GMSAutocompletePrediction]?
    fileprivate var autoCompletePlaces: [PointOfInterest]?

    fileprivate var textInputEnableRelay = BehaviorRelay<Bool>(value: true)

    // MARK: - Life Cycle
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        resourceTagsView.rearrangeViews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Register Keyboard Notification
        addNotificationObserver(name: UIWindow.keyboardWillShowNotification, selector: #selector(keyboardWillBeShow))
        addNotificationObserver(name: UIWindow.keyboardWillHideNotification, selector: #selector(keyboardWillBeHide))
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        searchTextField.becomeFirstResponder()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        searchTextField.endEditing(true)
        removeNotificationsObserver()
    }

    override func bindViewModel() {
        super.bindViewModel()

        thisViewModel.selectedPlaceIDSubject
            .subscribe(onNext: { [weak self] (placeID) in
                self?.gotoPlaceAutonomyProfileScreen(poiID: placeID)
            })
            .disposed(by: disposeBag)

        searchTextField.rx.controlEvent(.editingChanged)
            .subscribe(onNext: { [weak self] (_) in
                guard let self = self else { return }
                let changedText = self.searchTextField.text
                self.clearButton.isHidden = changedText?.isEmpty ?? true
                self.noPlacesMessageLabel.isHidden = true
                self.thisViewModel.searchLocationTextRelay.accept(changedText ?? "")
            })
            .disposed(by: disposeBag)

        BehaviorRelay.combineLatest(
            thisViewModel.locationsResultRelay,
            thisViewModel.placesResultRelay,
            thisViewModel.resourcesResultRelay
        )
            .map { (locations, places, resources) in
                return locations != nil || places != nil || resources.isEmpty
            }
            .bind(to: resourcesView.rx.isHidden)
            .disposed(by: disposeBag)

        thisViewModel.resourcesResultRelay
            .subscribe(onNext: { [weak self] in
                self?.rebuildResourcesListView(resources: $0)
            })
            .disposed(by: disposeBag)

        thisViewModel.locationsResultRelay
            .filterNil()
            .subscribe(onNext: { [weak self] (locations) in
                guard let self = self else { return }
                self.autoCompletePlaces = nil
                self.autoCompleteLocations = locations
                self.resultTableView.reloadData()
            })
            .disposed(by: disposeBag)

        thisViewModel.placesResultRelay
            .filterNil()
            .subscribe(onNext: { [weak self] (places) in
                guard let self = self else { return }
                self.autoCompleteLocations = nil
                self.autoCompletePlaces = places
                self.resultTableView.reloadData()
                self.noPlacesMessageLabel.isHidden = places.isNotEmpty
            })
            .disposed(by: disposeBag)
    }

    override func setupViews() {
        super.setupViews()

        themeService.rx
            .bind({ $0.mineShaftBackground }, to: contentView.rx.backgroundColor)
            .disposed(by: disposeBag)

        scrollView.addSubview(resourcesView)
        resourcesView.snp.makeConstraints { (make) in
            make.edges.width.equalToSuperview()
        }

        let paddingContentView = UIView()
        paddingContentView.addSubview(searchBar)
        paddingContentView.addSubview(noPlacesMessageLabel)
        paddingContentView.addSubview(scrollView)
        paddingContentView.addSubview(resultTableView)

        searchBar.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.leading.trailing.equalToSuperview()
        }

        noPlacesMessageLabel.snp.makeConstraints { (make) in
            make.top.equalTo(searchBar.snp.bottom).offset(30)
            make.leading.trailing.equalToSuperview()
        }

        scrollView.snp.makeConstraints { (make) in
            make.top.equalTo(searchBar.snp.bottom).offset(29)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(resultTableView)
        }

        resultTableView.snp.makeConstraints { (make) in
            make.top.equalTo(searchBar.snp.bottom).offset(6)
            make.leading.trailing.equalToSuperview()
            bottomConstraint = make.bottom.equalToSuperview().constraint
        }

        contentView.addSubview(paddingContentView)
        paddingContentView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(OurTheme.paddingOverBottomInset)
        }

        view.addGestureRecognizer(makeSwipeGesture())
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension LocationSearchViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfRecords = (autoCompleteLocations?.count ?? autoCompletePlaces?.count) ?? 0
        tableView.isHidden = numberOfRecords <= 0
        return numberOfRecords
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: LocationSearchTableCell.self)
        cell.separatorInset = .zero
        cell.selectionStyle = .none

        if let autoCompleteLocations = autoCompleteLocations {
            let autoCompleteLocation = autoCompleteLocations[indexPath.row]

            let searchText = thisViewModel.searchLocationTextRelay.value
            let placeText = autoCompleteLocation.attributedPrimaryText.string
            let secondaryText = autoCompleteLocation.attributedSecondaryText?.string ?? autoCompleteLocation.attributedFullText.string

            cell.setData(
                placeAttributedText: makeAttributedText(searchText, in: placeText),
                secondaryAttributedText: makeAttributedText(searchText, in: secondaryText))

            return cell

        } else if let autoCompletePlaces = autoCompletePlaces {
            let place = autoCompletePlaces[indexPath.row]
            cell.setData(place: place)
            return cell
        }

        return cell
    }

    fileprivate func makeAttributedText(_ searchText: String, in text: String) -> String {
        let regex = try! NSRegularExpression(pattern: "(?i)(\(searchText))")
        return regex.stringByReplacingMatches(in: text, range: NSRange(0..<text.utf16.count), withTemplate: "<b>$1</b>")
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let autoCompleteLocations = autoCompleteLocations {
            let googlePlaceID = autoCompleteLocations[indexPath.row].placeID
            thisViewModel.addNewPlace(googlePlaceID: googlePlaceID)

        } else if let autoCompletePlaces = autoCompletePlaces {
            let placeID = autoCompletePlaces[indexPath.row].id
            thisViewModel.selectedPlaceIDSubject.onNext(placeID)
        }
    }

    fileprivate func rebuildResourcesListView(resources: [Resource]) {
        resourceTagsView.reset()

        for resource in resources {
            let tagView = resourceTagsView.addTag((resource.id, resource.name.lowercased()))
            tagView.backgroundColor = .black
            tagView.addGestureRecognizer(makeTapGestureRecognizer())
        }
        resourceTagsView.rearrangeViews()
    }
}

// MARK: - UITextFieldDelegate
extension LocationSearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dismiss()
        return true
    }
}

// MARK: - LocationSearchViewController
extension LocationSearchViewController {
    fileprivate func gotoPlaceAutonomyProfileScreen(poiID: String) {
        let viewModel = PlaceHealthDetailsViewModel(poiID: poiID)
        viewModel.backAnimationType = .slide(direction: .right)
        navigator.show(segue: .placeHealthDetails(viewModel: viewModel), sender: self)
    }

    fileprivate func dismiss() {
        navigator.pop(sender: self, animated: true, animationType: .pageOut(direction: .down))
    }
}

// MARK: - KeyboardObserver
extension LocationSearchViewController {
    @objc func keyboardWillBeShow(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }

        bottomConstraint?.update(offset: -keyboardSize.height)
        view.layoutIfNeeded()
    }

    @objc func keyboardWillBeHide(notification: Notification) {
        bottomConstraint?.update(offset: 0)
        view.layoutIfNeeded()
    }
}

// MARK: - Setup views
extension LocationSearchViewController {
    fileprivate func makeScrollView() -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.isUserInteractionEnabled = true
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 15, right: 0)
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }

    fileprivate func makeSearchBar() -> UIView {
        let searchImageView = ImageView(image: R.image.search())
        let separateLine = SeparateLine(height: 1)

        let searchBar = UIView()
        searchBar.addSubview(searchImageView)
        searchBar.addSubview(searchTextField)
        searchBar.addSubview(clearButton)

        searchImageView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview().offset(-2)
        }

        searchTextField.snp.makeConstraints { (make) in
            make.leading.equalTo(searchImageView.snp.trailing).offset(17)
            make.top.bottom.equalToSuperview()
            make.width.equalToSuperview().offset(-90)
        }

        clearButton.snp.makeConstraints { (make) in
            make.leading.lessThanOrEqualTo(searchTextField.snp.trailing).offset(15)
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview().offset(-2)
        }

        let view = UIView()
        view.addSubview(searchBar)
        view.addSubview(separateLine)

        searchBar.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
        }

        separateLine.snp.makeConstraints { (make) in
            make.top.equalTo(searchBar.snp.bottom).offset(15)
            make.leading.trailing.bottom.equalToSuperview()
        }

        return view
    }

    fileprivate func makeSearchTextField() -> UITextField {
        let textField = UITextField()
        textField.font = R.font.atlasGroteskLight(size: 18)
        textField.placeholder = R.string.phrase.locationPlaceholder()
        textField.returnKeyType = .done
        textField.delegate = self

        themeService.rx
            .bind({ $0.lightTextColor  }, to: textField.rx.textColor)
            .bind({ $0.concordColor }, to: textField.rx.placeholderColor)
            .disposed(by: disposeBag)

        return textField
    }

    fileprivate func makeClearButton() -> UIButton {
        let button = UIButton()
        button.isHidden = true
        button.setImage(R.image.closeIcon(), for: .normal)

        button.rx.tap.bind { [weak self] in
            guard let self = self else { return }
            self.searchTextField.text = nil
            self.searchTextField.becomeFirstResponder()
            self.thisViewModel.placesResultRelay.accept(nil)
            self.thisViewModel.locationsResultRelay.accept(nil)
            self.autoCompleteLocations = nil
            self.autoCompletePlaces = nil
            self.resultTableView.reloadData()
            self.noPlacesMessageLabel.isHidden = true
            button.isHidden = true

        }.disposed(by: disposeBag)

        return button
    }

    fileprivate func makeResultTableView() -> TableView {
        let tableView = TableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .singleLine
        tableView.register(cellWithClass: LocationSearchTableCell.self)
        tableView.isHidden = true

        themeService.rx
            .bind({ $0.separateTextColor }, to: tableView.rx.separatorColor)
            .disposed(by: disposeBag)

        return tableView
    }

    fileprivate func makeResourcesView() -> UIView {
        let headerLabel = Label()
        headerLabel.numberOfLines = 0
        headerLabel.apply(text: R.string.phrase.locationSearchResource().localizedUppercase,
                          font: R.font.domaineSansTextLight(size: 14),
                          themeStyle: .silverColor)

        return LinearView(
            items: [(headerLabel, 0), (resourceTagsView, 34)],
            bottomConstraint: true)
    }

    fileprivate func makeTapGestureRecognizer() -> UITapGestureRecognizer {
        let tapGestureRecognizer = UITapGestureRecognizer()
        tapGestureRecognizer.rx.event.bind { [weak self] (event) in
            guard let self = self,
                let selectedTagView = event.view as? TagView else { return }

            self.searchTextField.text = selectedTagView.title
            self.searchTextField.resignFirstResponder()
            self.clearButton.isHidden = false
            self.thisViewModel.fetchPlacesBy(resourceID: selectedTagView.id)
        }.disposed(by: disposeBag)
        return tapGestureRecognizer
    }

    fileprivate func makeSwipeGesture() -> UISwipeGestureRecognizer {
        let swipeGesture = UISwipeGestureRecognizer()
        swipeGesture.direction = .down
        swipeGesture.rx.event.bind { [weak self] (gesture) in
            guard let self = self else { return }
            self.dismiss()
        }.disposed(by: disposeBag)
        return swipeGesture
    }

    fileprivate func makeNoPlacesMessageLabel() -> Label {
        let label = Label()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.isHidden = true
        label.apply(text: R.string.phrase.locationSearchNoPlacesMessage(),
                    font: R.font.atlasGroteskLight(size: 18),
                    themeStyle: .silverColor, lineHeight: 1.25)
        return label
    }
}
