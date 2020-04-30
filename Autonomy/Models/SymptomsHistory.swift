//
//  SymptomsHistory.swift
//  Autonomy
//
//  Created by Thuyen Truong on 4/29/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct SymptomsHistory: Codable {

    // MARK: - Properties
    let symptoms: [Symptom]
    let location: Location
    let timestamp: Date
}

struct BehaviorsHistory: Codable {

    // MARK: - Properties
    let behaviors: [Behavior]
    let location: Location
    let timestamp: Date
}

struct LocationHistory: Codable {

    // MARK: - Properties
    let location: Location
    let timestamp: Date
}
