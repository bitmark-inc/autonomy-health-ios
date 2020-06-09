//
//  HealthDetection.swift
//  Autonomy
//
//  Created by Thuyen Truong on 6/9/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import Foundation

struct HealthDetection: Codable {
    let guide: [HealthCenter]
    let official: Int
}
