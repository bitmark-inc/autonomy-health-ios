//
//  AreaProfile.swift
//  Autonomy
//
//  Created by Thuyen Truong on 4/17/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import Foundation

struct AreaProfile: Codable {
    let score, confirm, confirmDelta, symptoms: Int
    let symptomsDelta, behavior, behaviorDelta: Int

    enum CodingKeys: String, CodingKey {
        case score, confirm
        case confirmDelta = "confirm_delta"
        case symptoms
        case symptomsDelta = "symptoms_delta"
        case behavior
        case behaviorDelta = "behavior_delta"
    }
}
