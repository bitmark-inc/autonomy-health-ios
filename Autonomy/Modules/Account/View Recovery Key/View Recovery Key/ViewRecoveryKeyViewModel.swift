//
//  ViewRecoveryKeyViewModel.swift
//  Autonomy
//
//  Created by thuyentruong on 10/21/19.
//  Copyright © 2019 Bitmark Inc. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class ViewRecoveryKeyViewModel: ViewModel {
    let currentRecoveryKeyRelay = BehaviorRelay<[String]>(value: [])

    override init() {
        super.init()
        setup()
    }

    func setup() {
        do {
            guard let currentAccount = Global.current.account else { return }
            currentRecoveryKeyRelay.accept(
                try currentAccount.getRecoverPhrase(language: .english)
            )
        } catch {
            Global.log.error(error)
        }
    }
}
