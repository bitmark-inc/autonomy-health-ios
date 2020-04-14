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
    lazy var searchBar = makeSearchBar()
    lazy var searchTextField = makeSearchTextField()
    lazy var closeButton = makeCloseButton()
    lazy var resultTableView = makeResultTableView()

    var bottomConstraint: Constraint?
    lazy var thisViewModel: LocationSearchViewModel = {
        return viewModel as! LocationSearchViewModel
    }()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    var autoCompleteLocations = [GMSAutocompletePrediction]()

    // MARK: - Life Cycle
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

        thisViewModel.locationsResultRelay
            .subscribe(onNext: { [weak self] in
                self?.autoCompleteLocations = $0
                self?.resultTableView.reloadData()
            })
            .disposed(by: disposeBag)
    }

    override func setupViews() {
        super.setupViews()

        let paddingContentView = UIView()
        paddingContentView.addSubview(searchBar)
        paddingContentView.addSubview(resultTableView)

        searchBar.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
        }

        resultTableView.snp.makeConstraints { (make) in
            make.top.equalTo(searchBar.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
            bottomConstraint = make.bottom.equalToSuperview().constraint
        }

        closeButton.rx.tap.bind { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }.disposed(by: disposeBag)

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
        let cell = tableView.dequeueReusableCell(withClass: SearchTextTableCell.self)

        let searchText = thisViewModel.searchLocationTextRelay.value
        let locationText = autoCompleteLocations[indexPath.row].attributedFullText.string

        let regex = try! NSRegularExpression(pattern: "(?i)(\(searchText))")
        let styleAttributedText = regex.stringByReplacingMatches(in: locationText, range: NSRange(0..<locationText.utf16.count), withTemplate: "<b>$1</b>")

        cell.setData(attributedText: styleAttributedText)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let placeID = autoCompleteLocations[indexPath.row].placeID
        thisViewModel.selectedPlaceIDSubject.onNext(placeID)

        dismiss(animated: true, completion: nil)
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
        let separateLine = SeparateLine(height: 1)
        separateLine.backgroundColor = UIColor(hexString: "#828180")

        let view = UIView()
        view.addSubview(searchTextField)
        view.addSubview(closeButton)
        view.addSubview(separateLine)

        searchTextField.snp.makeConstraints { (make) in
            make.leading.centerY.equalToSuperview()
            make.width.equalToSuperview().offset(-100)
        }

        closeButton.snp.makeConstraints { (make) in
            make.leading.equalTo(searchTextField.snp.trailing).offset(5)
            make.top.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(43)
        }

        separateLine.snp.makeConstraints { (make) in
            make.top.equalTo(closeButton.snp.bottom).offset(15)
            make.leading.trailing.bottom.equalToSuperview()
        }

        return view
    }

    fileprivate func makeSearchTextField() -> UITextField {
        let textField = UITextField()
        textField.font = R.font.atlasGroteskLight(size: 24)
        textField.placeholder = R.string.localizable.addNewLocation()
        textField.returnKeyType = .done

        themeService.rx
            .bind({ $0.lightTextColor  }, to: textField.rx.textColor)
            .bind({ $0.silverTextColor }, to: textField.rx.placeholderColor)
            .disposed(by: disposeBag)

        return textField
    }

    fileprivate func makeCloseButton() -> UIButton {
        let button = UIButton()
        button.setImage(R.image.concordPlusCircle(), for: .normal)
        button.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 4)
        return button
    }

    fileprivate func makeResultTableView() -> TableView {
        let tableView = TableView()
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(cellWithClass: SearchTextTableCell.self)
        return tableView
    }
}
