//
//  ItemTrendingViewModel.swift
//  Autonomy
//
//  Created by Thuyen Truong on 6/10/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import RxSwift
import RxCocoa

class ItemTrendingViewModel: ViewModel {

    // MARK: - Properties
    let autonomyObject: AutonomyObject!
    let reportItemObject: ReportItemObject!
    let reportItemsRelay = BehaviorRelay<[ReportItem]?>(value: nil)
    let fetchTrendingStateRelay = BehaviorRelay<LoadState>(value: .hide)

    // MARK: - Inits
    init(autonomyObject: AutonomyObject, reportItemObject: ReportItemObject) {
        self.autonomyObject = autonomyObject
        self.reportItemObject = reportItemObject
    }

    func fetchTrending(in datePeriod: DatePeriod) {
        fetchTrendingStateRelay.accept(.loading)

        let fetchDataItemsSingle: Single<[ReportItem]>!
        switch reportItemObject {
        case .symptoms:
            fetchDataItemsSingle = TrendingService.getSymptomsTrending(autonomyObject: autonomyObject, in: datePeriod)
        case .behaviors:
            fetchDataItemsSingle = TrendingService.getBehaviorsTrending(autonomyObject: autonomyObject, in: datePeriod)
        case .cases:
            fetchDataItemsSingle = TrendingService.getCasesTrending(autonomyObject: autonomyObject, in: datePeriod)
        default:
            return
        }

        fetchDataItemsSingle
            .do(onDispose: { [weak self] in
                self?.fetchTrendingStateRelay.accept(.hide)
            })
            .subscribe(onSuccess: { [weak self] in
                self?.reportItemsRelay.accept($0)
            }, onError: { (error) in
                Global.backgroundErrorSubject.onNext(error)
            })
            .disposed(by: disposeBag)
    }
}
