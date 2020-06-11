//
//  YouAutonomyProfile.swift
//  Autonomy
//
//  Created by Thuyen Truong on 6/10/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import Foundation

struct YouAutonomyProfile: Codable {
    let autonomyScore, autonomyScoreDelta: Float
    let individual: IndividualHealthDetails
    let neighbor: NeighborHealthDetails

    enum CodingKeys: String, CodingKey {
        case autonomyScore = "autonomy_score"
        case autonomyScoreDelta = "autonomy_score_delta"
        case individual, neighbor
    }
}

// MARK: - IndividualHealthDetails
struct IndividualHealthDetails: Codable {
    let symptoms, behaviors: Int
    let symptomsDelta, behaviorsDelta: Float

    enum CodingKeys: String, CodingKey {
        case symptoms
        case symptomsDelta = "symptoms_delta"
        case behaviors
        case behaviorsDelta = "behaviors_delta"
    }
}

// MARK: - NeighborHealthDetails
struct NeighborHealthDetails: Codable {
    let cases, symptoms, behaviors: Int
    let casesDelta, symptomsDelta, behaviorsDelta: Float

    enum CodingKeys: String, CodingKey {
        case cases = "confirm"
        case casesDelta = "confirm_delta"
        case symptoms
        case symptomsDelta = "symptoms_delta"
        case behaviors
        case behaviorsDelta = "behaviors_delta"
    }
}
