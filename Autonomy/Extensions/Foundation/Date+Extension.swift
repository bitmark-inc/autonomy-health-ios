//
//  Date+Extension.swift
//  Autonomy
//
//  Created by Thuyen Truong on 6/10/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import Foundation
import SwiftDate

extension Date {
    func `in`(_ locale: Locales) -> DateInRegion {
        let defaultRegion = SwiftDate.defaultRegion
        let newRegion = Region(calendar: defaultRegion.calendar, zone: defaultRegion.timeZone, locale: Locales.english)

        return date.in(region: newRegion)
    }

    var appTimeFormat: Int {
        return Int(self.timeIntervalSince1970)
    }
}
