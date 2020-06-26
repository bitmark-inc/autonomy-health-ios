//
//  Date+Extension.swift
//  Autonomy
//
//  Created by Thuyen Truong on 6/10/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import Foundation

extension Date {
    func toFormat(_ dateFormat: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = .current
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.string(from: self)
    }
}
