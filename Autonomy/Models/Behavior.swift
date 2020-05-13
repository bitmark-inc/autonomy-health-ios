//
//  Behavior.swift
//  Autonomy
//
//  Created by Thuyen Truong on 4/15/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import Foundation

struct Behavior: Codable {
    let id, name: String
}

struct BehaviorList: Decodable {
    let officialBehaviors: [Behavior]
    let neighborhoodBehaviors: [Behavior]

    enum CodingKeys: String, CodingKey {
        case officialBehaviors = "official_behaviors"
        case neighborhoodBehaviors = "neighborhood_behaviors"
    }

    init(from decoder: Decoder) throws {
        let values              = try decoder.container(keyedBy: CodingKeys.self)
        officialBehaviors       = try values.decode([Behavior].self, forKey: .officialBehaviors)
        neighborhoodBehaviors   = try values.decodeIfPresent([Behavior].self, forKey: .neighborhoodBehaviors) ?? []
    }
}

struct BehaviorFullList: Decodable {
    let officialBehaviors: [Behavior]
    let customizedBehaviors: [Behavior]

    enum CodingKeys: String, CodingKey {
        case officialBehaviors = "official_behaviors"
        case customizedBehaviors = "customized_behaviors"
    }

    init(from decoder: Decoder) throws {
        let values           = try decoder.container(keyedBy: CodingKeys.self)
        officialBehaviors    = try values.decode([Behavior].self, forKey: .officialBehaviors)
        customizedBehaviors  = try values.decodeIfPresent([Behavior].self, forKey: .customizedBehaviors) ?? []
    }
}
