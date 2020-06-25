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
    let symptom, behavior: Int
    let symptomDelta, behaviorDelta: Float

    enum CodingKeys: String, CodingKey {
        case symptom
        case symptomDelta = "symptom_delta"
        case behavior
        case behaviorDelta = "behavior_delta"
    }
}

// MARK: - NeighborHealthDetails
struct NeighborHealthDetails: Codable {
    let activeCase, symptom, behavior: Int
    let activeCaseDelta, symptomDelta, behaviorDelta: Float
    let score, scoreDelta: Float

    enum CodingKeys: String, CodingKey {
        case activeCase = "confirm"
        case activeCaseDelta = "confirm_delta"
        case symptom
        case symptomDelta = "symptom_delta"
        case behavior
        case behaviorDelta = "behavior_delta"
        case score
        case scoreDelta = "score_delta"
    }
}
