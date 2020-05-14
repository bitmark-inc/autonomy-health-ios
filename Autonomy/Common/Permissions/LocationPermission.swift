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
import GoogleMaps

class LocationPermission {
    static func isEnabled() -> Bool? {
        guard CLLocationManager.locationServicesEnabled() else {
            return false
        }

        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:                            return nil
        case .restricted, .denied:                      return false
        case .authorizedAlways, .authorizedWhenInUse:   return true
        @unknown default:
            return false
        }
    }

    // look up address from coordinate
    static func lookupAddress(from location: CLLocation) -> Single<String?> {
        return Single<String?>.create { (event) -> Disposable in
            GMSGeocoder().reverseGeocodeCoordinate(location.coordinate) { (response, error) in
                if let error = error {
                    event(.error(error))
                    return
                }

                guard let gmsAddress = response?.results()?.first else {
                    event(.error("empty gmsAddress for location: \(location)"))
                    return
                }

                let addressString = gmsAddress.lines?.first
                if addressString == nil || addressString!.isEmpty {
                    Global.log.error("empty gmsAddress for location: \(location)")
                }

                event(.success(addressString))
            }
            return Disposables.create()
        }
    }

    static func askEnableLocationAlert() {
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

        DispatchQueue.main.async {
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
