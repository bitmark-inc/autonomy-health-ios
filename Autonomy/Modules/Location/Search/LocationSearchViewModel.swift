//
//  LocationSearchViewModel.swift
//  Autonomy
//
//  Created by Thuyen Truong on 4/10/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import RxSwift
import RxCocoa
import GooglePlaces

class LocationSearchViewModel: ViewModel {

    // MARK: - Input
    let searchLocationTextRelay = BehaviorRelay<String>(value: "")
    let selectedPlaceIDSubject = PublishSubject<String>()

    // MARK: - Output
    let locationsResultRelay = BehaviorRelay<[GMSAutocompletePrediction]?>(value: nil)
    let placesResultRelay = BehaviorRelay<[PointOfInterest]?>(value: nil)
    let resourcesResultRelay = BehaviorRelay<[Resource]>(value: [])
    let selectedGooglePlaceIDSubject = PublishSubject<String>()

    let token = GMSAutocompleteSessionToken()
    fileprivate lazy var filter: GMSAutocompleteFilter = {
        let autoCompleteFilter = GMSAutocompleteFilter()
        autoCompleteFilter.type = .address
        return autoCompleteFilter
    }()
    var scoresObserver: Disposable?

    override init() {
        super.init()

        observeLocationTextInput()
        fetchSuggestionResources()
    }

    fileprivate func observeLocationTextInput() {
        searchLocationTextRelay
            .distinctUntilChanged()
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] (searchText) in
                guard let self = self else { return }
                self.scoresObserver?.dispose() // cancel the scores request

                guard searchText.isNotEmpty else {
                    self.placesResultRelay.accept(nil)
                    self.locationsResultRelay.accept([])
                    self.locationsResultRelay.accept(nil)
                    return
                }

                GMSPlacesClient.shared().findAutocompletePredictions(fromQuery: searchText, filter: nil, sessionToken: self.token) { [weak self] (results, error) in
                    guard let self = self else { return }

                    if let error = error {
                        Global.log.error(error)
                    }

                    guard let results = results else { return }
                    self.locationsResultRelay.accept(results)
                }
            })
            .disposed(by: disposeBag)
    }

    fileprivate func fetchSuggestionResources() {
        ResourceService.getSuggestionList()
            .subscribe(onSuccess: { [weak self] in
                guard let self = self else { return }
                self.resourcesResultRelay.accept($0)
            }, onError: { (error) in
                Global.backgroundErrorSubject.onError(error)
            })
            .disposed(by: disposeBag)
    }

    func fetchPlacesBy(resourceID: String) {
        PlaceService.get(resourceID: resourceID)
            .subscribe(onSuccess: { [weak self] in
                self?.placesResultRelay.accept($0)
            }, onError: { (error) in
                Global.backgroundErrorSubject.onError(error)
            })
            .disposed(by: disposeBag)
    }

    func addNewPlace(googlePlaceID: String) {
        loadingState.onNext(.processing)

        let gmsPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) |
            UInt(GMSPlaceField.placeID.rawValue) | UInt(GMSPlaceField.coordinate.rawValue) |
            UInt(GMSPlaceField.formattedAddress.rawValue))!

        let token = GMSAutocompleteSessionToken()

        GMSPlacesClient.shared().fetchPlace(fromPlaceID: googlePlaceID, placeFields: gmsPlaceField, sessionToken: token) { [weak self] (place, error) in
            guard let self = self else { return }

            loadingState.onNext(.hide)

            if let error = error {
                Global.log.error(error)
            }

            guard let place = place else {
                Global.log.error("empty place when fetchPlace with googlePlaceID: \(googlePlaceID)")
                return
            }

            loadingState.onNext(.processing)
            let pointOfInterest = PointOfInterest(place: place)
            PlaceService.create(pointOfInterest: pointOfInterest)
                .do(onDispose: {
                    loadingState.onNext(.hide)
                })
                .subscribe(onSuccess: { [weak self] (newPlace) in
                    guard let self = self else { return }
                    self.selectedPlaceIDSubject.onNext(newPlace.id)

                }, onError: { (error) in
                    Global.backgroundErrorSubject.onNext(error)
                })
                .disposed(by: self.disposeBag)
        }
    }
}
