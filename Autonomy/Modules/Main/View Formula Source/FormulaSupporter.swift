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

    enum DefaultState {
        case `default`
        case custom
        case isReseting
    }

    static var shared = FormulaSupporter()

    // MARK: - Properties
    let coefficientRelay = BehaviorRelay<(actor: String?, v: Coefficient)?>(value: nil)
    let defaultStateRelay = BehaviorRelay<DefaultState>(value: .default)
    weak var mainCollectionView: UICollectionView?
    var displayingCell: HealthScoreCollectionCell? {
        return mainCollectionView?.visibleCells.first as? HealthScoreCollectionCell
    }

    var pollingSyncFormulaDisposable: Disposable?
    let disposeBag = DisposeBag()

    init() {
        coefficientRelay
            .filterNil()
            .filter { $0.actor != nil }
            .map { _ in .custom }
            .bind(to: defaultStateRelay)
            .disposed(by: disposeBag)
    }

    func pollingSyncFormula() {
        pollingSyncFormulaDisposable?.dispose()

        func pollingFunction() -> Observable<Void> {
            return FormulaService.get()
                .asObservable()
                .flatMap({ [weak self] (formulaWeight) -> Observable<Void> in
                    guard let self = self else { return Observable.never() }
                    self.coefficientRelay.accept((actor: nil, v: formulaWeight.coefficient))
                    self.defaultStateRelay.accept(formulaWeight.isDefault ? .default : .custom)
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
