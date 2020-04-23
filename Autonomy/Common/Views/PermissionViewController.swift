//
//  PermissionViewController.swift
//  Autonomy
//
//  Created by Thuyen Truong on 3/26/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import SwifterSwift
import CoreLocation

class PermissionViewController: ViewController, BackNavigator {

    // MARK: - Properties
    lazy var headerScreen: UIView = {
        HeaderView(header: R.string.localizable.permission().localizedUppercase)
    }()
    lazy var titleScreen = makeTitleScreen()
    lazy var scrollView = makeScrollView()
    lazy var notificationOptionBox = makeNotificationOptionBox()
    lazy var locationOptionBox = makeLocationOptionBox()
    lazy var backButton = makeLightBackItem()
    lazy var nextButton = SubmitButton(title: R.string.localizable.next().localizedUppercase,
                     icon: R.image.nextCircleArrow()!)
    lazy var groupsButton: UIView = {
        ButtonGroupView(button1: backButton, button2: nextButton, hasGradient: true)
    }()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - bindViewModel
    override func bindViewModel() {
        super.bindViewModel()

        notificationOptionBox.button.rx.tap.bind { [weak self] in
            guard let self = self else { return }
            NotificationPermission.askForNotificationPermission(handleWhenDenied: true)
                .subscribe()
                .disposed(by: self.disposeBag)
        }.disposed(by: disposeBag)

        NotificationCenter.default.addObserver(self, selector: #selector(reloadState), name: UIApplication.didBecomeActiveNotification, object: nil)

        locationOptionBox.button.rx.tap.bind {
            if LocationPermission.isEnabled() == false {
                LocationPermission.askEnableLocationAlert()
            } else {
                Global.current.locationManager.requestWhenInUseAuthorization()
            }
        }.disposed(by: disposeBag)

        nextButton.rxTap.bind { [weak self] in
            self?.gotoRiskLevelScreen()
        }.disposed(by: disposeBag)
    }

    /// Reload state
    // - disable button when notification is enabled
    // - disable button when location is enabled
    @objc func reloadState() {
        NotificationPermission.isEnabled()
            .map { $0 == true }
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] (isEnabled) in
                self?.notificationOptionBox.button.isEnabled = !isEnabled
            })
            .disposed(by: disposeBag)

        let isLocationEnabled = LocationPermission.isEnabled() == true
        locationOptionBox.button.isEnabled = !isLocationEnabled
        nextButton.isEnabled = isLocationEnabled
    }

    // MARK: - Setup views
    override func setupViews() {
        super.setupViews()

        // *** Setup subviews ***
        let paddingContentView = LinearView(
            items: [
                (headerScreen, 0),
                (titleScreen, 0),
                (SeparateLine(height: 1), 3),
                (notificationOptionBox, Size.dh(29)),
                (SeparateLine(height: 1), 15),
                (locationOptionBox, Size.dh(29)),
                (SeparateLine(height: 1), 15)
            ], bottomConstraint: true)

        scrollView.addSubview(paddingContentView)
        paddingContentView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
            make.width.equalToSuperview().offset(-30)
        }

        contentView.addSubview(scrollView)
        contentView.addSubview(groupsButton)

        groupsButton.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalToSuperview()
        }

        scrollView.snp.makeConstraints { (make) in
            make.top.leading.trailing.width.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalToSuperview().offset(-117)
        }

        nextButton.isEnabled = false
        reloadState()
    }
}

// MARK: - Navigator
extension PermissionViewController {
    fileprivate func gotoRiskLevelScreen() {
        let viewModel = RiskLevelViewModel()
        navigator.show(segue: .riskLevel(viewModel: viewModel), sender: self)
    }
}

// MARK: - Setup views
extension PermissionViewController {
    fileprivate func makeScrollView() -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.contentInset = UIEdgeInsets(top: 14, left: 15, bottom: 25, right: 15)
        return scrollView
    }

    fileprivate func makeTitleScreen() -> CenterView {
        let label = Label()
        label.numberOfLines = 0
        label.apply(text: R.string.phrase.permissionDescription(),
                    font: R.font.atlasGroteskLight(size: Size.ds(36)),
                    themeStyle: .lightTextColor, lineHeight: 1.2)
        label.textAlignment = .center
        return CenterView(contentView: label, spacing: 26, shrink: true)
    }

    fileprivate func makeNotificationOptionBox() -> OptionBoxView {
        let optionBoxView = OptionBoxView(
            title: R.string.localizable.notifications(),
            titleTop: 10,
            description: R.string.phrase.permissionNotificationDescription(),
            descTop: 8,
            btnImage: R.image.plusCircle()!)
        optionBoxView.button.setImage(R.image.checkedCircle(), for: .disabled)
        return optionBoxView
    }

    fileprivate func makeLocationOptionBox() -> OptionBoxView {
        let optionBoxView = OptionBoxView(
            title: R.string.localizable.location_data(),
            titleTop: 10,
            description: R.string.phrase.permissionLocationDescription(),
            descTop: 8,
            btnImage: R.image.plusCircle()!)
        optionBoxView.button.setImage(R.image.checkedCircle(), for: .disabled)
        return optionBoxView
    }
}
