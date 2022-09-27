//
//  WriteUtil.swift
//  Learn_AVFoundation
//
//  Created by 刘超群 on 2022/9/27.
//

import Foundation

struct WriteUtil {
    /**
     根据原始图像Rect和预览Rect裁剪
     - parameter sourceRect: 原始图像Rect
     - parameter previewRect: 预览Rect
     - returns: 裁剪后Rect
     */
    static func centerCropImageRect(sourceRect: CGRect, previewRect: CGRect) -> CGRect {
        let sourceAspectRatio: CGFloat = sourceRect.size.width/sourceRect.size.height
        let previewAspectRatio: CGFloat = previewRect.size.width/previewRect.size.height
        // 想要保持屏幕大小，所以裁剪视频图像
        var drawRect = sourceRect
        if sourceAspectRatio>previewAspectRatio {
            // 使用视频图像的全部高度，并中心裁剪宽度
            let scaledHeight = drawRect.size.height*previewAspectRatio
            drawRect.origin.x += (drawRect.self.width-scaledHeight)/2
            drawRect.size.width = scaledHeight
        } else {
            // 使用视频图像的全宽度，并中心裁剪高度
            drawRect.origin.y += (drawRect.size.height-drawRect.size.width/previewAspectRatio)/2
            drawRect.size.height = drawRect.size.width/previewAspectRatio
        }
        return drawRect
    }

    /**
     根据设备方向计算写入Transform
     - parameter deviceOrientation: 设备方向
     - returns: 写入Transform
     */
    static func writeTransform(for deviceOrientation: UIDeviceOrientation) -> CGAffineTransform {
        let result: CGAffineTransform
        switch deviceOrientation {
        case .landscapeRight:
            result = CGAffineTransform(rotationAngle: Double.pi)
        case .portraitUpsideDown:
            result = CGAffineTransform(rotationAngle: Double.pi/2*3)
        case .portrait, .faceUp, .faceDown, .unknown:
            result = CGAffineTransform(rotationAngle: Double.pi/2)
        case .landscapeLeft:
            result = CGAffineTransform.identity
        @unknown default:
            result = CGAffineTransform.identity
        }
        return result
    }

    static func outputURL() -> URL {
        let filePath = NSTemporaryDirectory() + "AVAssetWriter_movie.mov"
        let filerUrl = URL(fileURLWithPath: filePath)
        if FileManager.default.fileExists(atPath: filePath) {
            try? FileManager.default.removeItem(atPath: filePath)
        }
        return filerUrl
    }
}
