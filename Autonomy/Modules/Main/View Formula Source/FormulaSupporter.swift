//
//  FormulaSupporter.swift
//  Autonomy
//
//  Created by Thuyen Truong on 5/5/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class FormulaSupporter {
    static let coefficientRelay = BehaviorRelay<(actor: UIView?, v: Coefficient)?>(value: nil)
    static var mainCollectionView: UICollectionView?
    static var displayingCell: HealthScoreCollectionCell? {
        return mainCollectionView?.visibleCells.first as? HealthScoreCollectionCell
    }
}
