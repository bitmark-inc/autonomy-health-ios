//
//  PointOfInterest.swift
//  Autonomy
//
//  Created by Thuyen Truong on 4/13/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import Foundation
import GooglePlaces

struct PointOfInterest: Codable {
    var id: String = ""
    var alias: String
    let location: Location
    var score: Float? = nil

    init(place: GMSPlace) {
        self.alias = place.name ?? ""
        let coordinate = place.coordinate
        self.location = Location(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        alias = try values.decode(String.self, forKey: .alias)
        location = try values.decode(Location.self, forKey: .location)
        score = try values.decode(Float.self, forKey: .score)
    }
}
