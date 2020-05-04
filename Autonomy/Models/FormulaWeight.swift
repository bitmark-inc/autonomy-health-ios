//
//  FormulaWeight.swift
//  Autonomy
//
//  Created by Thuyen Truong on 5/4/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import Foundation

class FormulaWeight: Decodable {
    let coefficient: Coefficient
    let isDefault: Bool

    enum CodingKeys: String, CodingKey {
        case coefficient
        case isDefault = "is_default"
    }
}

class Coefficient: Decodable {
    var symptoms: Float
    var behaviors: Float
    var confirms: Float

    var symptomWeights: [SymptomWeight]

    enum CodingKeys: String, CodingKey {
        case symptoms, behaviors, confirms
        case symptomWeights = "symptom_weights"
    }
}

class SymptomWeight: Decodable {
    let symptom: Symptom
    var weight: Int
}
