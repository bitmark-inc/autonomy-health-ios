//
//  ReportedBehaviorViewModel.swift
//  Autonomy
//
//  Created by Thuyen Truong on 5/11/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import RxSwift
import RxCocoa

class ReportedBehaviorViewModel: ViewModel {

    // MARK: - Output
    let fetchDataResultSubject = PublishSubject<Event<Void>>()
    let metricsRelay = BehaviorRelay<SurveyMetrics?>(value: nil)

    override init() {
        super.init()

        fetchMetrics()
    }

    fileprivate func fetchMetrics() {
        BehaviorService.getMetrics()
            .subscribe(onSuccess: { [weak self] in
                self?.metricsRelay.accept($0)
            }, onError: { [weak self] (error) in
                self?.fetchDataResultSubject.onNext(Event.error(error))
            })
            .disposed(by: disposeBag)
    }
}
