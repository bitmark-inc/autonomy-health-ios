//
//  DebugLocationViewController.swift
//  Autonomy
//
//  Created by Thuyen Truong on 4/10/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import GoogleMaps

class DebugLocationViewController: ViewController, GMSMapViewDelegate {

    // MARK: - Properties
    lazy var mapView = makeMapView()
    lazy var navButtonGroup = makeNavButtonGroup()
    lazy var closeButton = makeCloseButton()
    lazy var backButton = makeBackButton()
    lazy var nextButton = makeNextButton()

    lazy var thisViewModel: DebugLocationViewModel = {
        return viewModel as! DebugLocationViewModel
    }()
    var markers: [String?: GMSMarker] = [:]
    var currentFocus = 0

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func bindViewModel() {
        super.bindViewModel()

        thisViewModel.debugsRelay
            .subscribe(onNext: { [weak self] (debugs) in
                guard let self = self else { return }
                for (poiID, debugInfo) in debugs {
                    self.buildMarkerWithInfo(poiID: poiID, debug: debugInfo)
                }
            })
            .disposed(by: disposeBag)
    }

    func buildMarkerWithInfo(poiID: String?, debug: Debug) {
        guard let coordinate = getCoordinate(of: poiID) else { return }
        let marker = pinMaker(in: coordinate)
        markers[poiID] = marker

        if poiID == nil { // default focus in current Location
            focusMarker(marker: marker)
        }
    }

    fileprivate func getCoordinate(of poiID: String?) -> CLLocationCoordinate2D? {
        if let poiID = poiID {
            guard let poi = thisViewModel.pois.first(where: { $0.id == poiID }) else { return nil }
            return CLLocationCoordinate2D(
                latitude: poi.location.latitude, longitude: poi.location.longitude)

        } else {
            return Global.current.userLocationRelay.value?.coordinate
        }
    }

    fileprivate func pinMaker(in coordinate: CLLocationCoordinate2D) -> GMSMarker {
        let marker = GMSMarker(position: coordinate)
        marker.map = mapView

        let circle = GMSCircle(position: coordinate, radius: 1000)
        circle.fillColor = UIColor(red: 0.0, green: 0.7, blue: 0, alpha: 0.1)
        circle.strokeColor = UIColor(red: 255/255, green: 153/255, blue: 51/255, alpha: 0.5)
        circle.strokeWidth = 2.5;
        circle.map = mapView;
        return marker
    }

    fileprivate func focusMarker(marker: GMSMarker) {
        let camera = GMSCameraPosition.camera(withTarget: marker.position, zoom: 14)
        mapView.camera = camera
        mapView.selectedMarker = marker
    }

    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        let infoWindow = DebugInfoWindowView(frame: CGRect(x: 0, y: 0, width: 300, height: 170))
        infoWindow.backgroundColor = UIColor(hexString: "#828180")!

        let poiID = markers.keys(forValue: marker).first ?? nil

        guard let coordinate = getCoordinate(of: poiID),
            let debug = thisViewModel.debugsRelay.value[poiID] else {
                return nil
        }

        infoWindow.setData(coordinate: coordinate, debug: debug)
        return infoWindow
    }

    override func setupViews() {
        super.setupViews()

        view.addSubview(mapView)
        view.addSubview(navButtonGroup)
        view.addSubview(closeButton)

        mapView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        closeButton.snp.makeConstraints { (make) in
            make.top.trailing.equalTo(view.safeAreaLayoutGuide)
                .inset(UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 15))
        }

        navButtonGroup.snp.makeConstraints { (make) in
            make.trailing.bottom.equalTo(view.safeAreaLayoutGuide).offset(-35)
        }
    }
}

extension DebugLocationViewController {
    fileprivate func makeMapView() -> GMSMapView {
        let mapView = GMSMapView()
        mapView.delegate = self
        return mapView
    }

    fileprivate func makeNavButtonGroup() -> UIView {
        let view = UIView()
        view.addSubview(backButton)
        view.addSubview(nextButton)

        backButton.snp.makeConstraints { (make) in
            make.top.leading.bottom.equalToSuperview()
                .inset(UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
        }

        nextButton.snp.makeConstraints { (make) in
            make.leading.equalTo(backButton.snp.trailing).offset(25)
            make.top.bottom.equalTo(backButton)
            make.trailing.equalToSuperview().offset(-5)
        }

        themeService.rx
            .bind({ $0.silverColor }, to: view.rx.backgroundColor)
            .disposed(by: disposeBag)

        return view
    }

    fileprivate func makeBackButton() -> UIButton {
        let button = UIButton()
        button.setImage(R.image.backCircleArrow(), for: .normal)
        button.rx.tap.bind { [weak self] in
            guard let self = self else { return }
            var currentFocus = self.currentFocus - 1
            if currentFocus < 0 {
                currentFocus = self.thisViewModel.poiIDs.count - 1
            }

            let poiID = self.thisViewModel.poiIDs[currentFocus]

            guard let marker = self.markers[poiID] else { return }
            self.currentFocus = currentFocus
            self.focusMarker(marker: marker)

        }.disposed(by: disposeBag)
        return button
    }

    fileprivate func makeNextButton() -> UIButton {
        let button = UIButton()
        button.setImage(R.image.nextCircleArrow(), for: .normal)
        button.rx.tap.bind { [weak self] in
            guard let self = self else { return }
            var currentFocus = self.currentFocus + 1
            if currentFocus >= self.thisViewModel.poiIDs.count {
                currentFocus = 0
            }

            let poiID = self.thisViewModel.poiIDs[currentFocus]

            guard let marker = self.markers[poiID] else { return }
            self.currentFocus = currentFocus
            self.focusMarker(marker: marker)

        }.disposed(by: disposeBag)
        return button
    }

    fileprivate func makeCloseButton() -> UIButton {
        let button = UIButton()
        button.setImage(R.image.concordPlusCircle(), for: .normal)
        button.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 4)
        button.rx.tap.bind { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }.disposed(by: disposeBag)
        return button
    }
}
