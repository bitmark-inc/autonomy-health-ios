//
//  SurveyBehaviorsViewModel.swift
//  Autonomy
//
//  Created by Thuyen Truong on 3/29/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import RxSwift
import RxCocoa

class SurveyBehaviorsViewModel: ViewModel {

    // MARK: - Input
    // MARK: - Output
    let behaviorsRelay = BehaviorRelay<[Behavior]?>(value: nil)
    let fetchDataResultSubject = PublishSubject<Event<Void>>()
    let surveySubmitResultSubject = PublishSubject<Event<Never>>()

    override init() {
        super.init()

    }
}
