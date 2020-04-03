//
//  MainViewModel.swift
//  Autonomy
//
//  Created by Thuyen Truong on 3/27/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import RxSwift
import RxCocoa

class MainViewModel: ViewModel {

    // MARK: - Outputs
    var healthScoreRelay = BehaviorRelay<Int?>(value: nil)
    var feedsRelay = BehaviorRelay<[HelpRequest]>(value: [])
    let fetchFeedStateRelay = BehaviorRelay<LoadState>(value: .hide)

    // MARK: - Handlers
    func fetchHealthScore() {
        HealthService.getScore()
            .subscribe(onSuccess: { [weak self] (score) in
                guard let self = self else { return }
                self.healthScoreRelay.accept(Int(score))
            }, onError: { (error) in
                Global.log.error(error)
            })
            .disposed(by: disposeBag)
    }

    func fetchFeeds() {
        fetchFeedStateRelay.accept(.loading)

        HelpRequestService.list()
            .do(onDispose: { [weak self] in
                self?.fetchFeedStateRelay.accept(.hide)
            })
            .subscribe(onSuccess: { [weak self] (helpRequests) in
                guard let self = self else { return }
                self.feedsRelay.accept(helpRequests)
            }, onError: { (error) in
                Global.log.error(error)
            })
            .disposed(by: disposeBag)

    }
}
