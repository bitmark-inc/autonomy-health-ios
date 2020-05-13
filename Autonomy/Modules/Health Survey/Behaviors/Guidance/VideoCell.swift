//
//  VideoCell.swift
//  Autonomy
//
//  Created by Thuyen Truong on 5/13/20.
//  Copyright © 2020 Bitmark Inc. All rights reserved.
//

import UIKit
import RxSwift
import YoutubePlayerView

class VideoCell: TableViewCell {

    // MARK: - Properties
    lazy var titleLabel = makeTitleLabel()
    fileprivate lazy var playVideo = makePlayVideo()
    lazy var thumbnailImageView = makeThumbnailImageView()
    lazy var videoPlayer = makeVideoPlayer()
    lazy var activityIndicator = makeActivityIndicator()
    var videoID: String = ""

    // MARK: - Inits
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = .clear

        let contentView = LinearView(items: [
            (titleLabel, 0),
            (thumbnailImageView, 30)
        ], bottomConstraint: true)

        thumbnailImageView.snp.makeConstraints { (make) in
            make.height.equalTo(194)
        }

        contentView.insertSubview(videoPlayer, at: 0)
        videoPlayer.snp.makeConstraints { (make) in
            make.top.leading.trailing.height.equalTo(thumbnailImageView)
        }

        contentCell.addSubview(contentView)
        contentCell.addSubview(activityIndicator)

        activityIndicator.snp.makeConstraints { (make) in
            make.centerX.centerY.equalTo(thumbnailImageView)
        }

        contentView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        contentCell.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
                .inset(UIEdgeInsets(top: 30, left: 15, bottom: 30, right: 15))
        }
    }

    func setData(title: String, videoID: String) {
        titleLabel.setText(title)
        self.videoID = videoID

        let thumbnailPath = "https://img.youtube.com/vi/\(videoID)/0.jpg"
        thumbnailImageView.loadPhotoMedia(photoPath: thumbnailPath)

        videoPlayer.loadWithVideoId(videoID)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension VideoCell: YoutubePlayerViewDelegate {
    func playerView(_ playerView: YoutubePlayerView, didChangedToState state: YoutubePlayerState) {
        if state != .paused {
            activityIndicator.startAnimating()
            playVideo.isHidden = true
        } else {
            activityIndicator.stopAnimating()
            playVideo.isHidden = false
        }
    }
}

extension VideoCell {
    fileprivate func makeTitleLabel() -> Label {
        let label = Label()
        label.numberOfLines = 0
        label.apply(font: R.font.domaineSansTextLight(size: 18), themeStyle: .lightTextColor)
        return label
    }

    fileprivate func makeThumbnailImageView() -> ImageView {
        let imageView = ImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.addSubview(playVideo)
        playVideo.snp.makeConstraints { (make) in
            make.centerX.centerY.equalToSuperview()
        }

        let tapGestureRecognizer = UITapGestureRecognizer()
        imageView.addGestureRecognizer(tapGestureRecognizer)
        imageView.isUserInteractionEnabled = true
        playVideo.isUserInteractionEnabled = true
        tapGestureRecognizer.rx.event.bind { [weak self] (_) in
            guard let self = self else { return }
            self.videoPlayer.seek(to: 0, allowSeekAhead: true)
            self.videoPlayer.play()
        }.disposed(by: disposeBag)

        return imageView
    }

    fileprivate func makeVideoPlayer() -> YoutubePlayerView {
        let videoPlayer = YoutubePlayerView()
        videoPlayer.delegate = self
        return videoPlayer
    }

    fileprivate func makeActivityIndicator() -> UIActivityIndicatorView {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.style = .whiteLarge
        return activityIndicator
    }

    fileprivate func makePlayVideo() -> ImageView {
        return ImageView(image: R.image.playVideo())
    }
}
