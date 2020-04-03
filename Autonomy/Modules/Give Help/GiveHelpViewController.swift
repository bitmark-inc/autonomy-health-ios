//
//  GiveHelpViewController.swift
//  Autonomy
//
//  Created by Thuyen Truong on 4/1/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import KMPlaceholderTextView
import PanModal
import SkeletonView

class GiveHelpViewController: ViewController, BackNavigator {

    // MARK: - Properties
    lazy var headerScreen: UIView = {
        HeaderView(header: R.string.localizable.request().localizedUppercase)
    }()
    lazy var scrollView = makeScrollView()
    lazy var contentSrollView = UIView()
    lazy var dateInfoLabel = makeDateInfoLabel()
    lazy var subjectLabel = makeSubjectLabel()
    lazy var subjectView = makeSubjectView()
    lazy var textInfoLabels = [(key: AssistanceInfoType, view: Label)]()
    lazy var infoViews: [UIView] = {
        return AssistanceInfoType.allCases.map { makeInfoView(for: $0) }
    }()

    lazy var backButton = makeLightBackItem()
    lazy var submitButton = SubmitButton(title: R.string.localizable.signUp().localizedUppercase,
                                         icon: R.image.tickCircleArrow()!)
    lazy var signedUpMessageView = UIView()
    lazy var copiedView = makeCopiedView()
    var infoViewsStack: UIStackView?

    lazy var groupsButton: UIView = {
        ButtonGroupView(button1: backButton, button2: submitButton)
    }()
    var groupBottomConstraint: Constraint?

