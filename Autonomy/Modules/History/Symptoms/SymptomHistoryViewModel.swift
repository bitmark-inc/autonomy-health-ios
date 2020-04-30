//
//  SymptomHistoryViewModel.swift
//  Autonomy
//
//  Created by Thuyen Truong on 4/29/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import RxSwift
import RxCocoa

class SymptomHistoryViewModel: ViewModel {

    // MARK: - Output
    let symptomHistoriesRelay = BehaviorRelay<[SymptomsHistory]?>(value: nil)
    let fetchDataResultSubject = PublishSubject<Event<Void>>()
    let loadingStateRelay = BehaviorRelay<LoadState>(value: .hide)
    let lock = NSLock()
    var endRecord: Bool = false

    override init() {
        super.init()

        fetchHistories()
    }

    func fetchHistories(before date: Date? = nil) {
        guard lock.try() else {
            return
        }

        loadingStateRelay.accept(.loading)
        HistoryService.symptoms(before: date)
            .do(onDispose: { [weak self] in
                guard let self = self else { return }
                self.lock.unlock()
                self.loadingStateRelay.accept(.hide)
            })
            .subscribe(onSuccess: { [weak self] in
                guard let self = self else { return }

                // track endRecord
                if $0.count < Constant.callHistoryLimit {
                    self.endRecord = true
                }

                var histories = self.symptomHistoriesRelay.value ?? []
                histories.append(contentsOf: $0)
                self.symptomHistoriesRelay.accept(histories)
            }, onError: { [weak self] (error) in
                self?.fetchDataResultSubject.onNext(Event.error(error))
            })
            .disposed(by: disposeBag)
    }
}
