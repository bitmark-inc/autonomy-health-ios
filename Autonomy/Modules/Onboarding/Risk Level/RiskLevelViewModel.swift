//
//  RiskLevelViewModel.swift
//  Autonomy
//
//  Created by Thuyen Truong on 3/27/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import RxSwift
import RxCocoa

class RiskLevelViewModel: ViewModel {

    // MARK: - Input
    var riskLevelSelectionRelay = BehaviorRelay<RiskLevel?>(value: nil)

    // MARK: - Output
    let signUpResultSubject = PublishSubject<Event<Never>>()

    func signUp() {
        guard let riskLevel = riskLevelSelectionRelay.value else { return }

        loadingState.onNext(.loading)
        ProfileDataEngine.create(riskLevel: riskLevel)
            .asObservable()
            .materializeWithCompleted(to: signUpResultSubject)
            .disposed(by: disposeBag)
    }
}
