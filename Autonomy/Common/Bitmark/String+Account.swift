//
//  String+Account.swift
//  Autonomy
//
//  Created by Thuyen Truong on 6/17/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import Foundation

extension String {

    func toRecoveryPhrases() -> [String] {
        return split(separator: " ").map(String.init).filter { $0.isNotEmpty }
    }
}
