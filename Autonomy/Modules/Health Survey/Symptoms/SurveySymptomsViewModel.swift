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

    // MARK: - Input
    // MARK: - Output
    let symptomsRelay = BehaviorRelay<[Symptom]?>(value: nil)
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
                self?.symptomsRelay.accept($0)
            }, onError: { [weak self] (error) in
                self?.fetchDataResultSubject.onNext(Event.error(error))
            })
            .disposed(by: disposeBag)
    }

    func report(with symptomKeys: [String]) {
        SymptomService.report(symptomKeys: symptomKeys)
            .asObservable()
            .materialize().bind { [weak self] in
                self?.surveySubmitResultSubject.onNext($0)
            }
            .disposed(by: disposeBag)
    }
}
