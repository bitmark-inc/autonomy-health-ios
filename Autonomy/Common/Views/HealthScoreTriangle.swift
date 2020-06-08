//
//  HealthScoreTriangle.swift
//  Autonomy
//
//  Created by Thuyen Truong on 4/3/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import UIKit
import SwiftSVG

class HealthScoreTriangle: UIView {

    // MARK: - Properties
    fileprivate let itemWidth: CGFloat!
    static let originalSize = CGSize(width: 312, height: 270)
    fileprivate lazy var scale: CGFloat = Self.getScale(from: itemWidth)
    fileprivate lazy var transformScale: CATransform3D = {
         return CATransform3DMakeScale(scale, scale, 0)
    }()

    fileprivate lazy var scoreLabel = makeScoreLabel()
    fileprivate lazy var deltaView = makeDeltaView()
    fileprivate lazy var deltaImageView = makeDeltaImageView()
    fileprivate lazy var deltaLabel = makeDeltaLabel()
    fileprivate var coloredSublayer: CAShapeLayer?
    fileprivate var processingTimer: Timer?

    var currentScore: Int?

    init(score: Int?, width: CGFloat? = nil) {
        self.itemWidth = width ?? (UIScreen.main.bounds.size.width - 30)
        self.currentScore = score
        super.init(frame: CGRect.zero)

        let infillLayer = CAShapeLayer(pathString: backgroundPath)
        infillLayer.fillColor = UIColor(red: 43, green: 43, blue: 43)?.cgColor
        infillLayer.transform = transformScale
        layer.addSublayer(infillLayer)

        if let score = score, score > 0, let coloredSublayer = makeColoredSublayer(for: score) {
            layer.addSublayer(coloredSublayer)
            self.coloredSublayer = coloredSublayer
        }

        addSubview(scoreLabel)
        addSubview(deltaView)
        scoreLabel.transform = CGAffineTransform(scaleX: scale, y: scale)

        scoreLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(42 * scale)
        }

