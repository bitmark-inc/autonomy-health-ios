//
//  HealthCenter.swift
//  Autonomy
//
//  Created by Thuyen Truong on 6/9/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import Foundation

struct HealthCenter: Codable {
    let distance: Float
    let country, state, county, institutionCode: String
    let latitude, longitude: Double
    let name, address, phone: String

    enum CodingKeys: String, CodingKey {
        case distance, country, state, county
        case institutionCode = "institution_code"
        case latitude, longitude, name, address, phone
    }
}
