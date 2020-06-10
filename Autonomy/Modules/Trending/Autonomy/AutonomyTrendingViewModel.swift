//
//  AutonomyTrendingViewModel.swift
//  Autonomy
//
//  Created by Thuyen Truong on 6/9/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import RxSwift
import RxCocoa

enum AutonomyObject {
    case individual
    case neighbor
    case poi(poiID: String)
}

enum ReportItemObject {
    case cases
    case symptoms
    case behaviors

    var title: String {
        switch self {
        case .cases:    return R.string.localizable.cases().localizedUppercase
        case .symptoms: return R.string.localizable.symptoms().localizedUppercase
        case .behaviors: return R.string.localizable.behaviors().localizedUppercase
        }
    }
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
