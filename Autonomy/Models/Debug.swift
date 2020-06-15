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
    let confirm, behavior, symptom: Int
    let score, confirmDelta, symptomDelta, behaviorDelta: Float

    enum CodingKeys: String, CodingKey {
        case score, confirm
        case confirmDelta = "confirm_delta"
        case symptom
        case symptomDelta = "symptom_delta"
        case behavior
        case behaviorDelta = "behavior_delta"
    }
}
