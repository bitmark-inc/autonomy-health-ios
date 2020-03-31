//
//  AssistanceAskInfoViewModel.swift
//  Autonomy
//
//  Created by Thuyen Truong on 3/30/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import RxSwift
import RxCocoa

enum AssistanceInfoType: CaseIterable {
    case exactNeeds
    case meetingLocation
    case contactInfo

    var title: String {
        switch self {
        case .exactNeeds:       return R.string.phrase.assistanceInfoExactNeeds()
        case .meetingLocation:  return R.string.phrase.assistanceInfoMeetingLocation()
        case .contactInfo:      return R.string.phrase.assistanceInfoContactInfo()
        }
    }
}

class AssistanceAskInfoViewModel: ViewModel {

    // MARK: - Properties
    let assistanceInfoType: AssistanceInfoType!
    let helpRequest: HelpRequest!

    // MARK: - Input
    let infoTextRelay = BehaviorRelay<String>(value: "")

    init(assistanceInfoType: AssistanceInfoType, helpRequest: HelpRequest) {
        self.assistanceInfoType = assistanceInfoType
        self.helpRequest = helpRequest
        super.init()
    }
}
