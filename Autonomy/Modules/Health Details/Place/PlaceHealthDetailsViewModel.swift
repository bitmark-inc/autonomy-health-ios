//
//  PlaceHealthDetailsViewModel.swift
//  Autonomy
//
//  Created by Thuyen Truong on 6/5/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import RxSwift
import RxCocoa
import Hero

class PlaceHealthDetailsViewModel: ViewModel {

    // MARK: - Properties
    let poiID: String!
    let poiAutonomyProfileRelay = BehaviorRelay<PlaceAutonomyProfile?>(value: nil)
    var backAnimationType: HeroDefaultAnimationType = .slide(direction: .down)

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
                Global.generalErrorSubject.onNext(error)
            })
            .disposed(by: disposeBag)
    }

    func monitor() {
        guard let poiID = poiAutonomyProfileRelay.value?.id else { return }
        PointOfInterestService.monitor(poiID: poiID)
            .subscribe(onCompleted: { [weak self] in
                guard let self = self,
                    let currentAutonomyProfile = self.poiAutonomyProfileRelay.value else {
                        return
                }

                var ownedAutonomyProfile = currentAutonomyProfile
                ownedAutonomyProfile.owned = true
                self.poiAutonomyProfileRelay.accept(ownedAutonomyProfile)

            }, onError: { (error) in
                Global.generalErrorSubject.onNext(error)
            })
            .disposed(by: disposeBag)
    }

    func removeMonitoring() {
        guard let poiID = poiAutonomyProfileRelay.value?.id else { return }
        PointOfInterestService.delete(poiID: poiID)
            .subscribe(onCompleted: { [weak self] in
                guard let self = self,
                    let currentAutonomyProfile = self.poiAutonomyProfileRelay.value else {
                        return
                }

                var ownedAutonomyProfile = currentAutonomyProfile
                ownedAutonomyProfile.owned = false
                self.poiAutonomyProfileRelay.accept(ownedAutonomyProfile)
            }, onError: { (error) in
                Global.generalErrorSubject.onNext(error)
            })
            .disposed(by: disposeBag)
    }
}
