//
//  Date+Formatter.swift
//  Autonomy
//
//  Created by Thuyen Truong on 3/31/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import Foundation
import SwiftDate

extension Date {
    var formatRelative: String {
        return self.toRelative()
    }
}
