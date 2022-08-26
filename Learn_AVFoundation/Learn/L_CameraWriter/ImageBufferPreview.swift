//
//  ImageBufferPreview.swift
//  Learn_AVFoundation
//
//  Created by 刘超群 on 2022/8/11.
//

import UIKit

let FilterSelectionChangedNotification: NSNotification.Name? = NSNotification.Name(rawValue: "filter_selection_changed")


func centerCropImageRect(sourceRect: CGRect, previewRect: CGRect) -> CGRect {
    let sourceAspectRatio: CGFloat = sourceRect.size.width/sourceRect.size.height
    let previewAspectRatio: CGFloat = previewRect.size.width/previewRect.size.height
    var drawRect = sourceRect
    if sourceAspectRatio>previewAspectRatio {
        let scaledHeight = drawRect.size.height*previewAspectRatio
        drawRect.origin.x += (drawRect.self.width-scaledHeight)/2
        drawRect.size.width = scaledHeight
    } else {
        drawRect.origin.y += (drawRect.size.height-drawRect.size.width/previewAspectRatio)/2
        drawRect.size.height = drawRect.size.width/previewAspectRatio
    }
    return drawRect
}

func transform(for deviceOrientation: UIDeviceOrientation) -> CGAffineTransform {
    let result: CGAffineTransform
    switch deviceOrientation {
    case .landscapeRight:
        result = CGAffineTransform(rotationAngle: Double.pi)
    case .portraitUpsideDown:
        result = CGAffineTransform(rotationAngle: Double.pi/2*3)
    case .portrait, .faceUp, .faceDown:
        result = CGAffineTransform(rotationAngle: Double.pi/2)
    case .unknown, .landscapeLeft:
        result = CGAffineTransform.identity
    @unknown default:
        result = CGAffineTransform.identity
    }
    return result
}

/**
 使用GLKView 达到预览的效果
 */
class ImageBufferPreview: GLKView {
    
    var image: CIImage?{
        didSet {
            bindDrawable()
            filter = PhotoFilters.filters.first!
            filter?.setValue(oldValue, forKey: kCIInputImageKey)
            let filteredImage = filter?.outputImage
            if let `filteredImage` = filteredImage {
                let cropRect: CGRect = centerCropImageRect(sourceRect: oldValue!.extent, previewRect: drawbleBounds)
                coreImageContext?.draw(filteredImage, in: drawbleBounds, from: cropRect)
            }
            self.display()
            filter?.setValue(nil, forKey: kCIInputImageKey)
        }
    }
    
    var filter: CIFilter?
    var coreImageContext: CIContext?
    private var drawbleBounds: CGRect
    
    override init(frame: CGRect, context: EAGLContext) {
        drawbleBounds = .zero
        super.init(frame: frame, context: context)
        
        enableSetNeedsDisplay = false
        isOpaque = true
        backgroundColor = .black
        transform = CGAffineTransform(rotationAngle: Double.pi/2)
        self.frame = frame
        bindDrawable()
        drawbleBounds = bounds
        drawbleBounds.size.width = CGFloat(drawableWidth)
        drawbleBounds.size.height = CGFloat(drawableHeight)
        NotificationCenter.default.addObserver(self, selector: #selector(filterChanged), name: FilterSelectionChangedNotification, object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func filterChanged(_ notification: NSNotification) {
        filter = notification.object as? CIFilter
    }
}
