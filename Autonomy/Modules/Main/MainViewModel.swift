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

enum POIFetchSource {
    case remote
    case userAdjust
    case userAdjustFormula
}

class MainViewModel: ViewModel {

    // MARK: - Outputs
    let poisRelay = BehaviorRelay<(pois: [PointOfInterest], source: POIFetchSource)>(value: (pois: [], source: .remote))
    let youAutonomyProfileRelay = BehaviorRelay<YouAutonomyProfile?>(value: nil)
    let fetchPOIStateRelay = BehaviorRelay<LoadState>(value: .hide)

    let addLocationSubject = PublishSubject<PointOfInterest?>()
    let orderLocationIndexSubject = PublishSubject<(from: Int, to: Int)>()
    let submitResultSubject = PublishSubject<Event<Never>>()
    var navigateToPoiID: String?

    override init() {
        super.init()

        fetchYouAutonomyProfile()
        fetchPOIs()
    }

    convenience init(navigateToPoiID: String?) {
        self.init()
        self.navigateToPoiID = navigateToPoiID
    }

    // MARK: - Handlers
    fileprivate func fetchYouAutonomyProfile() {
        AutonomyProfileService.get()
            .subscribe(onSuccess: { [weak self] in
                guard let self = self else { return }
                self.youAutonomyProfileRelay.accept($0)
            }, onError: { (error) in
                Global.backgroundErrorSubject.onNext(error)
            })
        .disposed(by: disposeBag)
    }

    func fetchPOIs(source: POIFetchSource = .remote) {
        fetchPOIStateRelay.accept(.loading)

        PointOfInterestService.get()
            .do(onDispose: { [weak self] in
                self?.fetchPOIStateRelay.accept(.hide)
            })
            .subscribe(onSuccess: { [weak self] (savedPOIs) in
                guard let self = self else { return }
                self.poisRelay.accept((pois: savedPOIs, source: source))

            }, onError: { (error) in
                Global.backgroundErrorSubject.onNext(error)
            })
            .disposed(by: disposeBag)
    }

    func addNewPOI(placeID: String) {
        let gmsPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) |
            UInt(GMSPlaceField.placeID.rawValue) | UInt(GMSPlaceField.coordinate.rawValue) |
            UInt(GMSPlaceField.formattedAddress.rawValue))!

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

            if self.poisRelay.value.pois.contains(where: {
                $0.location.latitude == place.coordinate.latitude && $0.location.longitude == place.coordinate.longitude }) {
                Global.log.info("[addLocation] duplicated location")
                self.addLocationSubject.onNext(nil)
                return
            }

            let pointOfInterest = PointOfInterest(place: place)
            PointOfInterestService.create(pointOfInterest: pointOfInterest)
                .subscribe(onSuccess: { [weak self] (newPOI) in
                    guard let self = self else { return }
                    var newPOIs = self.poisRelay.value.pois; newPOIs.append(newPOI)
                    self.poisRelay.accept((pois: newPOIs, source: .userAdjust))
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

                self.poisRelay.accept((pois: currentPOIs, source: .userAdjust))
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
                currentPOIs.removeAll(where: { $0.id == poiID })
                self.poisRelay.accept((pois: currentPOIs, source: .userAdjust))
            }, onError: { [weak self] (error) in
                self?.submitResultSubject.onNext(Event.error(error))
            })
            .disposed(by: disposeBag)
    }

    func orderPOI(from: Int, to: Int) {
        Global.log.info("[orderPOIs] order from: \(from) - to: \(to)")
        var orderedPOIs = poisRelay.value.pois
        let orderedPOI = orderedPOIs[from]

        orderedPOIs.remove(at: from)
        orderedPOIs.insert(orderedPOI, at: to)

        poisRelay.accept((pois: orderedPOIs, source: .userAdjust))
        orderLocationIndexSubject.onNext((from: from, to: to))

        let orderedPoiIDs = orderedPOIs.map { $0.id }
        PointOfInterestService.order(poiIDs: orderedPoiIDs)
            .subscribe(onCompleted: {
                Global.log.info("[orderPOIs] order POIs successfully")
            }, onError: { [weak self] (error) in
                self?.submitResultSubject.onNext(Event.error(error))
            })
            .disposed(by: disposeBag)
    }
}
