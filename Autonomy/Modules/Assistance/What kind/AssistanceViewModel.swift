//
//  AssistanceViewModel.swift
//  Autonomy
//
//  Created by Thuyen Truong on 3/30/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import RxSwift
import RxCocoa

class AssistanceViewModel: ViewModel {

    // MARK: - Input
    // MARK: - Output


}

enum AssistanceKind: String, CaseIterable {
    case foodAndWater = "food"
    case medicine = "medicine"
    case transport = "medical_care"
    case unsafeHome = "safe_location"

    var title: String {
        switch self {
        case .foodAndWater: return R.string.phrase.assistanceFoodAndWater()
        case .medicine:     return R.string.phrase.assistanceMedicine()
        case .transport:    return R.string.phrase.assistanceTransport()
        case .unsafeHome:   return R.string.phrase.assistanceUnsafeHome()
        }
    }

    var description: String {
        switch self {
        case .foodAndWater: return R.string.phrase.assistanceFoodAndWaterDesc()
        case .medicine:     return R.string.phrase.assistanceMedicineDesc()
        case .transport:    return R.string.phrase.assistanceTransportDesc()
        case .unsafeHome:   return R.string.phrase.assistanceUnsafeHomeDesc()
        }
    }

    var requestTitle: String {
        switch self {
        case .foodAndWater: return R.string.phrase.assistanceFoodAndWaterRequestTitle()
        case .medicine:     return R.string.phrase.assistanceMedicineRequestTitle()
        case .transport:    return R.string.phrase.assistanceTransportRequestTitle()
        case .unsafeHome:   return R.string.phrase.assistanceUnsafeHomeRequestTitle()
        }
    }
}
