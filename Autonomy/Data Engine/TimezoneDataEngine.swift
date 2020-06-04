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

    static var abbrTimezoneInGMT: Any {
        let secondsFromGMT = TimeZone.current.secondsFromGMT()
        let sign = secondsFromGMT < 0 ? "-" : "+"
        let absSecondsFromGMT = abs(secondsFromGMT)
        let hours = Int(absSecondsFromGMT / 3600)
        let minutes = Int(absSecondsFromGMT % 3600 / 60)

        var str = "GMT\(sign)\(hours)"
        if minutes != 0 {
            str += ":\(minutes)"
        }
        return str
    }

    static let disposeBag = DisposeBag()

    static func syncTimezone() {
        ProfileService.updateMe(metadata: ["timezone": abbrTimezoneInGMT])
            .subscribe(onCompleted: {
                Global.log.info("[timezone] sync successfully")
            }, onError: { (error) in
                Global.backgroundErrorSubject.onNext(error)
            })
            .disposed(by: disposeBag)
    }

    static func create(riskLevel: RiskLevel) -> Completable {
        let metadata = ["risk": riskLevel.rawValue, "timezone": abbrTimezoneInGMT]
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
