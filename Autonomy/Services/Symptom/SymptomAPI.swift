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
    case create(survey: Survey)
    case report(symptomKeys: [String])
}

extension SymptomAPI: AuthorizedTargetType, VersionTargetType, LocationTargetType {

    var baseURL: URL {
        return URL(string: Constant.apiServerURL + "/api/symptoms")!
    }

    var path: String {
        switch self {
        case .list, .create:    return ""
        case .report:           return "report"
        }
    }

    var method: Moya.Method {
        switch self {
        case .list:     return .get
        case .create:   return .post
        case .report:   return .post
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

    var parameters: [String: Any]? {
        var params: [String: Any] = [:]
        switch self {
        case .list:
            return nil
    
        case .create(let survey):
            params["name"] = survey.name
            params["desc"] = survey.desc

        case .report(let symptomKeys):
            params["symptoms"] = symptomKeys
        }
        return params
    }

    var task: Task {
        if let parameters = parameters {
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        }
        return .requestPlain
    }

    var headers: [String: String]? {
        return [
            "Accept": "application/json",
            "Content-Type": "application/json"
        ]
    }
}
