//
//  DebugInfoWindowView.swift
//  Autonomy
//
//  Created by Thuyen Truong on 5/4/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import UIKit
import RxSwift
import GoogleMaps

class DebugInfoWindowView: UIView {

    // MARK: - Properties
    lazy var debugInfoLabel = makeTextLabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(debugInfoLabel)
        debugInfoLabel.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
                .inset(UIEdgeInsets(top: 5, left: 8, bottom: 5, right: 8))
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setData(coordinate: CLLocationCoordinate2D, debug: Debug) {
        let text = """
coordinate: (\(coordinate.latitude),\(coordinate.longitude))
score: \(debug.metrics.score)
24h_confirms_count/delta: \(debug.metrics.confirm)/\(debug.metrics.confirmDelta)
24h_symptom_count/delta: \(debug.metrics.symptoms)/\(debug.metrics.symptomsDelta)
24h_behavior_count/delta: \(debug.metrics.behavior)/\(debug.metrics.behaviorDelta)
users_count: \(debug.users)
aqi: \(debug.aqi)
total_symptoms_count: \(debug.symptoms)
"""
        debugInfoLabel.setText(text)
    }
}

extension DebugInfoWindowView {
    fileprivate func makeTextLabel() -> Label {
        let label = Label()
        label.numberOfLines = 0
        label.apply(font: R.font.atlasGroteskLight(size: 13),
                    themeStyle: .lightTextColor, lineHeight: 1.25)
        return label
    }
}
