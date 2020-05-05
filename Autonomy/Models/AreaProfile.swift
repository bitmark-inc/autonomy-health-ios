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

class AreaProfileDetails: Decodable {
    let confirm:   AreaProfileConfirmDetails
    let behaviors: AreaProfileBehaviorsDetails
    let symptoms: AreaProfileSymptomsDetails
}

class AreaProfileConfirmDetails: Decodable {
    let yesterday, today: Int
    let score: Float
}

class AreaProfileBehaviorsDetails: Codable {
    let behaviorTotal, totalPeople, maxScorePerPerson, behaviorCustomizedTotal: Int
    let score: Float

    enum CodingKeys: String, CodingKey {
        case behaviorTotal = "behavior_total"
        case totalPeople = "total_people"
        case maxScorePerPerson = "max_score_per_person"
        case behaviorCustomizedTotal = "behavior_customized_total"
        case score
    }
}

class AreaProfileSymptomsDetails: Decodable {
    let totalWeight, totalPeople, maxWeight, customizedWeight: Int
    let score: Float

    enum CodingKeys: String, CodingKey {
        case totalWeight = "total_weight"
        case totalPeople = "total_people"
        case maxWeight = "max_weight"
        case customizedWeight = "customized_weight"
        case score
    }
}

extension AreaProfile {
    var displayScore: Int {
        return Int(score)
    }
}