    lazy var thisViewModel: GiveHelpViewModel = {
        return viewModel as! GiveHelpViewModel
    }()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: - bindViewModel
    override func bindViewModel() {
        super.bindViewModel()

        thisViewModel.signUpHiddenDrive
            .drive(submitButton.rx.isHidden)
            .disposed(by: disposeBag)

        thisViewModel.fetchDataResultSubject
            .subscribe(onNext: { [weak self] (event) in
                guard let self = self else { return }
                switch event {
                case .error(let error):
                    self.errorWhenFetchingData(error: error)
                default:
                    break
                }
            })
            .disposed(by: disposeBag)

        thisViewModel.helpRequestRelay
            .subscribe(onNext: { [weak self] (helpRequest) in
                guard let self = self else { return }
                guard let helpRequest = helpRequest else {
                    self.submitButton.isEnabled = false
                    self.scrollView.showAnimatedSkeleton()
                    return
                }

                // fill data into helpRequest
                self.submitButton.isEnabled = true
                self.fillData(helpRequest: helpRequest)
            })
            .disposed(by: disposeBag)

        thisViewModel.submitResultSubject
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (event) in
                guard let self = self else { return }
                loadingState.onNext(.hide)
                switch event {
                case .error(let error):
                    self.errorWhenSubmit(error: error)
                case .completed:
                    Global.log.info("[done] signed up help request")
                    self.showSignedPanModel()
                default:
                    break
                }
            }).disposed(by: disposeBag)

        submitButton.rxTap.bind { [weak self] in
            self?.thisViewModel.giveHelp()
        }.disposed(by: disposeBag)
    }

    fileprivate func showSignedPanModel() {
        let viewController = SuccessGiveHelpViewController()
        viewController.delegate = self
        presentPanModal(viewController)
    }

    // MARK: - Error Handlers
    fileprivate func errorWhenSubmit(error: Error) {
        guard !AppError.errorByNetworkConnection(error),
            !handleErrorIfAsAFError(error),
            !showIfRequireUpdateVersion(with: error) else {
                return
        }

        if let error = error as? ServerAPIError {
            switch error.code {
            case .HelpRequestAlreadyResponsed:
                thisViewModel.fetchHelpRequest()
                showErrorAlert(
                    title: R.string.error.giveHelpAlreadySigned(),
                    message: R.string.error.giveHelpAlreadySignedMessage())
                return
            default:
                break
            }
        }

        Global.log.error(error)
        showErrorAlertWithSupport(message: R.string.error.system())
    }

    func errorWhenFetchingData(error: Error) {
        guard !AppError.errorByNetworkConnection(error),
            !showIfRequireUpdateVersion(with: error),
            !handleErrorIfAsAFError(error) else {
                return
        }

        Global.log.error(error)
        showErrorAlertWithSupport(message: R.string.error.system())
    }

    // MARK: - Handlers
    fileprivate func fillData(helpRequest: HelpRequest) {
        scrollView.hideSkeleton()
        dateInfoLabel.setText(helpRequest.formattedCreatedAt?.localizedUppercase)
        subjectLabel.setText(helpRequest.assistanceKind?.requestTitle)

        for (key, infoLabel) in textInfoLabels {
            switch key {
            case .exactNeeds: infoLabel.setText(helpRequest.exactNeeds)
            case .meetingLocation: infoLabel.setText(helpRequest.meetingLocation)
            case .contactInfo: infoLabel.setText(helpRequest.contactInfo)
            }
        }

        fillSignedUpMessageIfNeeded(helpRequest: helpRequest)
    }

    fileprivate func fillSignedUpMessageIfNeeded(helpRequest: HelpRequest) {
        guard let helper = helpRequest.helper, helper.isNotEmpty else {
            return
        }

        guard let accountNumber = Global.current.account?.getAccountNumber() else { return }

        let messageView: UIView!
        if helpRequest.requester == accountNumber {
            messageView = makeSignedMessageView(message: R.string.phrase.giveHelpRequesterSubmitted())
        } else if helper == accountNumber {
            messageView = makeSignedMessageView(message: R.string.phrase.giveHelpHelperSubmitted())
        } else {
            infoViewsStack?.removeFromSuperview()
            let separateLine = SeparateLine(height: 1)
            contentSrollView.addSubview(separateLine)
            separateLine.snp.makeConstraints { (make) in
                make.top.equalTo(subjectView.snp.bottom).offset(15)
                make.leading.trailing.bottom.equalToSuperview()
            }

            messageView = makeSignedMessageView(message: R.string.phrase.giveHelpHelperOtherSubmitted())
        }

        signedUpMessageView.addSubview(messageView)
        messageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }

    fileprivate func copyExactNeedsInfo() {
        UIPasteboard.general.string = textInfoLabels.first(where: { $0.key == .exactNeeds })?.view.text
        flashCopiedView()
    }

    fileprivate func linkMap() {
        guard let meetingLocation = textInfoLabels.first(where: { $0.key == .meetingLocation })?.view.text,
            let targetURL = URL(string: "https://www.google.com/maps?q=\(meetingLocation.urlEncoded)") else { return }
        navigator.show(segue: .safariController(targetURL), sender: self, transition: .alert)
    }

    fileprivate func copyContactInfo() {
        UIPasteboard.general.string = textInfoLabels.first(where: { $0.key == .contactInfo })?.view.text
        flashCopiedView()
    }

    // MARK: - Setup views
    override func setupViews() {
        super.setupViews()

        infoViewsStack = UIStackView(arrangedSubviews: infoViews, axis: .vertical, spacing: 30)
        infoViewsStack!.isSkeletonable = true

        // *** Setup subviews ***
        contentSrollView = LinearView(
            items: [
                (headerScreen, 0),
                (subjectView, 26),
                (infoViewsStack!, 15)
            ], bottomConstraint: true)
        contentSrollView.isSkeletonable = true

        scrollView.addSubview(contentSrollView)
        scrollView.isSkeletonable = true

        contentView.addSubview(scrollView)
        contentView.addSubview(signedUpMessageView)
        contentView.addSubview(copiedView)
        contentView.addSubview(groupsButton)

        contentSrollView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
            make.width.equalToSuperview().offset(-30)
        }

        scrollView.snp.makeConstraints { (make) in
            make.top.leading.trailing.width.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(signedUpMessageView.snp.top).offset(-15)
        }

        signedUpMessageView.snp.makeConstraints { (make) in
            make.bottom.equalTo(groupsButton.snp.top).offset(-15)
            make.leading.trailing.equalToSuperview()
        }

        copiedView.snp.makeConstraints { (make) in
            make.bottom.equalTo(groupsButton.snp.top).offset(-15)
            make.width.equalToSuperview().offset(-30)
            make.centerX.equalToSuperview()
        }

        groupsButton.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalToSuperview()
                .inset(OurTheme.paddingInset)
        }
    }

    fileprivate func flashCopiedView() {
        copiedView.layer.opacity = 1

        UIView.animate(withDuration: 0.5, delay: 1.5, animations: {
            self.copiedView.layer.opacity = 0
        })
    }
}

// MARK: - PanModalDelegate
extension GiveHelpViewController: PanModalDelegate {
    func donePanModel() {
        let messageView = makeSignedMessageView(message: R.string.phrase.giveHelpHelperSubmitted())
        signedUpMessageView.removeSubviews()
        signedUpMessageView.addSubview(messageView)
        messageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        submitButton.isHidden = true
    }
}

