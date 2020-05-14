//
//  ProfileAPI.swift
//  Autonomy
//
//  Created by thuyentruong on 11/26/19.
//  Copyright © 2019 Bitmark Inc. All rights reserved.
//

import Foundation
import BitmarkSDK
import Moya

enum ProfileAPI {
    case create(encryptedPublicKey: String, metadata: [String: Any])
    case getMe
    case updateMe(metadata: [String: Any])
    case deleteMe
    case reportHere
}

extension ProfileAPI: AuthorizedTargetType, VersionTargetType, LocationTargetType {

    var baseURL: URL {
        return URL(string: Constant.apiServerURL + "/api/accounts")!
    }

    var path: String {
        switch self {
        case .create:
            return ""
        case .getMe, .updateMe, .deleteMe:
            return "me"
        case .reportHere:
            return "me/here"
        }
    }

    var method: Moya.Method {
        switch self {
        case .create:   return .post
        case .getMe:    return .get
        case .updateMe: return .patch
        case .deleteMe: return .delete
        case .reportHere: return .put
        }
    }

    var sampleData: Data {
        return Data()
    }

    var parameters: [String: Any]? {
        var params: [String: Any] = [:]
        switch self {
        case .create(let encryptedPublicKey, let metadata):
            params["enc_pub_key"] = encryptedPublicKey
            params["metadata"] = metadata
        case .getMe, .deleteMe, .reportHere:
            return nil
        case .updateMe(let metadata):
            params["metadata"] = metadata

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
