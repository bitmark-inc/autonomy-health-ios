//
//  PlaceHealthDetailsViewModel.swift
//  Autonomy
//
//  Created by Thuyen Truong on 6/5/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import RxSwift
import RxCocoa

class PlaceHealthDetailsViewModel: ViewModel {

    let poiID: String!

    init(poiID: String) {
        self.poiID = poiID
        super.init()
    }
}
