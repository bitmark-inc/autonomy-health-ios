//
//  SurveySymptomsViewController.swift
//  Autonomy
//
//  Created by Thuyen Truong on 3/29/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import SkeletonView

class SurveySymptomsViewController: ViewController {

    // MARK: - Properties
    lazy var headerScreen: UIView = {
        HeaderView(header: R.string.localizable.symptoms().localizedUppercase)
    }()
    lazy var titleScreen = makeTitleScreen()
    lazy var symptomsScrollView = makeSymptomsScrollView()
    lazy var doneButton = SubmitButton(title: R.string.localizable.done().localizedUppercase,
                     icon: R.image.doneCicleArrow()!)

    lazy var thisViewModel: SurveySymptomsViewModel = {
        return viewModel as! SurveySymptomsViewModel
    }()

    var symptoms = [Symptom]()
    var symptomViews = [CheckboxView]()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: - bindViewModel
    override func bindViewModel() {
        super.bindViewModel()

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

        thisViewModel.symptomsRelay
            .filterNil()
            .subscribe(onNext: { [weak self] (symptoms) in
                guard let self = self else { return }
                self.symptoms = symptoms
                self.rebuildSymptomsScrollView()
            })
            .disposed(by: disposeBag)

        thisViewModel.surveySubmitResultSubject
            .subscribe(onNext: { [weak self] (event) in
                guard let self = self else { return }
                loadingState.onNext(.hide)
                switch event {
                case .error(let error):
                    // TODO: self.errorWhenFetchingData(error: error)
                    self.gotoMainScreen()

                case .completed:
                    Global.log.info("[symptoms] report successfully")
                    self.gotoMainScreen()
                default:
                    break
                }

            })
            .disposed(by: disposeBag)

        doneButton.rxTap.bind { [weak self] in
            guard let self = self else { return }
            let selectedSymptomKeys = self.getSelectedSymptomKeys()
            self.thisViewModel.report(with: selectedSymptomKeys)
        }.disposed(by: disposeBag)
    }

    func getSelectedSymptomKeys() -> [String] {
        return symptoms.enumerated().compactMap { (index, symptom) -> String? in
            let symptomsCheckView = symptomViews[index]
            return symptomsCheckView.checkBox.on ? symptom.id : nil
        }
    }

    fileprivate func rebuildSymptomsScrollView() {
        symptomViews = symptoms.map { (symptom) -> CheckboxView in
            return CheckboxView(title: symptom.name, description: symptom.desc)
        }

        let symptomViewsStack = UIStackView(arrangedSubviews: symptomViews, axis: .vertical, spacing: 15)

        symptomsScrollView.removeSubviews()
        symptomsScrollView.addSubview(symptomViewsStack)

        symptomViewsStack.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
            make.width.equalToSuperview().offset(-30)
        }
    }

    // MARK: - Error Handlers
    func errorWhenFetchingData(error: Error) {
        guard !AppError.errorByNetworkConnection(error),
            !showIfRequireUpdateVersion(with: error),
            !handleErrorIfAsAFError(error) else {
                return
        }

        Global.log.error(error)
        showErrorAlertWithSupport(message: R.string.error.system())
    }

    fileprivate func errorWhenReport(error: Error) {
        guard !AppError.errorByNetworkConnection(error),
            !handleErrorIfAsAFError(error),
            !showIfRequireUpdateVersion(with: error) else {
                return
        }

        Global.log.error(error)
        showErrorAlertWithSupport(message: R.string.error.system())
    }

    // MARK: - Setup views
    override func setupViews() {
        super.setupViews()

        // *** Setup subviews ***
        let paddingContentView = LinearView(
            items: [
                (headerScreen, 0),
                (titleScreen, 0),
                (SeparateLine(height: 1), 3)],
            bottomConstraint: true)

        contentView.addSubview(paddingContentView)
        contentView.addSubview(symptomsScrollView)
        contentView.addSubview(doneButton)

        titleScreen.snp.makeConstraints { (make) in
            make.height.equalTo(contentView).multipliedBy(OurTheme.titleHeight)
        }

        paddingContentView.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
                .inset(OurTheme.paddingOverBottomInset)
        }

        symptomsScrollView.snp.makeConstraints { (make) in
            make.top.equalTo(paddingContentView.snp.bottom).offset(13)
            make.leading.trailing.equalToSuperview()
        }

        doneButton.snp.makeConstraints { (make) in
            make.top.equalTo(symptomsScrollView.snp.bottom).offset(3)
            make.trailing.bottom.equalToSuperview()
                .inset(OurTheme.paddingInset)
        }

        sampleSymptomsScrollView()
    }
}

// MARK: - Navigator
extension SurveySymptomsViewController {
    fileprivate func gotoMainScreen() {
        let viewModel = MainViewModel()
        navigator.show(segue: .main(viewModel: viewModel), sender: self,
                       transition: .replace(type: .slide(direction: .down)))
    }
}

// MARK: - Setup views
extension SurveySymptomsViewController {
    fileprivate func makeTitleScreen() -> CenterView {
        let label = Label()
        label.numberOfLines = 0
        label.apply(text: R.string.phrase.surveySymptomsTitle(),
                    font: R.font.atlasGroteskLight(size: 36),
                    themeStyle: .lightTextColor, lineHeight: 1.2)
        label.textAlignment = .center
        return CenterView(contentView: label)
    }

    fileprivate func makeSymptomsScrollView() -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.contentInset = OurTheme.paddingInset
        scrollView.isSkeletonable = true
        return scrollView
    }

    fileprivate func sampleSymptomsScrollView() {
        let symptomViews = (0...3).map { (symptom) -> CheckboxView in
            return CheckboxView(title: "---", description: "---")
        }

        let symptomViewsStack = UIStackView(arrangedSubviews: symptomViews, axis: .vertical, spacing: 15)
        symptomViewsStack.isSkeletonable = true
        symptomViewsStack.showAnimatedSkeleton()

        symptomsScrollView.removeSubviews()
        symptomsScrollView.addSubview(symptomViewsStack)

        symptomViewsStack.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
            make.width.equalToSuperview().offset(-30)
        }
    }
}
