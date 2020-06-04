//
//  SearchSurveyLayout.swift
//  Autonomy
//
//  Created by Thuyen Truong on 5/13/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import SwiftRichString

class SearchSurveyViewController: ViewController {

    // MARK: - Properties
    lazy var searchBar = makeSearchBar()
    lazy var searchTextField = makeSearchTextField()
    lazy var closeButton = makeCloseButton()
    lazy var resultTableView = makeResultTableView()

    var bottomConstraint: Constraint?

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

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

    // MARK: - Error Handlers
    func errorWhenSubmit(error: Error) {
        guard !handleIfGeneralError(error: error) else { return }
        Global.log.error(error)
        showErrorAlertWithSupport(message: R.string.error.system())
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
            make.top.equalTo(searchBar.snp.bottom).offset(15)
            make.leading.trailing.equalToSuperview()
            bottomConstraint = make.bottom.equalToSuperview().constraint
        }

        closeButton.rx.tap.bind { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }.disposed(by: disposeBag)

        contentView.addSubview(paddingContentView)
        paddingContentView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
}

// MARK: - KeyboardObserver
extension SearchSurveyViewController {
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
extension SearchSurveyViewController {
    fileprivate func makeSearchBar() -> UIView {
        let view = UIView()
        view.addSubview(closeButton)
        view.addSubview(searchTextField)

        themeService.rx
            .bind({ $0.mineShaftBackground }, to: view.rx.backgroundColor)
            .disposed(by: disposeBag)

        closeButton.snp.makeConstraints { (make) in
            make.leading.top.bottom.equalToSuperview()
                .inset(UIEdgeInsets(top: 8, left: 8, bottom: 7, right: 0))
            make.height.width.equalTo(30)
        }

        searchTextField.snp.makeConstraints { (make) in
            make.leading.equalTo(closeButton.snp.trailing).offset(8)
            make.trailing.equalToSuperview().offset(-30)
            make.centerY.equalToSuperview()
        }

        return view
    }

    fileprivate func makeSearchTextField() -> UITextField {
        let textField = UITextField()
        textField.font = R.font.atlasGroteskLight(size: 18)
        textField.returnKeyType = .done

        themeService.rx
            .bind({ $0.lightTextColor  }, to: textField.rx.textColor)
            .bind({ $0.lightTextColor  }, to: textField.rx.tintColor)
            .disposed(by: disposeBag)

        return textField
    }

    fileprivate func makeCloseButton() -> UIButton {
        let button = UIButton()
        button.setImage(R.image.plusCircle(), for: .normal)
        button.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 4)
        return button
    }

    fileprivate func makeResultTableView() -> TableView {
        let tableView = TableView()
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)

        tableView.register(cellWithClass: SearchSurveyTableCell.self)
        return tableView
    }

    func makeAttributedText(_ searchText: String, in text: String) -> String {
        let regex = try! NSRegularExpression(pattern: "(?i)(\(searchText))")
        return regex.stringByReplacingMatches(in: text, range: NSRange(0..<text.utf16.count), withTemplate: "<b>$1</b>")
    }
}

