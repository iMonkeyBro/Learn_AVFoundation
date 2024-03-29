//
//  ImageBufferPreview.swift
//  Learn_AVFoundation
//
//  Created by 刘超群 on 2022/8/11.
//

import UIKit

/**
 使用GLKView 达到预览的效果
 */
class ImageBufferPreview: GLKView {
    /// 需要绘制的image
    var image: CIImage! {
        didSet {
            bindDrawable()
            let cropRect: CGRect = WriteUtil.centerCropImageRect(sourceRect: image.extent, previewRect: drawbleBounds)
            coreImageContext.draw(image, in: drawbleBounds, from: cropRect)
            self.display()
        }
    }
    
    /// 绘制image上下文
    private(set) var coreImageContext: CIContext
    
    /// 绘制范围
    private var drawbleBounds: CGRect = .zero
    
    override init(frame: CGRect) {
        let eaglContext = EAGLContext(api: .openGLES2)!
        coreImageContext = CIContext(eaglContext: eaglContext, options: [CIContextOption.workingColorSpace: nil])
        super.init(frame: frame, context: eaglContext)
        enableSetNeedsDisplay = false
        isOpaque = true
        backgroundColor = .black
        transform = CGAffineTransform(rotationAngle: Double.pi/2)
        self.frame = frame
        bindDrawable()
        drawbleBounds = bounds
        drawbleBounds.size.width = CGFloat(drawableWidth)
        drawbleBounds.size.height = CGFloat(drawableHeight)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        CQLog("ImageBufferPreview-deinit")
    }

}
