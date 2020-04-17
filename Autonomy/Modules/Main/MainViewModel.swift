//
//  MainViewModel.swift
//  Autonomy
//
//  Created by Thuyen Truong on 3/27/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import RxSwift
import RxCocoa
import GooglePlaces

class MainViewModel: ViewModel {

    // MARK: - Outputs
    var healthScoreRelay = BehaviorRelay<Int?>(value: nil)
    let poisRelay = BehaviorRelay(value: (pois: [PointOfInterest](), userInteractive: false))
    let fetchPOIStateRelay = BehaviorRelay<LoadState>(value: .hide)

    let addLocationSubject = PublishSubject<PointOfInterest>()
    let deleteLocationIndexSubject = PublishSubject<Int>()
    let submitResultSubject = PublishSubject<Event<Never>>()

    // MARK: - Handlers
    func fetchHealthScore() {
        HealthService.getScore()
            .subscribe(onSuccess: { [weak self] (score) in
                guard let self = self else { return }
                self.healthScoreRelay.accept(Int(score))
            }, onError: { (error) in
                Global.log.error(error)
            })
            .disposed(by: disposeBag)
    }

    func fetchPOIs() {
        fetchPOIStateRelay.accept(.loading)

        PointOfInterestService.get()
            .do(onDispose: { [weak self] in
                self?.fetchPOIStateRelay.accept(.hide)
            })
            .subscribe(onSuccess: { [weak self] (savedPOIs) in
                guard let self = self else { return }
                self.poisRelay.accept((pois: savedPOIs, userInteractive: false))

            }, onError: { (error) in
                Global.log.error(error)
            })
            .disposed(by: disposeBag)
    }

    func addNewPOI(placeID: String) {
        let gmsPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) |
            UInt(GMSPlaceField.placeID.rawValue) | UInt(GMSPlaceField.coordinate.rawValue))!

        let token = GMSAutocompleteSessionToken()

        GMSPlacesClient.shared().fetchPlace(fromPlaceID: placeID, placeFields: gmsPlaceField, sessionToken: token) { [weak self] (place, error) in
            guard let self = self else { return }
            if let error = error {
                Global.log.error(error)
            }

            guard let place = place else {
                Global.log.error("empty place when fetchPlace with placeID: \(placeID)")
                return
            }

            let pointOfInterest = PointOfInterest(place: place)

            PointOfInterestService.create(pointOfInterest: pointOfInterest)
                .subscribe(onSuccess: { [weak self] (newPOI) in
                    guard let self = self else { return }
                    var newPOIs = self.poisRelay.value.pois; newPOIs.append(newPOI)
                    self.poisRelay.accept((pois: newPOIs, userInteractive: true))
                    self.addLocationSubject.onNext(newPOI)

                }, onError: { [weak self] (error) in
                    self?.submitResultSubject.onNext(Event.error(error))
                })
                .disposed(by: self.disposeBag)
        }
    }

    func updatePOI(poiID: String, alias: String) {
        PointOfInterestService.update(poiID: poiID, alias: alias)
            .subscribe(onCompleted: { [weak self] in
                guard let self = self else { return }
                var currentPOIs = self.poisRelay.value.pois
                guard let updatedPOIIndex = currentPOIs.firstIndex(where: { $0.id == poiID }) else {
                    Global.log.error("[incorrect data] can not find poiID")
                    return
                }

                var updatedPOI = currentPOIs[updatedPOIIndex]
                updatedPOI.alias = alias
                currentPOIs[updatedPOIIndex] = updatedPOI

                self.poisRelay.accept((pois: currentPOIs, userInteractive: true))
            }, onError: { [weak self] (error) in
                self?.submitResultSubject.onNext(Event.error(error))
            })
            .disposed(by: disposeBag)
    }

    func deletePOI(poiID: String) {
        PointOfInterestService.delete(poiID: poiID)
            .subscribe(onCompleted: { [weak self] in
                guard let self = self else { return }
                var currentPOIs = self.poisRelay.value.pois
                guard let deletedPOIIndex = currentPOIs.firstIndex(where: { $0.id == poiID }) else {
                    Global.log.error("[incorrect data] can not find poiID")
                    return
                }
                currentPOIs.removeAll(where: { $0.id == poiID })
                self.poisRelay.accept((pois: currentPOIs, userInteractive: true))
                self.deleteLocationIndexSubject.onNext(deletedPOIIndex)
            }, onError: { [weak self] (error) in
                self?.submitResultSubject.onNext(Event.error(error))
            })
            .disposed(by: disposeBag)
    }
}
