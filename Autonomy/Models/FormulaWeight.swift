//
//  FormulaWeight.swift
//  Autonomy
//
//  Created by Thuyen Truong on 5/4/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import Foundation

struct FormulaWeight: Decodable {
    let coefficient: Coefficient
    let isDefault: Bool

    enum CodingKeys: String, CodingKey {
        case coefficient
        case isDefault = "is_default"
    }
}

struct Coefficient: Decodable {
    var symptoms: Float
    var behaviors: Float
    var confirms: Float

    var symptomWeights: [SymptomWeight]
    var symptomKeyWeights: [String: Int]

    enum CodingKeys: String, CodingKey {
        case symptoms, behaviors, confirms
        case symptomWeights = "symptom_weights"
    }

    init(from decoder: Decoder) throws {
        let values      = try decoder.container(keyedBy: CodingKeys.self)
        symptoms        = try values.decode(Float.self, forKey: .symptoms)
        behaviors       = try values.decode(Float.self, forKey: .behaviors)
        confirms        = try values.decode(Float.self, forKey: .confirms)
        symptomWeights  = try values.decode([SymptomWeight].self, forKey: .symptomWeights)
        symptomKeyWeights = [:]
        symptomWeights.forEach {
            symptomKeyWeights[$0.symptom.id] = $0.weight
        }
    }
}

struct SymptomWeight: Decodable {
    let symptom: Symptom
    var weight: Int
}

extension Coefficient: Equatable {
    static func ==(lhs: Coefficient, rhs: Coefficient) -> Bool {
        var symptomWeightsEqual: Bool = true
        let rhsSymptomKeyWeights = rhs.symptomKeyWeights
        for (key, lhsWeight) in lhs.symptomKeyWeights {
            let rhsWeight = rhsSymptomKeyWeights[key]

            if lhsWeight != rhsWeight {
                symptomWeightsEqual = false
                break
            }
        }

        return symptomWeightsEqual &&
            lhs.symptoms == rhs.symptoms &&
            lhs.behaviors == rhs.behaviors &&
            lhs.confirms == rhs.confirms
    }
}
