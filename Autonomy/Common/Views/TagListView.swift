//
//  TagListView.swift
//  Autonomy
//
//  Created by Thuyen Truong on 5/11/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SkeletonView

class TagListView: UIView {

    // MARK: - Properties
    var tagViews: [TagView] = []
    fileprivate var rowViews: [UIView] = []
    fileprivate var rows = 0
    fileprivate var marginY: CGFloat = 15
    fileprivate var marginX: CGFloat = 15

    override open var intrinsicContentSize: CGSize {
        return CGSize(width: frame.width, height: currentHeight)
    }

    fileprivate var currentHeight: CGFloat {
        if rows == 0 {
            return 0
        }
        let rowsHeight = rowViews.map { $0.height }.sum()
        return CGFloat(rows) * marginY + rowsHeight - marginY
    }

    func reset() {
        tagViews.forEach { $0.removeFromSuperview() }
        rowViews.removeAll(keepingCapacity: true)

        tagViews = []
        rowViews = []
        rows = 0
    }

    func addTag(_ tag: (id: String, value: String)) -> TagView {
        let newTagView = TagView(id: tag.id, title: tag.value)
        tagViews.append(newTagView)
        return newTagView
    }

    func addTags(_ tags: [(id: String, value: String)]) {
        tags.forEach { _ = addTag($0) }
    }

    func rearrangeViews() {
        let views = tagViews + rowViews
        views.forEach {
            $0.removeFromSuperview()
        }
        rowViews.removeAll(keepingCapacity: true)
        rows = 0

        var currentRow = 0
        var currentRowView: UIView?
        var currentRowWidth: CGFloat = 0
        var currentRowHeight: CGFloat = 0
        let frameWidth = frame.width

        for tagView in tagViews {
            tagView.frame.size = tagView.intrinsicContentSize

            if currentRowView == nil || currentRowWidth + tagView.frame.width > frameWidth {
                currentRow += 1
                currentRowView = UIView()
                currentRowWidth = 0

                currentRowView!.frame.origin.y = currentRow == 1 ? 0 : (currentHeight + marginY)

                rowViews.append(currentRowView!)
                addSubview(currentRowView!)

                currentRowHeight = max(currentRowHeight, tagView.frame.height)
                rows += 1
            }

            if let currentRowView = currentRowView {
                tagView.frame.origin.x = currentRowWidth
                currentRowView.addSubview(tagView)
                currentRowWidth += tagView.frame.width + marginX
                currentRowView.frame.size = CGSize(width: currentRowWidth, height: currentRowHeight)
            }
        }
        invalidateIntrinsicContentSize()
    }
}

class TagView: UIView {

    // MARK: - Properties
    let id: String!

    fileprivate lazy var titleLabel = makeTitleLabel()
    fileprivate let title: String!
    fileprivate let disposeBag = DisposeBag()

    let isSelectedRelay = BehaviorRelay<Bool>(value: false)

    var isSelected: Bool = false {
        didSet {
            backgroundColor = isSelected ? UIColor(hexString: "#0060F2") : UIColor(hexString: "#282B32")
            isSelectedRelay.accept(isSelected)
        }
    }

    override var intrinsicContentSize: CGSize {
        var contentSize = titleLabel.intrinsicContentSize
        contentSize.height += 12; contentSize.width += 12
        return contentSize
    }

    // MARK: - Init
    init(id: String, title: String) {
        self.id = id
        self.title = title
        super.init(frame: .zero)

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
                .inset(UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6))
        }

        isSelected = false
        backgroundColor = UIColor(hexString: "#282B32")
        addGestureRecognizer(makeTapGestureRecognizer())
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func makeTitleLabel() -> Label {
        let label = Label()
        label.apply(text: title, font: R.font.atlasGroteskLight(size: 14),
                    themeStyle: .lightTextColor)
        return label
    }

    fileprivate func makeTapGestureRecognizer() -> UITapGestureRecognizer {
        let tapGestureRecognizer = UITapGestureRecognizer()
        isUserInteractionEnabled = true
        tapGestureRecognizer.rx.event.bind { [weak self] (_) in
            guard let self = self else { return }
            self.isSelected = !self.isSelected
        }.disposed(by: disposeBag)
        return tapGestureRecognizer
    }
}


