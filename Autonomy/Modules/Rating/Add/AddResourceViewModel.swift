//
//  AddResourceViewModel.swift
//  Autonomy
//
//  Created by Thuyen Truong on 6/8/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import RxSwift
import RxCocoa

class AddResourceViewModel: ViewModel {

    // MARK: - Properties
    let poiID: String!
    let importantResourcesRelay = BehaviorRelay<[Resource]?>(value: nil)
    let addResourcesResultSubject = PublishSubject<Event<[Resource]>>()

    init(poiID: String) {
        self.poiID = poiID
        super.init()

        fetchImportantResources()
    }

    // MARK: - Handlers
    func fetchImportantResources() {
        ResourceService.getImportantList(poiID: poiID)
            .subscribe(onSuccess: { [weak self] in
                self?.importantResourcesRelay.accept($0)
            }, onError: { (error) in
                Global.backgroundErrorSubject.onNext(error)
            })
            .disposed(by: disposeBag)
    }

    func add(resources: [Resource]) {
        loadingState.onNext(.processing)

        Observable.zip(
            Observable.just(()).delay(.seconds(3), scheduler: MainScheduler.instance).asObservable(),
            ResourceService.add(poiID: poiID, resources: resources).asObservable()
        )
        .subscribe(onNext: { [weak self] (_, resources) in
            guard let self = self else { return }
            self.addResourcesResultSubject.onNext(Event.next(resources))
            self.addResourcesResultSubject.onCompleted()

        }, onError: { [weak self] (error) in
            self?.addResourcesResultSubject.onNext(Event.error(error))
        })
        .disposed(by: disposeBag)
    }
}
