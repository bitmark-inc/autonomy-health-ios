//
//  ReviewHelpRequestViewModel.swift
//  Autonomy
//
//  Created by Thuyen Truong on 3/30/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import RxSwift
import RxCocoa

class ReviewHelpRequestViewModel: ViewModel {

    // MARK: - Properties
    let helpRequest: HelpRequest!

    // MARK: - Outputs
    var submitResultSubject = PublishSubject<Event<Never>>()

    init(helpRequest: HelpRequest) {
        self.helpRequest = helpRequest
        super.init()
    }

    func submit() {
        loadingState.onNext(.loading)
        HelpRequestService.create(helpRequest: helpRequest)
            .asCompletable()
            .asObservable()
            .materialize().bind { [weak self] in
                self?.submitResultSubject.onNext($0)
            }
            .disposed(by: disposeBag)
    }
}
