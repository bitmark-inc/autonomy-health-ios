//
//  LocationPermission.swift
//  Autonomy
//
//  Created by Thuyen Truong on 3/27/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import UIKit
import RxSwift
import CoreLocation

class LocationPermission {
    static func isEnabled() -> Bool? {
        guard CLLocationManager.locationServicesEnabled() else {
            return false
        }

        return isEnabled(with: CLLocationManager.authorizationStatus())
    }

    static func isEnabled(with authorizationStatus: CLAuthorizationStatus) -> Bool? {
        switch authorizationStatus {
        case .notDetermined:                            return nil
        case .restricted, .denied:                      return false
        case .authorizedAlways, .authorizedWhenInUse:   return true
        @unknown default:
            return false
        }
    }

    static func askEnableLocationAlert() {
        DispatchQueue.main.async {
            let alertController = UIAlertController(
                title: R.string.error.locationTitle(),
                message: R.string.error.locationMessage(),
                preferredStyle: .alert)

            let cancelAction = UIAlertAction(
                title: R.string.localizable.cancel(),
                style: .cancel, handler: nil)

            let enableAction = UIAlertAction(
                title: R.string.localizable.enable(),
                style: .default, handler: self.openAppSettings)

            alertController.addAction(cancelAction)
            alertController.addAction(enableAction)
            alertController.preferredAction = enableAction

            alertController.show()
        }
    }

    @objc static func openAppSettings(_ sender: UIAlertAction) {
        guard let url = URL(string: UIApplication.openSettingsURLString) else {
            return
        }

        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
