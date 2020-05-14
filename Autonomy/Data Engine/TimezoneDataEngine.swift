//
//  TimezoneDataEngine.swift
//  Autonomy
//
//  Created by Thuyen Truong on 5/14/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import Foundation
import RxSwift

protocol TimezoneDataEngineDelegate {
    static func syncTimezone()
}

class TimezoneDataEngine: TimezoneDataEngineDelegate {

    static var abbrTimezone: Any {
        return TimeZone.current.abbreviation() ?? ""
    }

    static let disposeBag = DisposeBag()

    static func syncTimezone() {
        ProfileService.updateMe(metadata: ["timezone": abbrTimezone])
            .subscribe(onCompleted: {
                Global.log.info("[timezone] sync successfully")
            }, onError: { (error) in
                Global.log.error(error)
            })
            .disposed(by: disposeBag)

    }


    static func create(riskLevel: RiskLevel) -> Completable {
        let metadata = ["risk": riskLevel.rawValue, "timezone": abbrTimezone]
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
