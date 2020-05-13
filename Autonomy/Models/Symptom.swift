//
//  Symptom.swift
//  Autonomy
//
//  Created by Thuyen Truong on 3/31/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import Foundation

struct Symptom: Codable {
    let id, name: String
}

struct SymptomList: Decodable {
    let officialSymptoms: [Symptom]
    let neighborhoodSymptoms: [Symptom]

    enum CodingKeys: String, CodingKey {
        case officialSymptoms = "official_symptoms"
        case neighborhoodSymptoms = "neighborhood_symptoms"
    }

    init(from decoder: Decoder) throws {
        let values          = try decoder.container(keyedBy: CodingKeys.self)
        officialSymptoms    = try values.decode([Symptom].self, forKey: .officialSymptoms)
        neighborhoodSymptoms    = try values.decodeIfPresent([Symptom].self, forKey: .neighborhoodSymptoms) ?? []
    }
}

struct SymptomFullList: Decodable {
    let officialSymptoms: [Symptom]
    let customizedSymptoms: [Symptom]
    let suggestedSymptoms: [Symptom]

    enum CodingKeys: String, CodingKey {
        case officialSymptoms = "official_symptoms"
        case customizedSymptoms = "customized_symptoms"
        case suggestedSymptoms = "suggested_symptoms"
    }

    init(from decoder: Decoder) throws {
        let values          = try decoder.container(keyedBy: CodingKeys.self)
        officialSymptoms    = try values.decode([Symptom].self, forKey: .officialSymptoms)
        customizedSymptoms    = try values.decodeIfPresent([Symptom].self, forKey: .customizedSymptoms) ?? []
        suggestedSymptoms    = try values.decodeIfPresent([Symptom].self, forKey: .suggestedSymptoms) ?? []
    }
}
