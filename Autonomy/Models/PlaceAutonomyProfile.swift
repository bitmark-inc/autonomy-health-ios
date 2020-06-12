//
//  PlaceAutonomyProfile.swift
//  Autonomy
//
//  Created by Thuyen Truong on 6/10/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import Foundation

struct PlaceAutonomyProfile: Codable {
    let id, alias, address: String
    let rating: Bool
    let hasMoreResources: Bool
    let resourceReportItems: [ResourceReportItem]
    let neighbor: NeighborHealthDetails
    let autonomyScore, autonomyScoreDelta: Float

    enum CodingKeys: String, CodingKey {
        case id, alias, address, rating, neighbor
        case hasMoreResources = "has_more_resources"
        case resourceReportItems = "resources"
        case autonomyScore = "autonomy_score"
        case autonomyScoreDelta = "autonomy_score_delta"
    }
}

// MARK: - Resource
struct ResourceReportItem: Codable {
    let name: String
    let score: Float
    let ratings: Float
}
