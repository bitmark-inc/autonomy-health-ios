//
//  ViewRecoveryKeyViewController.swift
//  Autonomy
//
//  Created by thuyentruong on 10/21/19.
//  Copyright © 2019 Bitmark Inc. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import UPCarouselFlowLayout

class ViewRecoveryKeyViewController: ViewController, BackNavigator {

    // MARK: - Properties
    fileprivate lazy var screenTitle = makeScreenTitle()
    fileprivate lazy var messageLabel = makeMessageLabel()
    fileprivate lazy var recoveryKeyCollectionView = makeRecoveryKeyCollectionView()
    fileprivate lazy var indexViewLabel = makeIndexViewLabel()
    fileprivate lazy var backButton = makeLightBackItem(withHandler: false)
    fileprivate lazy var groupsButton: UIView = {
        let groupView = ButtonGroupView(button1: backButton)
        groupView.apply(backgroundStyle: .codGrayBackground)
        return groupView
    }()

    fileprivate var recoveryKey = [String]()
    fileprivate var currentViewWordRelay = BehaviorRelay(value: 1)
    fileprivate lazy var thisViewModel: ViewRecoveryKeyViewModel = {
        return viewModel as! ViewRecoveryKeyViewModel
    }()

    fileprivate var pageSize: CGSize {
        let layout = self.recoveryKeyCollectionView.collectionViewLayout as! UPCarouselFlowLayout
        var pageSize = layout.itemSize
        pageSize.width += layout.minimumLineSpacing
        return pageSize
    }

    override func bindViewModel() {
        super.bindViewModel()

        backButton.rx.tap.bind { [weak self] in
            self?.doneViewRecoveryKey()
        }.disposed(by: disposeBag)

        thisViewModel.currentRecoveryKeyRelay
            .subscribe(onNext: { [weak self] in self?.recoveryKey = $0 })
            .disposed(by: disposeBag)

        currentViewWordRelay
            .map { R.string.phrase.recoveryKeyIndex($0) }
            .bind(to: indexViewLabel.rx.text)
            .disposed(by: disposeBag)
    }

    // MARK: - setup views
    override func setupViews() {
        super.setupViews()

        // *** Setup subviews ***
        let paddingContentView = LinearView(
            items: [
                (screenTitle, 0),
                (messageLabel, Size.dh(66)),
        ])

        contentView.addSubview(paddingContentView)
        contentView.addSubview(recoveryKeyCollectionView)
        contentView.addSubview(indexViewLabel)
        contentView.addSubview(groupsButton)

        paddingContentView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(OurTheme.profilePaddingInset)
        }

        recoveryKeyCollectionView.snp.makeConstraints { make in
            make.top.equalTo(paddingContentView.snp.bottom).offset(Size.dh(85))
            make.centerY.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(100)
        }

        indexViewLabel.snp.makeConstraints { make in
            make.top.equalTo(recoveryKeyCollectionView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }

        groupsButton.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
extension ViewRecoveryKeyViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return recoveryKey.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: RecoveryKeyWordCell.self, for: indexPath)
        let word = recoveryKey[indexPath.row]
        cell.setData(word: word)
        return cell
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard let layout = recoveryKeyCollectionView.collectionViewLayout as? UPCarouselFlowLayout else { return }
        let pageSide = (layout.scrollDirection == .horizontal) ? pageSize.width : pageSize.height
        let offset = scrollView.contentOffset.x
        let currentViewIndex = Int(floor((offset - pageSide / 2) / pageSide) + 1)
        currentViewWordRelay.accept(currentViewIndex + 1)
    }
}

extension ViewRecoveryKeyViewController {
    fileprivate func doneViewRecoveryKey() {
        let viewControllers = navigationController?.viewControllers ?? []
        guard let target = viewControllers.first(where: { type(of: $0) == ProfileViewController.self }) else {
            return
        }
        navigator.popToViewController(target: target, animationType: .pageOut(direction: .right))
    }
}

extension ViewRecoveryKeyViewController {
    fileprivate func makeScreenTitle() -> Label {
        let label = Label()
        label.apply(text: R.string.phrase.viewRecoveryKeyTitle(),
                    font: R.font.atlasGroteskLight(size: 24),
                    themeStyle: .lightTextColor)
        return label
    }

    fileprivate func makeMessageLabel() -> Label {
        let label = Label()
        label.numberOfLines = 0
        label.apply(text: R.string.phrase.recoveryKeyMessage(),
                    font: R.font.atlasGroteskLight(size: 18),
                    themeStyle: .lightTextColor, lineHeight: 1.25)
        return label
    }

    fileprivate func makeRecoveryKeyCollectionView() -> UICollectionView {
        let flowlayout = UPCarouselFlowLayout()
        flowlayout.scrollDirection = .horizontal
        flowlayout.itemSize = CGSize(width: 200, height: 64)

        let collectionView = UICollectionView(frame: view.frame, collectionViewLayout: flowlayout)
        collectionView.collectionViewLayout = flowlayout
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.register(cellWithClass: RecoveryKeyWordCell.self)
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }

    fileprivate func makeIndexViewLabel() -> Label {
        let label = Label()
        label.apply(font: R.font.atlasGroteskLight(size: 24),
                    themeStyle: .lightTextColor, lineHeight: 1.25)
        return label
    }
}
