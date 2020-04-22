//
//  UIViewController+Error.swift
//  Autonomy
//
//  Created by thuyentruong on 11/12/19.
//  Copyright © 2019 Bitmark Inc. All rights reserved.
//

import UIKit
import Intercom
import SwifterSwift
import Moya

extension UIViewController {
    func showErrorAlert(title: String = R.string.error.generalTitle(), message: String, buttonTitle: String = R.string.localizable.ok()) {
        showAlert(
            title: title, message: message,
            buttonTitles: [buttonTitle])
    }

    func showErrorAlert(message: String) {
        showAlert(
            title: R.string.error.generalTitle(),
            message: message,
            buttonTitles: [R.string.localizable.ok()])
    }

    func showErrorAlertWithSupport(message: String) {
        let supportMessage = R.string.localizable.supportMessage(message)
        let alertController = UIAlertController(
            title: R.string.error.generalTitle(),
            message: supportMessage,
            preferredStyle: .alert)

        let supportButton = UIAlertAction(title: R.string.localizable.contact(), style: .default) { (_) in
            Intercom.presentMessenger()
        }

        alertController.addAction(title: R.string.localizable.cancel(), style: .default, handler: nil)
        alertController.addAction(supportButton)
        alertController.preferredAction = supportButton
        alertController.show()
    }

    func handleErrorIfAsAFError(_ error: Error) -> Bool {
        guard let error = error as? MoyaError else {
            return false
        }

        switch error {
        case .underlying(let error, _):
            guard let error = error.asAFError else { return false }
            switch error {
            case .sessionTaskFailed(let error):
                showErrorAlert(message: error.localizedDescription)
                Global.log.info("[done] handle AFError; show error: \(error.localizedDescription)")
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

struct ErrorAlert {
    static func showErrorAlert(message: String) {
        let alertController = UIAlertController(
            title: R.string.error.generalTitle(),
            message: message,
            preferredStyle: .alert)
        alertController.addAction(title: R.string.localizable.ok(), style: .default, handler: nil)
        alertController.show()
    }

    static func showErrorAlertWithSupport(message: String) {
        let supportMessage = R.string.localizable.supportMessage(message)
        let alertController = UIAlertController(
            title: R.string.error.generalTitle(),
            message: supportMessage,
            preferredStyle: .alert)

        let supportButton = UIAlertAction(title: R.string.localizable.contact(), style: .default) { (_) in
            Intercom.presentMessenger()
        }

        alertController.addAction(title: R.string.localizable.cancel(), style: .default, handler: nil)
        alertController.addAction(supportButton)
        alertController.preferredAction = supportButton
        alertController.show()
    }
}

extension Global {
    static func handleErrorIfAsAFError(_ error: Error) -> Bool {
        guard let error = error as? MoyaError else {
            return false
        }

        switch error {
        case .underlying(let error, _):
            guard let error = error.asAFError else { return false }
            switch error {
            case .sessionTaskFailed(let error):
                Global.log.info("[done] handle silently AFError; show error: \(error.localizedDescription)")
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
