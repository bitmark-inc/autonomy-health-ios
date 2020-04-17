//
//  GiveHelpViewModel.swift
//  Autonomy
//
//  Created by Thuyen Truong on 4/1/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import RxSwift
import RxCocoa

class GiveHelpViewModel: ViewModel {

    // MARK: - Properties
    let helpRequestID: String!

    // MARK: - Outputs
    var helpRequestRelay = BehaviorRelay<HelpRequest?>(value: nil)
    let fetchDataResultSubject = PublishSubject<Event<Void>>()
    let submitResultSubject = PublishSubject<Event<Never>>()

    var signUpHiddenDrive: Driver<Bool>

    init(helpRequestID: String) {
        self.helpRequestID = helpRequestID

        signUpHiddenDrive = helpRequestRelay
            .map { (helpRequest) -> Bool in
                guard let helpRequest = helpRequest else {
                    return true
                }

                if helpRequest.requester == Global.current.account?.getAccountNumber() {
                    return true
                }

                return helpRequest.helper?.isNotEmpty ?? false
            }
            .asDriver(onErrorJustReturn: true)

        super.init()
        fetchHelpRequest()
    }

    func fetchHelpRequest() {
        HelpRequestService.get(of: helpRequestID)
            .subscribe(onSuccess: { [weak self] in
                self?.helpRequestRelay.accept($0)
            }, onError: { [weak self] (error) in
                self?.fetchDataResultSubject.onNext(Event.error(error))
            })
            .disposed(by: disposeBag)
    }

    func giveHelp() {
        loadingState.onNext(.loading)

        HelpRequestService.give(to: helpRequestID)
            .asObservable()
            .materialize().bind { [weak self] in
                self?.submitResultSubject.onNext($0)
            }
            .disposed(by: disposeBag)
    }
}
