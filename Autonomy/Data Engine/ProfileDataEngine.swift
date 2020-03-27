//
//  ProfileDataEngine.swift
//  Autonomy
//
//  Created by thuyentruong on 11/27/19.
//  Copyright © 2019 Bitmark Inc. All rights reserved.
//

import Foundation
import RxSwift

protocol ProfileDataEngineDelegate {
    static func create(riskLevel: RiskLevel) -> Completable
    static func fetchMe() -> Profile?
}

class ProfileDataEngine: ProfileDataEngineDelegate {
    static func fetchMe() -> Profile? {
        return nil
    }

    static func create(riskLevel: RiskLevel) -> Completable {
        let metadata = ["risk": riskLevel.rawValue]
        return AccountService.rxCreateAndSetupNewAccountIfNotExist()
            .andThen(ProfileService.create(metadata: metadata))
            .asCompletable()
            .catchError { (error) -> Completable in
                if let error = error as? ServerAPIError, error.code == .AccountHasTaken {
                    return Completable.empty()
                }

                return Completable.error(error)
            }
    }
}
