//
//  ResourceRatingViewModel.swift
//  Autonomy
//
//  Created by Thuyen Truong on 6/8/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import RxSwift
import RxCocoa

class ResourceRatingViewModel: ViewModel {

    // MARK: - Properties
    let poiID: String!
    let highlightResourceID: String?
    let resourceRatingsRelay = BehaviorRelay<[ResourceRating]?>(value: nil)
    let submitRatingsResultSubject = PublishSubject<Event<Never>>()

    // MARK: - Inits
    init(poiID: String, highlightResourceID: String? = nil) {
        self.poiID = poiID
        self.highlightResourceID = highlightResourceID

        super.init()
        fetchRatings()
    }

    // MARK: - Handlers
    func fetchRatings() {
        ResourceService.getRatings(poiID: poiID)
            .subscribe(onSuccess: { [weak self] in
                self?.resourceRatingsRelay.accept($0)
            }, onError: { (error) in
                Global.generalErrorSubject.onNext(error)
            })
            .disposed(by: disposeBag)
    }

    func submitRatings(ratings: [ResourceRating]) {
        Observable.zip(
            Observable.just(()).delay(.seconds(3), scheduler: MainScheduler.instance).asObservable(),
            ResourceService.rate(poiID: poiID, ratings: ratings).asObservable()
        )
        .subscribe(onError: { [weak self] (error) in
            self?.submitRatingsResultSubject.onNext(Event.error(error))
        }, onCompleted: { [weak self] in
            guard let self = self else { return }
            self.submitRatingsResultSubject.onNext(Event.completed)
            self.submitRatingsResultSubject.onCompleted()
        })
        .disposed(by: disposeBag)
    }
}
