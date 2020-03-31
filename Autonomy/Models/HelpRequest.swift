//
//  HelpRequest.swift
//  Autonomy
//
//  Created by Thuyen Truong on 3/30/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import Foundation
import SwiftDate

struct HelpRequest: Codable {
    var id: String?
    var subject: String?
    var exactNeeds: String?
    var meetingLocation: String?
    var contactInfo: String?
    var createdAt: Date?

    var requester: String?
    var helper: String?
    var state: String?

    enum CodingKeys: String, CodingKey {
        case id, requester, helper, subject
        case exactNeeds = "exact_needs"
        case meetingLocation = "meeting_location"
        case contactInfo = "contact_info"
        case state
        case createdAt = "created_at"
    }

    init(from decoder: Decoder) throws {
        let values          = try decoder.container(keyedBy: CodingKeys.self)
        id                  = try values.decode(String?.self, forKey: .id)
        subject             = try values.decode(String?.self, forKey: .subject)
        requester           = try values.decode(String?.self, forKey: .requester)
        helper              = try values.decode(String?.self, forKey: .helper)
        state               = try values.decode(String?.self, forKey: .state)
        exactNeeds          = try values.decode(String?.self, forKey: .exactNeeds)
        meetingLocation     = try values.decode(String?.self, forKey: .meetingLocation)
        contactInfo         = try values.decode(String?.self, forKey: .contactInfo)
        if let createdAtText   = try values.decode(String?.self,   forKey: .createdAt) {
            createdAt = Date(createdAtText)
        }
    }

    init() {

    }
}

enum HelpRequestState: String {
    case pending = "PENDING"
    case responded = "RESPONDED"
}

extension HelpRequest {
    var assistanceKind: AssistanceKind? {
        guard let subject = subject else { return nil }
        return AssistanceKind(rawValue: subject)
    }

    var caseState: HelpRequestState? {
        guard let state = state else { return nil }
        return HelpRequestState(rawValue: state)
    }

    var formattedCreatedAt: String? {
        guard let createdAt = createdAt else { return nil }

        let dateText = createdAt.toRelative(style: Global.customDayGradation)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let timeText = dateFormatter.string(from: createdAt)

        return "\(dateText) - \(timeText)"
    }
}
