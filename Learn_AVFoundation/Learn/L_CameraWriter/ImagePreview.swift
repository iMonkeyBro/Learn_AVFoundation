//
//  ImagePreview.swift
//  Learn_AVFoundation
//
//  Created by 刘超群 on 2022/10/4.
//

import Foundation
import UIKit

/// 利用UIImageView预览
class ImagePreview: UIImageView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentMode = .scaleAspectFill
        transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
    }
    
    override init(image: UIImage?) {
        super.init(image: image)
        contentMode = .scaleAspectFill
        transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
    }
    
    override init(image: UIImage?, highlightedImage: UIImage?) {
        super.init(image: image, highlightedImage: highlightedImage)
        contentMode = .scaleAspectFill
        transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
