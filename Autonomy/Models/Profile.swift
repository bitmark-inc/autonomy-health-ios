//
//  Profile.swift
//  Autonomy
//
//  Created by thuyentruong on 11/26/19.
//  Copyright © 2019 Bitmark Inc. All rights reserved.
//

import Foundation

struct Profile: Codable {
    let id, accountNumber: String
    let metadata: Metadata
    let createdAt, updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case accountNumber = "account_number"
        case metadata
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct Metadata: Codable {

}

enum RiskLevel: String {
    case high
    case low
}
