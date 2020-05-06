//
//  FormulaSupporter.swift
//  Autonomy
//
//  Created by Thuyen Truong on 5/5/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxSwiftExt

enum FakeAppError: Error {
    case reloadPolling
}

class FormulaSupporter {

    // MARK: - Properties
    static let coefficientRelay = BehaviorRelay<(actor: String?, v: Coefficient)?>(value: nil)
    weak static var mainCollectionView: UICollectionView?
    static var displayingCell: HealthScoreCollectionCell? {
        return mainCollectionView?.visibleCells.first as? HealthScoreCollectionCell
    }

    static var pollingSyncFormulaDisposable: Disposable?
    static let disposeBag = DisposeBag()

    static func pollingSyncFormula() {
        pollingSyncFormulaDisposable?.dispose()

        func pollingFunction() -> Observable<Void> {
            return FormulaService.get()
                .asObservable()
                .flatMap({ (formulaWeight) -> Observable<Void> in
                    coefficientRelay.accept((actor: nil, v: formulaWeight.coefficient))
                    return Observable.error(FakeAppError.reloadPolling)
                })
                .do(onError: { (error) in
                    guard !AppError.errorByNetworkConnection(error),
                        !Global.handleErrorIfAsAFError(error),
                        type(of: error) != FakeAppError.self else {
                            return
                    }
                    Global.log.error(error)
                })
        }

        pollingSyncFormulaDisposable = pollingFunction()
            .observeOn(MainScheduler.asyncInstance)
            .retry(.delayed(maxCount: 1000, time: 2 * 60))
            .subscribe()

        pollingSyncFormulaDisposable?.disposed(by: disposeBag)
    }
}
