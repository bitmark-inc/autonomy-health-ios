//
//  FormulaView.swift
//  Autonomy
//
//  Created by Thuyen Truong on 5/1/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import UIKit

class FormulaView: UIView {

    // MARK: - Properties
    fileprivate var partViews: [UIView] = []
    fileprivate var rowViews: [UIView] = []
    fileprivate var rows = 0
    fileprivate var marginY: CGFloat = 2
    fileprivate var marginX: CGFloat = 10
    fileprivate var marginXForBracket: CGFloat = 1

    override open var intrinsicContentSize: CGSize {
        return CGSize(width: frame.width, height: currentHeight)
    }

    fileprivate var currentHeight: CGFloat {
        let rowsHeight = rowViews.map { $0.height }.sum()
        var height = CGFloat(rows) * marginY + rowsHeight
        if rows > 0 {
            height -= marginY
        }
        return height
    }

    func addPart(_ part: UIView) {
        partViews.append(part)
    }

    func rearrangeViews() {
        let views = partViews as [UIView] + rowViews
        views.forEach {
            $0.removeFromSuperview()
        }
        rowViews.removeAll(keepingCapacity: true)

        var currentRow = 0
        var currentRowView: UIView?
        var currentRowWidth: CGFloat = 0
        var currentRowHeight: CGFloat = 0
        let frameWidth = frame.width

        for partView in partViews {
            partView.frame.size = partView.intrinsicContentSize

            if currentRowView == nil || currentRowWidth + partView.frame.width > frameWidth {
                currentRow += 1
                currentRowWidth = 0
                currentRowView = UIView(frame: CGRect(x: 0, y: currentHeight, width: 0, height: 0))
                rowViews.append(currentRowView!)
                addSubview(currentRowView!)

                if type(of: partView) != UIView.self {
                     partView.frame.size.width = min(partView.frame.size.width, frameWidth)
                }

                currentRowHeight = max(currentRowHeight, partView.frame.height)
            }

            if let currentRowView = currentRowView {
                partView.frame.origin.x = currentRowWidth
                if let labelFig = partView as? FigLabel, labelFig.label.text == ")" {
                    partView.frame.origin.x -= (marginX - marginXForBracket)
                }

                currentRowView.addSubview(partView)

                if let labelFig = partView as? FigLabel, labelFig.label.text == "(" {
                    currentRowWidth += partView.frame.width + marginXForBracket
                } else {
                    currentRowWidth += partView.frame.width + marginX
                }

                currentRowView.frame.size = CGSize(width: currentRowWidth, height: currentRowHeight)
            }
        }

        rows = currentRow

        invalidateIntrinsicContentSize()
    }
}
