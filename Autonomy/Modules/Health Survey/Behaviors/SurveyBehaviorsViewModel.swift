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

    // MARK: - Output
    let behaviorListRelay = BehaviorRelay<BehaviorList?>(value: nil)
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
                self?.behaviorListRelay.accept($0)
            }, onError: { [weak self] (error) in
                self?.fetchDataResultSubject.onNext(Event.error(error))
            })
            .disposed(by: disposeBag)
    }

    func report(with behaviorKeys: [String]) {
        loadingState.onNext(.processing)

        Observable.zip(
            Observable.just(()).delay(.seconds(3), scheduler: MainScheduler.instance).asObservable(),
            BehaviorService.report(behaviorKeys: behaviorKeys).asObservable()
        ).subscribe(onError: { [weak self] (error) in
            self?.surveySubmitResultSubject.onNext(Event.error(error))
        }, onCompleted: { [weak self] in
            guard let self = self else { return }
            self.surveySubmitResultSubject.onNext(Event.completed)
            self.surveySubmitResultSubject.onCompleted()
        })
        .disposed(by: disposeBag)
    }
}
