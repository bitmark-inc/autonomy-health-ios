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

        NetworkConnectionManager.shared.doActionWhenConnecting { [weak self] in
            self?.fetchBehaviors()
        }
    }

    fileprivate func fetchBehaviors() {
        BehaviorService.getList()
            .subscribe(onSuccess: { [weak self] in
                self?.behaviorsRelay.accept($0)
            }, onError: { [weak self] (error) in
                self?.fetchDataResultSubject.onNext(Event.error(error))
            })
            .disposed(by: disposeBag)
    }

    func report(with behaviorKeys: [String]) {
        surveySubmitResultSubject.onCompleted() // don't block user to wait for this result.

        BehaviorService.report(behaviorKeys: behaviorKeys)
            .subscribe(onCompleted: {
                Global.log.info("[behavior] report successfully")
            }, onError: { (error) in
                Global.log.error(error)
            })
            .disposed(by: disposeBag)
    }
}
