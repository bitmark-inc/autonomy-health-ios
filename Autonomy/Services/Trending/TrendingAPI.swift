//
//  TrendingAPI.swift
//  Autonomy
//
//  Created by Thuyen Truong on 6/10/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import Foundation
import Moya

enum TrendingAPI {
    case autonomyTrending(autonomyObject: AutonomyObject, datePeriod: DatePeriod)
}

extension TrendingAPI: AuthorizedTargetType, VersionTargetType, LocationTargetType {

    var baseURL: URL {
        return URL(string: Constant.apiServerURL + "/api/report-items")!
    }

    var path: String {
        return ""
    }

    var method: Moya.Method {
        return .get
    }

    var sampleData: Data {
        var dataURL: URL?
        switch self {
        case .autonomyTrending:
            dataURL = R.file.trendingAutonomyJson()
        }

        if let dataURL = dataURL, let data = try? Data(contentsOf: dataURL) {
            return data
        }
        return Data()
    }

    var task: Task {
        var params: [String: Any] = [:]

        switch self {
        case .autonomyTrending(let autonomyObject, let datePeriod):
            if let localeCode = Locale.current.languageCode {
                params["lang"] = localeCode
            }

            switch autonomyObject {
            case .individual:
                params["scope"] = "individual"
            case .place(let poiID):
                params["scope"] = "neighbor"
                params["poi_id"] = poiID
            }

            params["start"] = datePeriod.startDate.appTimeFormat
            params["end"] = datePeriod.endDate.appTimeFormat

            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)
        }
    }

    var headers: [String: String]? {
        return [
            "Accept": "application/json",
            "Content-Type": "application/json"
        ]
    }
}
