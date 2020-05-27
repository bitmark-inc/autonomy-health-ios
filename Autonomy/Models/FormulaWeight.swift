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

    enum CodingKeys: String, CodingKey {
        case symptoms, behaviors, confirms
    }
}

extension Coefficient: Equatable {
    static func ==(lhs: Coefficient, rhs: Coefficient) -> Bool {
        return lhs.symptoms == rhs.symptoms &&
            lhs.behaviors == rhs.behaviors &&
            lhs.confirms == rhs.confirms
    }
}
