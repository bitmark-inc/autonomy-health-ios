//
//  Debug.swift
//  Autonomy
//
//  Created by Thuyen Truong on 5/4/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import Foundation

class Debug: Decodable {
    let metrics: DebugMetrics
    let users, aqi, symptoms: Int
}

// MARK: - Metrics
struct DebugMetrics: Codable {
    let confirm, behavior, symptoms: Int
    let score, confirmDelta, symptomsDelta, behaviorDelta: Float

    enum CodingKeys: String, CodingKey {
        case score, confirm
        case confirmDelta = "confirm_delta"
        case symptoms
        case symptomsDelta = "symptoms_delta"
        case behavior
        case behaviorDelta = "behavior_delta"
    }
}