// MARK: - Setup views
extension GiveHelpViewController {
    fileprivate func makeScrollView() -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.contentInset = OurTheme.paddingInset
        return scrollView
    }

    fileprivate func makeSubjectView() -> UIView {
        let coloredCircle = UIView(frame: CGRect(x: 0, y: 0, width: 90, height: 90))
        coloredCircle.cornerRadius = 45
        coloredCircle.backgroundColor = Constant.HeathColor.red

        let rightView = LinearView(items: [(dateInfoLabel, 0), (subjectLabel, 5)])
        rightView.isSkeletonable = true

        let view = UIView()
        view.addSubview(coloredCircle)
        view.addSubview(rightView)

        coloredCircle.snp.makeConstraints { (make) in
            make.width.height.equalTo(90)
            make.leading.top.bottom.equalToSuperview()
        }

        rightView.snp.makeConstraints { (make) in
            make.leading.equalTo(coloredCircle.snp.trailing).offset(15)
            make.top.trailing.bottom.equalToSuperview()
        }
        view.isSkeletonable = true
        return view
    }

    fileprivate func makeInfoView(for assistanceInfoType: AssistanceInfoType) -> UIView {
        let titleLabel = Label()
        titleLabel.apply(text: assistanceInfoType.title.localizedUppercase,
                         font: R.font.domaineSansTextLight(size: 14),
                         themeStyle: .silverChaliceColor)
        titleLabel.textAlignment = .center

        let iconButton = UIButton()

        switch assistanceInfoType {
        case .exactNeeds:
            iconButton.setImage(R.image.copy(), for: .normal)
            iconButton.rx.tap.bind { [weak self] in
                self?.copyExactNeedsInfo()
            }.disposed(by: disposeBag)
        case .meetingLocation:
            iconButton.setImage(R.image.linkMap(), for: .normal)
            iconButton.rx.tap.bind { [weak self] in
                self?.linkMap()
            }.disposed(by: disposeBag)
        case .contactInfo:
            iconButton.setImage(R.image.copy(), for: .normal)
            iconButton.rx.tap.bind { [weak self] in
                self?.copyContactInfo()
            }.disposed(by: disposeBag)
        }

        iconButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 29, bottom: 29, right: 0)
        iconButton.isSkeletonable = true

        let textInfoLabel = makeTextInfoLabel()
        textInfoLabels.append((key: assistanceInfoType, view: textInfoLabel))

        let contentView = UIView()
        contentView.addSubview(textInfoLabel)
        contentView.addSubview(iconButton)
        contentView.isSkeletonable = true

        textInfoLabel.snp.makeConstraints { (make) in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalToSuperview().offset(-25)
        }

        iconButton.snp.makeConstraints { (make) in
            make.top.trailing.equalToSuperview()
            make.height.equalTo(70)
        }

        let view = LinearView(items: [
            (SeparateLine(height: 1), 0),
            (titleLabel, 15),
            (contentView, 15)
        ], bottomConstraint: true)
        view.isSkeletonable = true
        return view
    }

    fileprivate func makeDateInfoLabel() -> Label {
        let label = Label()
        label.apply(
            text: "---", font: R.font.domaineSansTextLight(size: 14),
            themeStyle: .silverChaliceColor)
        label.isSkeletonable = true
        return label
    }

    fileprivate func makeSubjectLabel() -> Label {
        let label = Label()
        label.numberOfLines = 0
        label.apply(text: "---", font: R.font.atlasGroteskLight(size: 24),
                    themeStyle: .lightTextColor)
        label.isSkeletonable = true
        return label
    }

    fileprivate func makeTextInfoLabel() -> Label {
        let label = Label()
        label.numberOfLines = 0
        label.apply(text: "---", font: R.font.atlasGroteskLight(size: 18),
                    themeStyle: .lightTextColor, lineHeight: 1.2)
        label.isSkeletonable = true
        return label
    }

    fileprivate func makeSignedMessageView(message: String) -> UIView {
        let label = Label()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.apply(text: message,
                    font: R.font.atlasGroteskLight(size: 18),
                    themeStyle: .lightTextColor, lineHeight: 1.2)

        let signedUpMessageCover = UIView()
        signedUpMessageCover.addSubview(label)

        label.snp.makeConstraints { (make) in
            make.width.equalToSuperview().offset(-30)
            make.top.bottom.centerX.equalToSuperview()
        }

        let view = LinearView(items: [
            (SeparateLine(height: 1), 0),
            (SeparateLine(height: 1), 3),
            (signedUpMessageCover, 13),
            (SeparateLine(height: 1), 13),
            (SeparateLine(height: 1), 3)
        ], bottomConstraint: true)

        return view
    }

    fileprivate func makeCopiedView() -> UIView {
        let label = Label()
        label.textAlignment = .center
        label.apply(text: R.string.localizable.copied().localizedUppercase,
                    font: R.font.domaineSansTextLight(size: 14),
                    themeStyle: .lightTextColor)

        let view = UIView()
        view.addSubview(label)
        view.backgroundColor = .black
        view.layer.opacity = 0

        label.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
                .inset(UIEdgeInsets(top: 16, left: 0, bottom: 15, right: 0))
            make.centerX.equalToSuperview()
        }

        return view
    }
}
