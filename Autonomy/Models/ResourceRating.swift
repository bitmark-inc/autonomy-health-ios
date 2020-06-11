//
//  ResourceRating.swift
//  Autonomy
//
//  Created by Thuyen Truong on 6/11/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import Foundation

struct ResourceRating: Codable {
    let resource: Resource
    let score: Int
}
