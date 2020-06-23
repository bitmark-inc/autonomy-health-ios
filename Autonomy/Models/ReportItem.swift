//
//  ReportItem.swift
//  Autonomy
//
//  Created by Thuyen Truong on 6/10/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import Foundation

struct ReportItem: Codable {
    let name: String
    let value: Float?
    let changeRate: Float
    let distribution: [String: Double]

    enum CodingKeys: String, CodingKey {
        case name, value
        case changeRate = "change_rate"
        case distribution
    }

    init(from decoder: Decoder) throws {
        let values  = try decoder.container(keyedBy: CodingKeys.self)
        name        = try values.decode(String.self, forKey: .name)
        value       = try values.decode(Float?.self, forKey: .value)
        changeRate  = try values.decode(Float?.self, forKey: .changeRate) ?? 0
        distribution  = try values.decode([String: Double].self, forKey: .distribution)
    }
}
