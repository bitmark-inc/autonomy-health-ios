//
//  SurveyMetrics.swift
//  Autonomy
//
//  Created by Thuyen Truong on 5/13/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import Foundation

struct SurveyMetrics: Decodable {
    let me: [String: Float]
    let community: [String: Float]
}
