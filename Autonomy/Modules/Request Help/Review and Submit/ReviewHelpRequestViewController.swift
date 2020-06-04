//
//  ReviewHelpRequestViewController.swift
//  Autonomy
//
//  Created by Thuyen Truong on 3/30/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import KMPlaceholderTextView
import PanModal

class ReviewHelpRequestViewController: ViewController, BackNavigator {

    // MARK: - Properties
    lazy var headerScreen: UIView = {
        HeaderView(header: R.string.localizable.assistance().localizedUppercase)
    }()
    lazy var titleScreen = makeTitleScreen()
    lazy var scrollView = makeScrollView()
    lazy var subjectView = makeSubjectView()
    lazy var infoViews: [UIView] = {
        return AssistanceInfoType.allCases.map { makeInfoView(for: $0) }
    }()

    lazy var backButton = makeLightBackItem()
    lazy var submitButton = RightIconButton(title: R.string.localizable.submit().localizedUppercase,
                                         icon: R.image.upCircleArrow()!)

    lazy var groupsButton: UIView = {
        ButtonGroupView(button1: backButton, button2: submitButton)
    }()
    var groupBottomConstraint: Constraint?

    lazy var thisViewModel: ReviewHelpRequestViewModel = {
        return viewModel as! ReviewHelpRequestViewModel
    }()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: - bindViewModel
    override func bindViewModel() {
        super.bindViewModel()

        thisViewModel.submitResultSubject
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (event) in
                guard let self = self else { return }
                loadingState.onNext(.hide)
                switch event {
                case .error(let error):
                    self.errorWhenSubmit(error: error)
                case .completed:
                    Global.log.info("[done] submitted help request")
                    self.showSubmittedPanModel()
                default:
                    break
                }
            }).disposed(by: disposeBag)

        submitButton.rx.tap.bind { [weak self] in
            self?.thisViewModel.submit()
        }.disposed(by: disposeBag)
    }

    fileprivate func showSubmittedPanModel() {
    }

    // MARK: - Error Handlers
    fileprivate func errorWhenSubmit(error: Error) {
        guard !handleIfGeneralError(error: error) else { return }

        if let error = error as? ServerAPIError {
            switch error.code {
            case .DuplicateHelpRequest:
                showDuplicateHelpErrorAlert()
                return
            default:
                break
            }
        }

        Global.log.error(error)
        showErrorAlertWithSupport(message: R.string.error.system())
    }

    fileprivate func showDuplicateHelpErrorAlert() {
        let alertController = UIAlertController(
            title: R.string.error.requestHelpDuplicate(),
            message: R.string.error.requestHelpDuplicateMessage(),
            preferredStyle: .alert)

        let okButton = UIAlertAction(title: R.string.localizable.ok(), style: .default) { [weak self] (_) in
            self?.gotoMainScreen()
        }

        alertController.addAction(okButton)
        alertController.show()
    }

    // MARK: - Setup views
    override func setupViews() {
        super.setupViews()

        let infoViewsStack = UIStackView(arrangedSubviews: infoViews, axis: .vertical, spacing: 30)

        // *** Setup subviews ***
        let paddingContentView = LinearView(
            items: [
                (headerScreen, 0),
                (titleScreen, 0),
                (SeparateLine(height: 1), 3),
                (subjectView, 15),
                (infoViewsStack, 15)
            ], bottomConstraint: true)

        scrollView.addSubview(paddingContentView)


        contentView.addSubview(scrollView)
        contentView.addSubview(groupsButton)

        paddingContentView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
            make.width.equalToSuperview().offset(-30)
        }

        groupsButton.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalToSuperview()
                .inset(OurTheme.paddingInset)
        }

        titleScreen.snp.makeConstraints { (make) in
            make.height.equalTo(OurTheme.titleHeight)
        }

        scrollView.snp.makeConstraints { (make) in
            make.top.leading.trailing.width.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalToSuperview().offset(-60)
        }
    }
}

// MARK: - PandModelDelegate
extension ReviewHelpRequestViewController: PanModalDelegate {
    func donePanModel() {
        gotoMainScreen()
    }
}

// MARK: - Navigator
extension ReviewHelpRequestViewController {
    fileprivate func gotoMainScreen() {
        let viewModel = MainViewModel()
        navigator.show(segue: .main(viewModel: viewModel), sender: self, transition: .replace(type: .slide(direction: .down)))
    }
}

// MARK: - Setup views
extension ReviewHelpRequestViewController {
    fileprivate func makeScrollView() -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.contentInset = OurTheme.paddingInset
        return scrollView
    }

    fileprivate func makeTitleScreen() -> CenterView {
        let label = Label()
        label.numberOfLines = 0
        label.apply(text: R.string.phrase.reviewTitle(),
                    font: R.font.atlasGroteskLight(size: Size.ds(36)),
                    themeStyle: .lightTextColor, lineHeight: 1.2)
        label.textAlignment = .center
        return CenterView(contentView: label)
    }

    fileprivate func makeSubjectView() -> UIView {
        let coloredCircle = UIView(frame: CGRect(x: 0, y: 0, width: 90, height: 90))
        coloredCircle.cornerRadius = 45
        coloredCircle.backgroundColor = HealthRisk.high.color

        let dateInfoLabel = Label()
        dateInfoLabel.apply(
            text: thisViewModel.helpRequest.formattedCreatedAt?.localizedUppercase ?? "---",
            font: R.font.domaineSansTextLight(size: 14),
            themeStyle: .silverChaliceColor)

        let subjectLabel = Label()
        subjectLabel.numberOfLines = 0
        subjectLabel.apply(text: thisViewModel.helpRequest.assistanceKind?.requestTitle,
                           font: R.font.atlasGroteskLight(size: 24),
                           themeStyle: .lightTextColor)

        let rightView = LinearView(items: [(dateInfoLabel, 0), (subjectLabel, 5)])

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

        return view
    }

    fileprivate func makeInfoView(for assistanceInfoType: AssistanceInfoType) -> UIView {
        let titleLabel = Label()
        titleLabel.apply(text: assistanceInfoType.title.localizedUppercase,
                         font: R.font.domaineSansTextLight(size: 14),
                         themeStyle: .silverChaliceColor)
        titleLabel.textAlignment = .center

        var infoText: String?
        switch assistanceInfoType {
        case .exactNeeds:       infoText = thisViewModel.helpRequest.exactNeeds
        case .meetingLocation:  infoText = thisViewModel.helpRequest.meetingLocation
        case .contactInfo:      infoText = thisViewModel.helpRequest.contactInfo
        }

        let textInfoLabel = Label()
        textInfoLabel.numberOfLines = 0
        textInfoLabel.apply(text: infoText, font: R.font.atlasGroteskLight(size: 18),
                            themeStyle: .lightTextColor, lineHeight: 1.2)

        return LinearView(items: [
            (SeparateLine(height: 1), 0),
            (titleLabel, 15),
            (textInfoLabel, 15)
        ], bottomConstraint: true)
    }
}
