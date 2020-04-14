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

    // MARK: - Output
    let locationsResultRelay = BehaviorRelay<[GMSAutocompletePrediction]>(value: [])
    let selectedPlaceIDSubject = PublishSubject<String?>()

    let token = GMSAutocompleteSessionToken()
    fileprivate lazy var filter: GMSAutocompleteFilter = {
        let autoCompleteFilter = GMSAutocompleteFilter()
        autoCompleteFilter.type = .address
        return autoCompleteFilter
    }()

    override init() {
        super.init()

        observeLocationTextInput()
    }

    fileprivate func observeLocationTextInput() {
        searchLocationTextRelay
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] (searchText) in
                guard let self = self else { return }

                guard searchText.isNotEmpty else {
                    self.locationsResultRelay.accept([])
                    return
                }

                GMSPlacesClient.shared().findAutocompletePredictions(fromQuery: searchText, filter: self.filter, sessionToken: self.token) { [weak self] (results, error) in
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
}
