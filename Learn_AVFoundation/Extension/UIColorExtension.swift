//
//  UIColorExtension.swift
//  CQKit
//
//  Created by 刘超群 on 2021/5/18.
//

import Foundation
import UIKit

extension UIColor: CQCompatible {}

public extension CQ where Base == UIColor {
    
    /// hexColor转UIColor
    /// - Parameter hexColor: hexColor
    /// - Returns: UIColor
    static func hexColor(_ hexColor: Int64) -> UIColor {
        let red = ((CGFloat)((hexColor & 0xFF0000) >> 16))/255.0;
        let green = ((CGFloat)((hexColor & 0xFF00) >> 8))/255.0;
        let blue = ((CGFloat)(hexColor & 0xFF))/255.0;
        return UIColor(red: red, green: green, blue: blue, alpha: 1)
    }
}
