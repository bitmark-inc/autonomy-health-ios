//
//  SearchBehaviorViewModel.swift
//  Autonomy
//
//  Created by Thuyen Truong on 5/11/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import RxSwift
import RxCocoa
import GooglePlaces

class SearchBehaviorViewModel: ViewModel {

    // MARK: - Input

    let searchNameTextRelay = BehaviorRelay<String>(value: "")

    // MARK: - Output
    let newBehaviorSubject = PublishSubject<Behavior>()
    let fullBehaviorsRelay = BehaviorRelay<[Behavior]>(value: [])
    let fetchDataResultSubject = PublishSubject<Event<Void>>()
    let filteredRecordsResultRelay = BehaviorRelay<[Behavior]>(value: [])

    var submitBehaviorResultSubject = PublishSubject<Event<Behavior>>()

    override init() {
        super.init()

        fetchFullBehaviors()
        observeSearchTextInput()
    }

    fileprivate func fetchFullBehaviors() {
        BehaviorService.getFullList()
            .subscribe(onSuccess: { [weak self] in
                let fullBehaviors = $0.officialBehaviors + $0.customizedBehaviors
                self?.fullBehaviorsRelay.accept(fullBehaviors)
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

                let fullBehaviors = self.fullBehaviorsRelay.value
                let filteredBehaviors = fullBehaviors.filter {
                    $0.name.lowercased().contains(searchText.lowercased())
                }
                self.filteredRecordsResultRelay.accept(filteredBehaviors)

            })
            .disposed(by: disposeBag)
    }


    func submitBehavior(name: String) {
        loadingState.onNext(.processing)
        var name = name
        let cleanName = name.trim().lowercased()

        if let existingBehavior = fullBehaviorsRelay.value.first(where: { $0.name.lowercased() == cleanName }) {
            submitBehaviorResultSubject.onNext(Event.next(existingBehavior))
            return
        }

        BehaviorService.create(name: name)
            .asObservable()
            .materializeWithCompleted(to: submitBehaviorResultSubject)
            .disposed(by: disposeBag)
    }
}
