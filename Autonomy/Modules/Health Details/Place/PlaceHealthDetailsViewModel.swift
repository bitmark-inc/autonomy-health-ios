//
//  PlaceHealthDetailsViewModel.swift
//  Autonomy
//
//  Created by Thuyen Truong on 6/5/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import RxSwift
import RxCocoa

class PlaceHealthDetailsViewModel: ViewModel {

    // MARK: - Properties
    let poiID: String!
    let poiAutonomyProfileRelay = BehaviorRelay<PlaceAutonomyProfile?>(value: nil)

    init(poiID: String) {
        self.poiID = poiID
        super.init()
    }

    func fetchPOIAutonomyProfile(allResources: Bool) {
        AutonomyProfileService.get(poiID: poiID, allResources: allResources)
            .subscribe(onSuccess: { [weak self] in
                guard let self = self else { return }
                self.poiAutonomyProfileRelay.accept($0)
            }, onError: { (error) in
                Global.backgroundErrorSubject.onNext(error)
            })
            .disposed(by: disposeBag)
    }
}
