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
            let clGeocoder = CLGeocoder()

            clGeocoder.reverseGeocodeLocation(location) { (placemarks, error) in
                if let error = error {
                    event(.error(error))
                    return
                }

                guard let placemark = placemarks?.first else {
                    event(.error("empty placemarks for location: \(location)"))
                    return
                }

                var subThoroughfare = ""
                var thoroughfare = ""

                if let text = placemark.subThoroughfare { subThoroughfare = text }
                if let text = placemark.thoroughfare { thoroughfare = " \(text)" }

                var address = "\(subThoroughfare)\(thoroughfare)"

                if address.isEmpty {
                    var name = ""
                    var subLocality = ""
                    var locality = ""

                    if let text = placemark.name { name = text }
                    if let text = placemark.subLocality { subLocality = " \(text)" }
                    if let text = placemark.locality { locality = " \(text)" }

                    address = "\(name)\(subLocality)\(locality)"
                }

                if address.isEmpty {
                    address = (placemark.name ?? placemark.country) ?? ""
                }

                event(.success(address))
            }
            return Disposables.create()
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
