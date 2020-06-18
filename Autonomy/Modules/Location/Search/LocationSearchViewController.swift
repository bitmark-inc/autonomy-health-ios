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
    fileprivate lazy var searchBar = makeSearchBar()
    fileprivate lazy var searchTextField = makeSearchTextField()
    fileprivate lazy var resultTableView = makeResultTableView()
    fileprivate lazy var resourceTagsView = TagListView()
    fileprivate lazy var resourceView = makeResourceView()

    fileprivate var bottomConstraint: Constraint?
    fileprivate lazy var thisViewModel: LocationSearchViewModel = {
        return viewModel as! LocationSearchViewModel
    }()

    fileprivate var scores = [Float?]()
    fileprivate var autoCompleteLocations = [GMSAutocompletePrediction]()

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

        _ = searchTextField.rx.textInput => thisViewModel.searchLocationTextRelay

        BehaviorRelay.combineLatest(thisViewModel.locationsResultRelay, thisViewModel.resourcesResultRelay)
            .map { (locations, resources) in
                return locations.isNotEmpty || resources.isEmpty
            }
            .bind(to: resourceView.rx.isHidden)
            .disposed(by: disposeBag)

        thisViewModel.resourcesResultRelay
            .subscribe(onNext: { [weak self] in
                self?.rebuildResourcesListView(resources: $0)
            })
            .disposed(by: disposeBag)

        thisViewModel.locationsResultRelay
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.autoCompleteLocations = $0
                self.resultTableView.reloadData()
            })
            .disposed(by: disposeBag)
    }

    override func setupViews() {
        super.setupViews()

        themeService.rx
            .bind({ $0.mineShaftBackground }, to: contentView.rx.backgroundColor)
            .disposed(by: disposeBag)

        let paddingContentView = UIView()
        paddingContentView.addSubview(searchBar)
        paddingContentView.addSubview(resultTableView)
        paddingContentView.addSubview(resourceView)

        searchBar.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
        }

        resultTableView.snp.makeConstraints { (make) in
            make.top.equalTo(searchBar.snp.bottom).offset(6)
            make.leading.trailing.equalToSuperview()
            bottomConstraint = make.bottom.equalToSuperview().constraint
        }

        resourceView.snp.makeConstraints { (make) in
            make.top.equalTo(searchBar.snp.bottom).offset(29)
            make.leading.trailing.equalToSuperview()
        }

        contentView.addSubview(paddingContentView)
        paddingContentView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(OurTheme.paddingOverBottomInset)
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension LocationSearchViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return autoCompleteLocations.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: LocationSearchTableCell.self)
        cell.separatorInset = .zero

        let autoCompleteLocation = autoCompleteLocations[indexPath.row]

        let searchText = thisViewModel.searchLocationTextRelay.value
        let placeText = autoCompleteLocation.attributedPrimaryText.string
        let secondaryText = autoCompleteLocation.attributedSecondaryText?.string ?? autoCompleteLocation.attributedFullText.string

        cell.setData(
            placeAttributedText: makeAttributedText(searchText, in: placeText),
            secondaryAttributedText: makeAttributedText(searchText, in: secondaryText))

        return cell
    }

    fileprivate func makeAttributedText(_ searchText: String, in text: String) -> String {
        let regex = try! NSRegularExpression(pattern: "(?i)(\(searchText))")
        return regex.stringByReplacingMatches(in: text, range: NSRange(0..<text.utf16.count), withTemplate: "<b>$1</b>")
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let placeID = autoCompleteLocations[indexPath.row].placeID
        tableView.isUserInteractionEnabled = false
        thisViewModel.selectedPlaceIDSubject.onNext(placeID)
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
        dismiss(animated: true, completion: nil)
        return true
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
    fileprivate func makeSearchBar() -> UIView {
        let closeButton = makeCloseButton()
        let searchImageView = ImageView(image: R.image.search())
        let separateLine = SeparateLine(height: 1)

        let searchBar = UIView()
        searchBar.addSubview(searchImageView)
        searchBar.addSubview(searchTextField)
        searchBar.addSubview(closeButton)

        searchImageView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview().offset(-2)
        }

        searchTextField.snp.makeConstraints { (make) in
            make.leading.equalTo(searchImageView.snp.trailing).offset(17)
            make.top.bottom.equalToSuperview()
            make.width.equalToSuperview().offset(-90)
        }

        closeButton.snp.makeConstraints { (make) in
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

    fileprivate func makeCloseButton() -> UIButton {
        let button = UIButton()
        button.setImage(R.image.closeIcon(), for: .normal)

        button.rx.tap.bind { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }.disposed(by: disposeBag)

        return button
    }

    fileprivate func makeResultTableView() -> TableView {
        let tableView = TableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .singleLine
        tableView.register(cellWithClass: LocationSearchTableCell.self)

        themeService.rx
            .bind({ $0.separateTextColor }, to: tableView.rx.separatorColor)
            .disposed(by: disposeBag)

        return tableView
    }

    fileprivate func makeResourceView() -> UIView {
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
        tapGestureRecognizer.rx.event.bind { (event) in
            guard let selectedTagView = event.view as? TagView else { return }
            print(selectedTagView)

        }.disposed(by: disposeBag)
        return tapGestureRecognizer
    }
}
