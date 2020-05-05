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

    enum CodingKeys: String, CodingKey {
        case symptoms, behaviors, confirms
        case symptomWeights = "symptom_weights"
    }
}

struct SymptomWeight: Decodable {
    let symptom: Symptom
    var weight: Int
}

extension Coefficient: Equatable {
    static func ==(lhs: Coefficient, rhs: Coefficient) -> Bool {
        var symptomWeightsEqual: Bool = true
        for lhsSymptomWeight in lhs.symptomWeights {
            guard let rhsSymptomWeight = rhs.symptomWeights.first(where: { $0.symptom.id == lhsSymptomWeight.symptom.id }) else {
                symptomWeightsEqual = false
                break
            }

            if lhsSymptomWeight.weight != rhsSymptomWeight.weight {
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
