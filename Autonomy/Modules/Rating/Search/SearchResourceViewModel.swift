//
//  SearchResourceViewModel.swift
//  Autonomy
//
//  Created by Thuyen Truong on 6/8/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import RxSwift
import RxCocoa

class SearchResourceViewModel: ViewModel {

    // MARK: - Input
    let searchNameTextRelay = BehaviorRelay<String>(value: "")

    // MARK: - Output
    let newResourceSubject = PublishSubject<Resource>()
    let fullResourcesRelay = BehaviorRelay<[Resource]>(value: [])
    let fetchDataResultSubject = PublishSubject<Event<Void>>()
    let filteredRecordsResultRelay = BehaviorRelay<[Resource]>(value: [])

    var submitResourceResultSubject = PublishSubject<Event<Resource>>()

    let poiID: String!

    init(poiID: String) {
        self.poiID = poiID
        super.init()

        fetchFullResources()
        observeSearchTextInput()
    }

    fileprivate func fetchFullResources() {
        ResourceService.getFullList(poiID: poiID)
            .subscribe(onSuccess: { [weak self] in
                self?.fullResourcesRelay.accept($0)
            }, onError: { [weak self] (error) in
                self?.fetchDataResultSubject.onNext(Event.error(error))
            })
            .disposed(by: disposeBag)
    }

    fileprivate func observeSearchTextInput() {
        searchNameTextRelay
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] (searchText) in
                guard let self = self else { return }

                guard searchText.isNotEmpty else {
                    self.filteredRecordsResultRelay.accept([])
                    return
                }

                let fullResources = self.fullResourcesRelay.value
                let filteredResources = fullResources.filter {
                    $0.name.lowercased().contains(searchText.lowercased())
                }
                self.filteredRecordsResultRelay.accept(filteredResources)

            })
            .disposed(by: disposeBag)
    }

    func extractResource(name: String) -> Resource {
        var name = name
        let cleanName = name.trim().lowercased()

        if let existingResource = fullResourcesRelay.value.first(where: { $0.name.lowercased() == cleanName }) {
            return existingResource
        }

        return Resource(id: "", name: name)
    }
}
