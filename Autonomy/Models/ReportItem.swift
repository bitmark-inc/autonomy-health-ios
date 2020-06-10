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
    let value: Float
    let changeRate: Float

    enum CodingKeys: String, CodingKey {
        case name, value
        case changeRate = "change_rate"
    }
}
