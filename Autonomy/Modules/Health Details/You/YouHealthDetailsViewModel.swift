//
//  YouHealthDetailsViewModel.swift
//  Autonomy
//
//  Created by Thuyen Truong on 6/5/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import RxSwift
import RxCocoa

class YouHealthDetailsViewModel: ViewModel {

    // MARK: - Properties
    let youAutonomyProfileRelay = BehaviorRelay<YouAutonomyProfile?>(value: nil)

    override init() {
        super.init()

        fetchYouAutonomyProfile()
    }

    fileprivate func fetchYouAutonomyProfile() {
        AutonomyProfileService.get()
            .subscribe(onSuccess: { [weak self] in
                guard let self = self else { return }
                self.youAutonomyProfileRelay.accept($0)
            }, onError: { (error) in
                Global.backgroundErrorSubject.onNext(error)
            })
            .disposed(by: disposeBag)
    }
}
