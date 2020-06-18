//
//  SignInViewModel.swift
//  Autonomy
//
//  Created by Thuyen Truong on 6/17/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import RxSwift
import RxCocoa
import BitmarkSDK

class SignInViewModel: ViewModel {

    // MARK: - Properties
    let phrasesTextRelay = BehaviorRelay<String>(value: "")
    let phrasesRelay = BehaviorRelay<[String]>(value: [])

    // MARK: - Outputs
    var submitEnabled: Driver<Bool>
    let signInResultSubject = PublishSubject<Event<Void>>()

    override init() {
        submitEnabled = phrasesRelay
            .map { $0.count == Constant.numberOfPhrases }
            .asDriver(onErrorJustReturn: false)

        super.init()

        setup()
    }

    func setup() {
        phrasesTextRelay
            .map { $0.trimmed }
            .map { $0.toRecoveryPhrases() }
            .bind(to: phrasesRelay)
            .disposed(by: disposeBag)

        signInResultSubject
            .subscribe { print($0) }
        .disposed(by: disposeBag)
    }

    func signIn() {
        Global.log.info("[start] signIn")
        loadingState.onNext(.processing)

        AccountService.rxGetAccount(phrases: phrasesRelay.value)
            .map { (account) in
                Global.current.cachedAccount = account
                try Global.current.setupCurrentAccount()
            }
            .asObservable()
            .materialize()
            .delay(.seconds(2), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] (event) in
                self?.signInResultSubject.onNext(event)
            })
            .disposed(by: disposeBag)
    }
}
