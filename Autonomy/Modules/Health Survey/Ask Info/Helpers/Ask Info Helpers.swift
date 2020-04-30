//
//  Ask Info Helper.swift
//  Autonomy
//
//  Created by Thuyen Truong on 4/30/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import Foundation

enum AskInfoType: CaseIterable {
    case symptomTitle
    case symptomDesc
    case behaviorTitle
    case behaviorDesc
}

struct Survey {
    var name: String = ""
    var desc: String = ""
}
