//
//  AskInfoViewModel.swift
//  Autonomy
//
//  Created by Thuyen Truong on 3/30/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import RxSwift
import RxCocoa

class AskInfoViewModel: ViewModel {

    // MARK: - Properties
    let askInfoType: AskInfoType!
    let survey: Survey!

    // MARK: - Input
    let infoTextRelay = BehaviorRelay<String>(value: "")

    // MARK: - Outputs
    var submitSymptomResultSubject = PublishSubject<Event<Symptom>>()
    var submitBehavorResultSubject = PublishSubject<Event<Behavior>>()

    init(askInfoType: AskInfoType, survey: Survey) {
        self.askInfoType = askInfoType
        self.survey = survey
        super.init()
    }

    func submitSymptom(_ survey: Survey) {
        guard survey.name.isNotEmpty else {
            Global.log.error("FlowError: survey is empty")
            return
        }

        loadingState.onNext(.loading)
        SymptomService.create(survey: survey)
            .asObservable()
            .materializeWithCompleted(to: submitSymptomResultSubject)
            .disposed(by: disposeBag)
    }

    func submitBehavior(_ survey: Survey) {
        guard survey.name.isNotEmpty else {
            Global.log.error("FlowError: survey is empty")
            return
        }

        loadingState.onNext(.loading)
        BehaviorService.create(survey: survey)
            .asObservable()
            .materializeWithCompleted(to: submitBehavorResultSubject)
            .disposed(by: disposeBag)
    }
}
