//
//  HelpRequestAPI.swift
//  Autonomy
//
//  Created by thuyentruong on 11/26/19.
//  Copyright © 2019 Bitmark Inc. All rights reserved.
//

import Foundation
import BitmarkSDK
import Moya

enum HelpRequestAPI {
    case create(helpRequest: HelpRequest)
    case list
    case get(helpRequestID: String)
    case give(helpRequestID: String)
}

extension HelpRequestAPI: AuthorizedTargetType, VersionTargetType, LocationTargetType {

    var baseURL: URL {
        return URL(string: Constant.apiServerURL + "/api/helps")!
    }

    var path: String {
        switch self {
        case .create, .list:
            return ""
        case .get(let helpRequestID), .give(let helpRequestID):
            return helpRequestID
        }
    }

    var method: Moya.Method {
        switch self {
        case .create:           return .post
        case .get, .list:       return .get
        case .give:             return .patch
        }
    }

    var sampleData: Data {
        return Data()
    }

    var parameters: [String: Any]? {
        var params: [String: Any] = [:]
        switch self {
        case .create(let helpRequest):
            params["subject"] = helpRequest.subject
            params["exact_needs"] = helpRequest.exactNeeds
            params["meeting_location"] = helpRequest.meetingLocation
            params["contact_info"] = helpRequest.contactInfo

        case .get, .list, .give:
            return nil
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
