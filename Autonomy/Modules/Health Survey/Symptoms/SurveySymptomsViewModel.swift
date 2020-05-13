//
//  SurveySymptomsViewModel.swift
//  Autonomy
//
//  Created by Thuyen Truong on 3/29/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import RxSwift
import RxCocoa

class SurveySymptomsViewModel: ViewModel {

    // MARK: - Output
    let symptomListRelay = BehaviorRelay<SymptomList?>(value: nil)
    let fetchDataResultSubject = PublishSubject<Event<Void>>()
    let surveySubmitResultSubject = PublishSubject<Event<Never>>()

    override init() {
        super.init()

        NetworkConnectionManager.shared.doActionWhenConnecting { [weak self] in
            self?.fetchSymptoms()
        }
    }

    fileprivate func fetchSymptoms() {
        SymptomService.getList()
            .subscribe(onSuccess: { [weak self] in
                self?.symptomListRelay.accept($0)
            }, onError: { [weak self] (error) in
                self?.fetchDataResultSubject.onNext(Event.error(error))
            })
            .disposed(by: disposeBag)
    }

    func report(with symptomKeys: [String]) {
        loadingState.onNext(.processing)

        Observable.zip(
            Observable.just(()).delay(.seconds(3), scheduler: MainScheduler.instance).asObservable(),
            SymptomService.report(symptomKeys: symptomKeys).asObservable()
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
