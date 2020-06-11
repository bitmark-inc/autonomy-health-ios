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
    let healthScoreRelay = BehaviorRelay<[Float?]>(value: [])

    // MARK: - Output
    let locationsResultRelay = BehaviorRelay<[GMSAutocompletePrediction]>(value: [])
    let selectedPlaceIDSubject = PublishSubject<String?>()

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
        observeSearchToFetchScores()
    }

    fileprivate func observeLocationTextInput() {
        searchLocationTextRelay
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] (searchText) in
                guard let self = self else { return }
                self.scoresObserver?.dispose() // cancel the scores request
                self.healthScoreRelay.accept([])

                guard searchText.isNotEmpty else {
                    self.locationsResultRelay.accept([])
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

    fileprivate func observeSearchToFetchScores() {
        locationsResultRelay
            .subscribe(onNext: { [weak self] (places) in
                guard let self = self else { return }
                self.scoresObserver?.dispose()

                if places.count == 0 {
                    self.healthScoreRelay.accept([])
                    return
                }

                let placeInfos = places.map { $0.attributedFullText.string }
                self.scoresObserver = HealthService.getScores(places: placeInfos)
                    .subscribe(onSuccess: { [weak self] (scores) in
                        guard let self = self else { return }
                        self.healthScoreRelay.accept(scores)
                    }, onError: { (error) in
                        Global.backgroundErrorSubject.onNext(error)
                    })

                self.scoresObserver?.disposed(by: self.disposeBag)
            })
            .disposed(by: disposeBag)
    }
}
