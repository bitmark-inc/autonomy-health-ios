//
//  Error+Supporter.swift
//  Autonomy
//
//  Created by Thuyen Truong on 5/18/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import Foundation
import Moya

extension Error {
    var isTransient: Bool {
        guard let error = self as? MoyaError else {
            return false
        }

        switch error {
        case .underlying(let error, _):
            guard let error = error.asAFError else { return false }
            switch error {
            case .sessionTaskFailed(let error):

                // TODO: temporary fix
                if error.localizedDescription.contains("HTTP") {
                    Global.log.error(error)
                    return false
                }

                return true

            default:
                break
            }
        default:
            break
        }

        return false
    }
}
