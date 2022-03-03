//
//  UIImageExtension.swift
//  CQKit
//
//  Created by 刘超群 on 2021/5/18.
//

import Foundation
import UIKit

extension UIImage: CQCompatible {}

public extension CQ where Base == UIImage {
    
    /// 根据颜色生成UIImage
    /// - Note: 利用UIGraphicsBeginImageContextWithOptions绘制UIImage
    /// - Parameter color: 颜色
    /// - Returns: 生成的UIImage
    static func color(_ color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.main.scale)
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.setFillColor(color.cgColor)
        ctx?.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    @discardableResult
    func then(_ block: (Base) throws -> Void) rethrows -> Base {
        try block(base)
        return base
    }
}
