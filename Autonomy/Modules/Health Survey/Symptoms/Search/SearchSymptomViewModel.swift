//
//  SearchSymptomViewModel.swift
//  Autonomy
//
//  Created by Thuyen Truong on 5/11/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import RxSwift
import RxCocoa
import GooglePlaces

class SearchSymptomViewModel: ViewModel {

    // MARK: - Input

    let searchNameTextRelay = BehaviorRelay<String>(value: "")

    // MARK: - Output
    let newSymptomSubject = PublishSubject<Symptom>()
    let fullSymptomsRelay = BehaviorRelay<[Symptom]>(value: [])
    let fetchDataResultSubject = PublishSubject<Event<Void>>()
    let filteredRecordsResultRelay = BehaviorRelay<[Symptom]>(value: [])

    var submitSymptomResultSubject = PublishSubject<Event<Symptom>>()

    override init() {
        super.init()

        fetchFullSymptoms()
        observeSearchTextInput()
    }

    fileprivate func fetchFullSymptoms() {
        SymptomService.getFullList()
            .subscribe(onSuccess: { [weak self] in
                let fullSymptoms = $0.officialSymptoms + $0.customizedSymptoms + $0.suggestedSymptoms
                self?.fullSymptomsRelay.accept(fullSymptoms)
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

                let fullSymptoms = self.fullSymptomsRelay.value
                let filteredSymptoms = fullSymptoms.filter { $0.name.contains(searchText) }
                self.filteredRecordsResultRelay.accept(filteredSymptoms)

            })
            .disposed(by: disposeBag)
    }


    func submitSymptom(name: String) {
        loadingState.onNext(.processing)
        SymptomService.create(name: name)
            .asObservable()
            .materializeWithCompleted(to: submitSymptomResultSubject)
            .disposed(by: disposeBag)
    }
}
