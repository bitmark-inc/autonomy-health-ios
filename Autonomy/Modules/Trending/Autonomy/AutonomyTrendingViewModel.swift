//
//  AutonomyTrendingViewModel.swift
//  Autonomy
//
//  Created by Thuyen Truong on 6/9/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import RxSwift
import RxCocoa
import SwiftDate

enum AutonomyObject {
    case individual
    case place(poiID: String)
}

class AutonomyTrendingViewModel: ViewModel {

    // MARK: - Properties
    let autonomyObject: AutonomyObject!
    let reportItemsRelay = BehaviorRelay<[ReportItem]?>(value: nil)

    // MARK: - Inits
    init(autonomyObject: AutonomyObject) {
        self.autonomyObject = autonomyObject
    }

    func fetchTrending(in datePeriod: DatePeriod) {
        TrendingService.getAutonomyTrending(autonomyObject: autonomyObject, in: datePeriod)
            .subscribe(onSuccess: { [weak self] in
                self?.reportItemsRelay.accept($0)
            }, onError: { (error) in
                Global.backgroundErrorSubject.onNext(error)
            })
            .disposed(by: disposeBag)
    }
}
