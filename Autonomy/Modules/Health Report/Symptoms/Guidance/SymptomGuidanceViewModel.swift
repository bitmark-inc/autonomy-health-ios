//
//  SymptomGuidanceViewModel.swift
//  Autonomy
//
//  Created by Thuyen Truong on 6/8/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import RxSwift
import RxCocoa

class SymptomGuidanceViewModel: ViewModel {
    let healthCenters: [HealthCenter]!

    init(healthCenters: [HealthCenter]) {
        self.healthCenters = healthCenters
        super.init()
    }
}