        deltaView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(scoreLabel.snp.bottom).offset(Size.dh(16))
        }

        snp.makeConstraints { (make) in
            make.height.equalTo(Self.originalSize.height * scale)
            make.width.equalTo(itemWidth)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Handlers
    // === Static Helpers ===
    static func getScale(from width: CGFloat) -> CGFloat {
        return width / Self.originalSize.width
    }

    func resetLayout() {
        scoreLabel.setText(nil)
        currentScore = nil
        processingTimer?.invalidate()
        coloredSublayer?.removeFromSuperlayer()
        coloredSublayer = nil
    }

    func updateLayout(score: Float, animate: Bool) {
        let score = Int(score.rounded())
        processingTimer?.invalidate()
        scoreLabel.setText("\(score)")

        guard score != currentScore else { return }

        let step = (score > (currentScore ?? 0)) ? 1 : -1
        var updatingScore = currentScore ?? 0

        processingTimer = Timer.scheduledTimer(withTimeInterval: 0.025, repeats: true) { [weak self] (timer) in
            guard let self = self else { return }

            if animate {
                updatingScore = updatingScore + step
            } else {
                updatingScore = score
            }

            self.coloredSublayer?.removeFromSuperlayer()
            self.coloredSublayer = nil

            if let coloredSublayer = self.makeColoredSublayer(for: updatingScore) {
                self.layer.addSublayer(coloredSublayer)
                self.coloredSublayer = coloredSublayer
            }

            self.currentScore = updatingScore
            if updatingScore == score {
                timer.invalidate()
            }
        }
    }

    fileprivate func makeColoredSublayer(for score: Int) -> CAShapeLayer? {
        guard score > 0 else {
            return nil
        }
        
        let colored = CAShapeLayer(pathString: score <= 100 ? colorPath[score - 1] : colorPath[99])
        let healthColor = HealthRisk(from: score)?.color.cgColor
        colored.fillColor = healthColor
        colored.strokeColor = healthColor
        colored.transform = transformScale

        return colored
    }

    fileprivate let backgroundPath = "M156 0 L156 62.3538 L258 239.023 L54 239.023 L156 62.3538 L156 0 L0 270.2 L312 270.2 Z"
    fileprivate let colorPath = [
        "M156 0 L156 62.3538 L159.0909 67.7074 L160.7273 8.1879 Z",
        "M156 0 L156 62.3538 L162.1818 73.0611 L165.4545 16.3758 Z",
        "M156 0 L156 62.3538 L165.2727 78.4147 L170.1818 24.5636 Z",
        "M156 0 L156 62.3538 L168.3636 83.7683 L174.9091 32.7515 Z",
        "M156 0 L156 62.3538 L171.4546 89.1219 L179.6363 40.9394 Z",
        "M156 0 L156 62.3538 L174.5455 94.4755 L184.3636 49.1273 Z",
        "M156 0 L156 62.3538 L177.6364 99.8291 L189.0909 57.3151 Z",
        "M156 0 L156 62.3538 L180.7273 105.1827 L193.8181 65.503 Z",
        "M156 0 L156 62.3538 L183.8182 110.5364 L198.5454 73.6909 Z",
        "M156 0 L156 62.3538 L186.9091 115.89 L203.2726 81.8788 Z",
        "M156 0 L156 62.3538 L190 121.2436 L207.9999 90.0666 Z",
        "M156 0 L156 62.3538 L193.0909 126.5972 L212.7272 98.2545 Z",
        "M156 0 L156 62.3538 L196.1819 131.9508 L217.4544 106.4424 Z",
        "M156 0 L156 62.3538 L199.2728 137.3044 L222.1817 114.6303 Z",
        "M156 0 L156 62.3538 L202.3637 142.658 L226.909 122.8181 Z",
        "M156 0 L156 62.3538 L205.4546 148.0116 L231.6362 131.006 Z",
        "M156 0 L156 62.3538 L208.5455 153.3652 L236.3635 139.1939 Z",
        "M156 0 L156 62.3538 L211.6364 158.7189 L241.0908 147.3818 Z",
        "M156 0 L156 62.3538 L214.7273 164.0725 L245.818 155.5697 Z",
        "M156 0 L156 62.3538 L217.8182 169.4261 L250.5453 163.7575 Z",
        "M156 0 L156 62.3538 L220.9091 174.7797 L255.2726 171.9454 Z",
        "M156 0 L156 62.3538 L224.0001 180.1333 L259.9998 180.1333 Z",
        "M156 0 L156 62.3538 L227.091 185.4869 L264.7271 188.3212 Z",
        "M156 0 L156 62.3538 L230.1819 190.8405 L269.4543 196.5091 Z",
        "M156 0 L156 62.3538 L233.2728 196.1941 L274.1816 204.6969 Z",
        "M156 0 L156 62.3538 L236.3637 201.5477 L278.9089 212.8848 Z",
        "M156 0 L156 62.3538 L239.4546 206.9013 L283.6361 221.0727 Z",
        "M156 0 L156 62.3538 L242.5455 212.2549 L288.3634 229.2606 Z",
        "M156 0 L156 62.3538 L245.6364 217.6085 L293.0907 237.4485 Z",
        "M156 0 L156 62.3538 L248.7274 222.9621 L297.8179 245.6364 Z",
        "M156 0 L156 62.3538 L251.8183 228.3158 L302.5452 253.8242 Z",
        "M156 0 L156 62.3538 L254.9092 233.6694 L307.2725 262.0121 Z",
        "M156 0 L156 62.3538 L258.0001 239.023 L311.9997 270.2 Z",
        "M156 0 L156 62.3538 L258 239.023 L258 239.023 L312 270.2 L312 270.2 Z",
        "M156 0 L156 62.3538 L258 239.023 L251.8182 239.023 L302.5454 270.2 L312 270.2 Z",
        "M156 0 L156 62.3538 L258 239.023 L245.6364 239.023 L293.0909 270.2 L312 270.2 Z",
        "M156 0 L156 62.3538 L258 239.023 L239.4545 239.023 L283.6363 270.2 L312 270.2 Z",
        "M156 0 L156 62.3538 L258 239.023 L233.2727 239.023 L274.1818 270.2 L312 270.2 Z",
        "M156 0 L156 62.3538 L258 239.023 L227.0909 239.023 L264.7272 270.2 L312 270.2 Z",
        "M156 0 L156 62.3538 L258 239.023 L220.9091 239.023 L255.2727 270.2 L312 270.2 Z",
        "M156 0 L156 62.3538 L258 239.023 L214.7272 239.023 L245.8181 270.2 L312 270.2 Z",
        "M156 0 L156 62.3538 L258 239.023 L208.5454 239.023 L236.3636 270.2 L312 270.2 Z",
        "M156 0 L156 62.3538 L258 239.023 L202.3636 239.023 L226.909 270.2 L312 270.2 Z",
        "M156 0 L156 62.3538 L258 239.023 L196.1818 239.023 L217.4545 270.2 L312 270.2 Z",
        "M156 0 L156 62.3538 L258 239.023 L189.9999 239.023 L207.9999 270.2 L312 270.2 Z",
        "M156 0 L156 62.3538 L258 239.023 L183.8181 239.023 L198.5454 270.2 L312 270.2 Z",
        "M156 0 L156 62.3538 L258 239.023 L177.6363 239.023 L189.0909 270.2 L312 270.2 Z",
        "M156 0 L156 62.3538 L258 239.023 L171.4545 239.023 L179.6363 270.2 L312 270.2 Z",
        "M156 0 L156 62.3538 L258 239.023 L165.2726 239.023 L170.1818 270.2 L312 270.2 Z",
        "M156 0 L156 62.3538 L258 239.023 L159.0908 239.023 L160.7272 270.2 L312 270.2 Z",
        "M156 0 L156 62.3538 L258 239.023 L152.909 239.023 L151.2727 270.2 L312 270.2 Z",
        "M156 0 L156 62.3538 L258 239.023 L146.7272 239.023 L141.8181 270.2 L312 270.2 Z",
        "M156 0 L156 62.3538 L258 239.023 L140.5453 239.023 L132.3636 270.2 L312 270.2 Z",
        "M156 0 L156 62.3538 L258 239.023 L134.3635 239.023 L122.909 270.2 L312 270.2 Z",
        "M156 0 L156 62.3538 L258 239.023 L128.1817 239.023 L113.4545 270.2 L312 270.2 Z",
        "M156 0 L156 62.3538 L258 239.023 L121.9999 239.023 L104 270.2 L312 270.2 Z",
        "M156 0 L156 62.3538 L258 239.023 L115.8181 239.023 L94.5454 270.2 L312 270.2 Z",
        "M156 0 L156 62.3538 L258 239.023 L109.6363 239.023 L85.0909 270.2 L312 270.2 Z",
        "M156 0 L156 62.3538 L258 239.023 L103.4544 239.023 L75.6363 270.2 L312 270.2 Z",
        "M156 0 L156 62.3538 L258 239.023 L97.2726 239.023 L66.1818 270.2 L312 270.2 Z",
        "M156 0 L156 62.3538 L258 239.023 L91.0908 239.023 L56.7272 270.2 L312 270.2 Z",
        "M156 0 L156 62.3538 L258 239.023 L84.909 239.023 L47.2727 270.2 L312 270.2 Z",
        "M156 0 L156 62.3538 L258 239.023 L78.7272 239.023 L37.8181 270.2 L312 270.2 Z",
        "M156 0 L156 62.3538 L258 239.023 L72.5454 239.023 L28.3636 270.2 L312 270.2 Z",
        "M156 0 L156 62.3538 L258 239.023 L66.3635 239.023 L18.9091 270.2 L312 270.2 Z",
        "M156 0 L156 62.3538 L258 239.023 L60.1817 239.023 L9.4545 270.2 L312 270.2 Z",
        "M156 0 L156 62.3538 L258 239.023 L54 239.023 L54 239.023 L0 270.2 L0 270.2 L312 270.2 Z",
        "M156 0 L156 62.3538 L258 239.023 L54 239.023 L57.0909 233.6694 L4.7273 262.0121 L0 270.2 L312 270.2 Z",
        "M156 0 L156 62.3538 L258 239.023 L54 239.023 L60.1818 228.3158 L9.4546 253.8242 L0 270.2 L312 270.2 Z",
        "M156 0 L156 62.3538 L258 239.023 L54 239.023 L63.2727 222.9622 L14.1818 245.6363 L0 270.2 L312 270.2 Z",
        "M156 0 L156 62.3538 L258 239.023 L54 239.023 L66.3636 217.6086 L18.9091 237.4484 L0 270.2 L312 270.2 Z",
        "M156 0 L156 62.3538 L258 239.023 L54 239.023 L69.4546 212.255 L23.6364 229.2606 L0 270.2 L312 270.2 Z",
        "M156 0 L156 62.3538 L258 239.023 L54 239.023 L72.5455 206.9014 L28.3636 221.0727 L0 270.2 L312 270.2 Z",
        "M156 0 L156 62.3538 L258 239.023 L54 239.023 L75.6364 201.5478 L33.0909 212.8848 L0 270.2 L312 270.2 Z",
        "M156 0 L156 62.3538 L258 239.023 L54 239.023 L78.7273 196.1942 L37.8182 204.6969 L0 270.2 L312 270.2 Z",
        "M156 0 L156 62.3538 L258 239.023 L54 239.023 L81.8182 190.8406 L42.5455 196.509 L0 270.2 L312 270.2 Z",
        "M156 0 L156 62.3538 L258 239.023 L54 239.023 L84.9091 185.487 L47.2727 188.3212 L0 270.2 L312 270.2 Z",
        "M156 0 L156 62.3538 L258 239.023 L54 239.023 L88 180.1334 L52 180.1333 L0 270.2 L312 270.2 Z",
        "M156 0 L156 62.3538 L258 239.023 L54 239.023 L91.0909 174.7798 L56.7273 171.9454 L0 270.2 L312 270.2 Z",
        "M156 0 L156 62.3538 L258 239.023 L54 239.023 L94.1818 169.4261 L61.4546 163.7575 L0 270.2 L312 270.2 Z",
        "M156 0 L156 62.3538 L258 239.023 L54 239.023 L97.2728 164.0725 L66.1818 155.5696 L0 270.2 L312 270.2 Z",
        "M156 0 L156 62.3538 L258 239.023 L54 239.023 L100.3637 158.7189 L70.9091 147.3817 L0 270.2 L312 270.2 Z",
        "M156 0 L156 62.3538 L258 239.023 L54 239.023 L103.4546 153.3653 L75.6364 139.1939 L0 270.2 L312 270.2 Z",
        "M156 0 L156 62.3538 L258 239.023 L54 239.023 L106.5455 148.0117 L80.3636 131.006 L0 270.2 L312 270.2 Z",
        "M156 0 L156 62.3538 L258 239.023 L54 239.023 L109.6364 142.6581 L85.0909 122.8181 L0 270.2 L312 270.2 Z",
        "M156 0 L156 62.3538 L258 239.023 L54 239.023 L112.7273 137.3045 L89.8182 114.6302 L0 270.2 L312 270.2 Z",
        "M156 0 L156 62.3538 L258 239.023 L54 239.023 L115.8182 131.9509 L94.5455 106.4424 L0 270.2 L312 270.2 Z",
        "M156 0 L156 62.3538 L258 239.023 L54 239.023 L118.9091 126.5973 L99.2727 98.2545 L0 270.2 L312 270.2 Z",
        "M156 0 L156 62.3538 L258 239.023 L54 239.023 L122.0001 121.2437 L104 90.0666 L0 270.2 L312 270.2 Z",
        "M156 0 L156 62.3538 L258 239.023 L54 239.023 L125.091 115.8901 L108.7273 81.8787 L0 270.2 L312 270.2 Z",
        "M156 0 L156 62.3538 L258 239.023 L54 239.023 L128.1819 110.5364 L113.4545 73.6909 L0 270.2 L312 270.2 Z",
        "M156 0 L156 62.3538 L258 239.023 L54 239.023 L131.2728 105.1828 L118.1818 65.503 L0 270.2 L312 270.2 Z",
        "M156 0 L156 62.3538 L258 239.023 L54 239.023 L134.3637 99.8292 L122.9091 57.3151 L0 270.2 L312 270.2 Z",
        "M156 0 L156 62.3538 L258 239.023 L54 239.023 L137.4546 94.4756 L127.6364 49.1272 L0 270.2 L312 270.2 Z",
        "M156 0 L156 62.3538 L258 239.023 L54 239.023 L140.5455 89.122 L132.3636 40.9394 L0 270.2 L312 270.2 Z",
        "M156 0 L156 62.3538 L258 239.023 L54 239.023 L143.6364 83.7684 L137.0909 32.7515 L0 270.2 L312 270.2 Z",
        "M156 0 L156 62.3538 L258 239.023 L54 239.023 L146.7273 78.4147 L141.8182 24.5636 L0 270.2 L312 270.2 Z",
        "M156 0 L156 62.3538 L258 239.023 L54 239.023 L149.8183 73.0611 L146.5454 16.3757 L0 270.2 L312 270.2 Z",
        "M156 0 L156 62.3538 L258 239.023 L54 239.023 L152.9092 67.7075 L151.2727 8.1878 L0 270.2 L312 270.2 Z",
        "M156 0 L156 62.3538 L258 239.023 L54 239.023 L156 62.3538 L156 0 L0 270.2 L312 270.2 Z",
    ]

    fileprivate func makeScoreLabel() -> Label {
        let label = Label()
        label.apply(
            font: R.font.domaineSansTextLight(size: 64),
            themeStyle: .lightTextColor)
        return label
    }

    fileprivate func makeDeltaView() -> UIView {
        return RowView(items: [
            (deltaImageView, 0),
            (deltaLabel, 2)
        ], trailingConstraint: true)
    }

    fileprivate func makeDeltaImageView() -> UIImageView {
        return UIImageView()
    }

    fileprivate func makeDeltaLabel() -> Label {
        let label = Label()
        label.font = R.font.ibmPlexMonoLight(size: 18)
        return label
    }
}
