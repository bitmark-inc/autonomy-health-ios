//
//  FormulaAPI.swift
//  Autonomy
//
//  Created by thuyentruong on 11/26/19.
//  Copyright © 2019 Bitmark Inc. All rights reserved.
//

import Foundation
import BitmarkSDK
import Moya

enum FormulaAPI {
    case get
    case update(coefficient: Coefficient)
    case delete
}

extension FormulaAPI: AuthorizedTargetType, VersionTargetType, LocationTargetType {

    var baseURL: URL {
        return URL(string: Constant.apiServerURL + "/api/accounts/me/profile_formula")!
    }

    var path: String {
        switch self {
        case .get, .update, .delete: return ""
        }
    }

    var method: Moya.Method {
        switch self {
        case .get:      return .get
        case .update:   return .put
        case .delete:   return .delete
        }
    }

    var sampleData: Data {
        return Data()
    }

    var task: Task {
        var params: [String: Any] = [:]

        switch self {
        case .get:
            if let localeCode = Locale.current.languageCode {
                params["lang"] = localeCode
            }
            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)

        case .delete:
            return .requestPlain

        case .update(let coefficient):
            let coefficient: [String: Any] = [
                "symptoms": coefficient.symptoms,
                "behaviors": coefficient.behaviors,
                "confirms": coefficient.confirms,
                "symptom_weights": coefficient.symptomKeyWeights
            ]

            params = ["coefficient": coefficient]
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        }
    }

    var headers: [String: String]? {
        return [
            "Accept": "application/json",
            "Content-Type": "application/json"
        ]
    }
}
