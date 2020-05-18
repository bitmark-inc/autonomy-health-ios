//
//  ServerAPIError.swift
//  Autonomy
//
//  Created by thuyentruong on 11/22/19.
//  Copyright © 2019 Bitmark Inc. All rights reserved.
//

import Foundation
import RxSwift
import Moya
import SwifterSwift
import RxSwiftExt

let errorKeyPath = "error"

enum APIErrorCode: Int, Codable {
    case AccountHasTaken             = 1100
    case RequireUpdateVersion        = 1007
    case HelpRequestAlreadyResponsed = 1200
    case DuplicateHelpRequest        = 1201
    case UnexpectedResponseFormat    = 500
}

extension Data {
    func convertServerAPIError() -> ServerAPIError {
        var error: ServerAPIError
        do {
            let serverError = try JSONDecoder().decode([String: ServerAPIError].self, from: self)
            if serverError.has(key: errorKeyPath) {
                error = serverError[errorKeyPath]!
            } else {
                throw "incorrect error keypath"
            }
        } catch (_) {
            error = ServerAPIError(
                code: .UnexpectedResponseFormat,
                message: String(data: self, encoding: .utf8) ?? "")
        }
        return error
    }
}

struct ServerAPIError: Codable, Error {
    let code: APIErrorCode
    let message: String
}

extension PrimitiveSequence where Trait == SingleTrait, Element == Response {
    func filterSuccess() -> Observable<Element> {
        return self.asObservable().flatMap { (response) -> Observable<Element> in
            Global.log.debug("----- successful response -----")
            Global.log.debug(String(data: response.data, encoding: .utf8))

            if 200 ... 299 ~= response.statusCode {
                return Observable.just(response)
            }

            if response.statusCode == 406 {
                return Observable.error(ServerAPIError(code: .RequireUpdateVersion, message: ""))
            }

            let serverAPIError = response.data.convertServerAPIError()

            return Observable.error(serverAPIError)
        }
    }
}
