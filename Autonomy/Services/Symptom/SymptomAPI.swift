//
//  SymptomAPI.swift
//  Autonomy
//
//  Created by thuyentruong on 11/26/19.
//  Copyright © 2019 Bitmark Inc. All rights reserved.
//

import Foundation
import BitmarkSDK
import Moya

enum SymptomAPI {
    case list
    case fullList
    case create(name: String)
    case report(symptomKeys: [String])
    case metrics
}

extension SymptomAPI: AuthorizedTargetType, VersionTargetType, LocationTargetType {

    var baseURL: URL {
        switch self {
        case .list, .fullList:
            return URL(string: Constant.apiServerURL + "/api/v2/symptoms")!
        case .metrics:
            return URL(string: Constant.apiServerURL + "/api/metrics/symptom")!
        default:
            return URL(string: Constant.apiServerURL + "/api/symptoms")!
        }

    }

    var path: String {
        switch self {
        case .list, .fullList, .create, .metrics:
            return ""
        case .report:
            return "report"
        }
    }

    var method: Moya.Method {
        switch self {
        case .list, .fullList, .metrics:
            return .get
        case .create, .report:
            return .post
        }
    }

    var sampleData: Data {
        var dataURL: URL?
        switch self {
        case .list: dataURL = R.file.symptomsListJson()
        default:
            break
        }

        if let dataURL = dataURL, let data = try? Data(contentsOf: dataURL) {
            return data
        }
        return Data()
    }

    var task: Task {
        var params: [String: Any] = [:]

        switch self {
        case .list:
            if let localeCode = Locale.current.languageCode {
                params["lang"] = localeCode
            }
            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)

        case .fullList:
            params["all"] = true

            if let localeCode = Locale.current.languageCode {
                params["lang"] = localeCode
            }
            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)

        case .create(let name):
            params["name"] = name
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)

        case .report(let symptomKeys):
            params["symptoms"] = symptomKeys
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)

        case .metrics:
            return .requestPlain
        }
    }

    var headers: [String: String]? {
        return [
            "Accept": "application/json",
            "Content-Type": "application/json"
        ]
    }
}
