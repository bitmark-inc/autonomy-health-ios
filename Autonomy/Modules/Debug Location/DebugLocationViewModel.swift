//
//  DebugLocationViewModel.swift
//  Autonomy
//
//  Created by Thuyen Truong on 4/10/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import RxSwift
import RxCocoa
import GooglePlaces

class DebugLocationViewModel: ViewModel {

    // MARK: - Input
    let pois: [PointOfInterest]!
    let poiIDs: [String?]!

    // MARK: - Output
    let debugsRelay = BehaviorRelay<[String?: Debug]>(value: [:])

    init(pois: [PointOfInterest]) {
        self.pois = pois

        var poiIDs: [String?] = pois.map { $0.id }
        poiIDs.prepend(nil)
        self.poiIDs = poiIDs

        super.init()

        poiIDs.forEach { (poiID) in
            fetchDebug(poiID: poiID)
        }
    }

    func fetchDebug(poiID: String?) {
        let debugSingle: Single<Debug>!

        if let poiID = poiID {
            debugSingle = DebugService.get(poiID: poiID)
        } else {
            debugSingle = DebugService.get()
        }

        debugSingle
            .subscribe(onSuccess: { [weak self] (debug) in
                guard let self = self else { return }
                var debugs = self.debugsRelay.value
                debugs[poiID] = debug
                self.debugsRelay.accept(debugs)

            }, onError: { (error) in
                Global.backgroundErrorSubject.onNext(error)
            })
            .disposed(by: disposeBag)
    }
}
