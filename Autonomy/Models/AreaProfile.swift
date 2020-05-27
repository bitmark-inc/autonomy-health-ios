//
//  AreaProfile.swift
//  Autonomy
//
//  Created by Thuyen Truong on 4/17/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import Foundation

struct AreaProfile: Decodable {
    let score: Float
    let confirm, symptoms, behavior: Int
    let confirmDelta, symptomsDelta, behaviorDelta: Float
    let details: AreaProfileDetails

    enum CodingKeys: String, CodingKey {
        case score
        case confirm
        case confirmDelta = "confirm_delta"
        case symptoms
        case symptomsDelta = "symptoms_delta"
        case behavior
        case behaviorDelta = "behavior_delta"
        case details
    }
}

struct AreaProfileDetails: Decodable {
    let confirm:   AreaProfileDetail
    let behaviors: AreaProfileDetail
    let symptoms: AreaProfileDetail
}

struct AreaProfileDetail: Decodable {
    let score: Float
}
