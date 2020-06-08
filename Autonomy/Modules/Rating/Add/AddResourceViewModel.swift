//
//  AddResourceViewModel.swift
//  Autonomy
//
//  Created by Thuyen Truong on 6/8/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import RxSwift
import RxCocoa

class AddResourceViewModel: ViewModel {

    // MARK: - Properties
    let poiID: String!

    init(poiID: String) {
        self.poiID = poiID
        super.init()
    }
}
