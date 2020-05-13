//
//  ImageView.swift
//  Autonomy
//
//  Created by thuyentruong on 11/12/19.
//  Copyright © 2019 Bitmark Inc. All rights reserved.
//

import UIKit
import Kingfisher

class ImageView: UIImageView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    override init(image: UIImage?) {
        super.init(image: image)
        setupViews()
    }

    override init(image: UIImage?, highlightedImage: UIImage?) {
        super.init(image: image, highlightedImage: highlightedImage)
        setupViews()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }

    func setupViews() {
        contentMode = .scaleAspectFit
        layer.masksToBounds = true
    }

    func loadPhotoMedia(photoPath: String) {
        guard let photoURL = URL(string: photoPath) else {
            Global.log.error("invalid photo URL: \(photoPath)")
            return
        }

        let imageResource = ImageResource(downloadURL: photoURL)
        kf.setImage(with: imageResource) { (result) in
            switch result {
            case .success(_):
                break
            case .failure(let error):
                Global.log.debug(error)
            }
        }
    }
}
