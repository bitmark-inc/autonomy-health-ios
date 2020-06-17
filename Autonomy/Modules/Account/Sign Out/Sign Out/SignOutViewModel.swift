//
//  SignOutViewModel.swift
//  Autonomy
//
//  Created by Thuyen Truong on 6/17/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import RxSwift
import RxCocoa

class SignOutViewModel: ViewModel {

    // MARK: - Properties
    let phrasesTextRelay = BehaviorRelay<String>(value: "")
    let phrasesRelay = BehaviorRelay<[String]>(value: [])

    // MARK: - Outputs
    var submitEnabled: Driver<Bool>
    let signOutResultSubject = PublishSubject<Event<Never>>()

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
    }

    func signOut() {
        do {
            try Global.current.removeCurrentAccount()
        } catch {
            signOutResultSubject.onNext(Event.error(AccountError.invalidRecoveryKey))
        }

        Observable.zip(
            Observable.just(()).delay(.seconds(3), scheduler: MainScheduler.instance),
            Observable.just(())
        )
        .subscribe(onNext: { [weak self] (_) in
            self?.signOutResultSubject.onNext(.completed)
        })
        .disposed(by: disposeBag)
    }

    func validRecoveryKey() -> Bool {
        do {
            guard let currentAccount = Global.current.account else { throw AppError.emptyCurrentAccount }

            let currentRecoveryKey = try currentAccount.getRecoverPhrase(language: .english)
            return phrasesRelay.value == currentRecoveryKey
        } catch {
            Global.log.error(error)
            return false
        }
    }
}
