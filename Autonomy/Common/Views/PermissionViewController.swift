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
    lazy var notificationOptionBox = makeNotificationOptionBox()
    lazy var locationOptionBox = makeLocationOptionBox()
    lazy var backButton = makeLightBackItem()
    lazy var nextButton = SubmitButton(title: R.string.localizable.next().localizedUppercase,
                     icon: R.image.nextCircleArrow()!)
    lazy var groupsButton: UIView = {
        ButtonGroupView(button1: backButton, button2: nextButton)
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
                Global.current.locationManager.requestAlwaysAuthorization()
            }
        }.disposed(by: disposeBag)

        nextButton.rxTap.bind { [weak self] in
            self?.gotoRiskLevelScreen()
        }.disposed(by: disposeBag)
    }

    /// Reload state
    // - hidden button when notification is enabled
    // - hidden button when location is enabled
    @objc func reloadState() {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.getNotificationSettings { [weak self] (settings) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .denied, .notDetermined:
                    self.notificationOptionBox.button.isHidden = false

                default:
                    self.notificationOptionBox.button.isHidden = true
                }
            }
        }

        let isLocationEnabled = LocationPermission.isEnabled() == true
        locationOptionBox.button.isHidden = isLocationEnabled
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
            ]
        )

        paddingContentView.addSubview(groupsButton)
        groupsButton.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalToSuperview()
        }

        contentView.addSubview(paddingContentView)
        paddingContentView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(OurTheme.paddingInset)
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
    fileprivate func makeTitleScreen() -> CenterView {
        let label = Label()
        label.numberOfLines = 0
        label.apply(text: R.string.phrase.permissionDescription(),
                    font: R.font.atlasGroteskLight(size: Size.ds(36)),
                    themeStyle: .lightTextColor, lineHeight: 1.2)
        label.textAlignment = .center
        return CenterView(contentView: label, spacing: 26)
    }

    fileprivate func makeNotificationOptionBox() -> OptionBoxView {
        return OptionBoxView(title: R.string.localizable.notifications(),
                             titleTop: 10,
                             description: R.string.phrase.permissionNotificationDescription(),
                             descTop: 8,
                             btnImage: R.image.plusCircle()!)
    }

    fileprivate func makeLocationOptionBox() -> OptionBoxView {
        return OptionBoxView(title: R.string.localizable.location_data(),
                             titleTop: 10,
                             description: R.string.phrase.permissionLocationDescription(),
                             descTop: 8,
                             btnImage: R.image.plusCircle()!)
    }
}
