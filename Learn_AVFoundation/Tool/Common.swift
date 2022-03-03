//
//  Common.swift
//  Learn_AVFoundation
//
//  Created by 刘超群 on 2022/3/4.
//

import Foundation

// 相当于PCH一次导入，多次使用
@_exported import SnapKit
@_exported import Then

/**
 项目名称
 Swift NSClassFromString 反射类需要加上项目名
 */
var KPROJECT_NAME: String {
    guard let infoDict = Bundle.main.infoDictionary else {
        return "."
    }
    let key = kCFBundleExecutableKey as String
    guard let value = infoDict[key] as? String else {
        return "."
    }
    return value + "."
}

// MARK:- 屏幕宽高
/// 屏幕宽度
let SCREEN_WIDTH = UIScreen.main.bounds.width
/// 屏幕高度
let SCREEN_HEIGHT = UIScreen.main.bounds.height

/// 是否是全面屏的ipad
var IS_FullScreenIPadPro: Bool{
    if #available(iOS 12.0, *) {
        if UIApplication.shared.keyWindow?.safeAreaInsets.bottom == 20 {
            return true
        }else{
            return false
        }
    }else{
        return false;
    }
}

// MARK:- 颜色方法
/**
颜色
- parameter r: 红色
- parameter g: 绿色
- parameter b: 蓝色
- parameter a: 透明度
*/
func RGBA(_ r: CGFloat, _ g: CGFloat, _ b:CGFloat, _ a: CGFloat) -> UIColor {
    return UIColor(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: a)
}
/**
 颜色
 - parameter r: 红色
 - parameter g: 绿色
 - parameter b: 蓝色
 */
func RGB(_ r: CGFloat, _ g: CGFloat, _ b:CGFloat) -> UIColor {
    return RGBA(r, g, b, 1.0)
}

/**
 随机颜色
 */
func RANDOM_UICOLOR() -> UIColor {
    return RGB(CGFloat(arc4random_uniform(256)), CGFloat(arc4random_uniform(256)), CGFloat(arc4random_uniform(256)))
}

// MARK:- 自定义打印方法, 打印文件名方法名行数，当然也可以自定义
/**
 - parameter file: 文件名，默认文件路径最后一个
 - parameter funcName: 函数名，默认打印所在函数
 - parameter lineNum: 行数，默认打印所在行数
 */
func CQLog<T>(_ message: T, file: NSString = #file, funcName: String = #function, lineNum: Int = #line) {
    #if DEBUG
    let fileName: String = file.lastPathComponent
    print("\(fileName)-\(funcName)-(\(lineNum))-\(message)")
    #endif
}

extension UIFont {
    public static func pingFangRegular(size: CGFloat) -> UIFont {
        guard let font = UIFont(name: "PingFangSC-Regular", size: size) else {
            return UIFont.systemFont(ofSize: size)
        }
        return font
    }

    public static func pingFangMedium(size: CGFloat) -> UIFont {
        guard let font = UIFont(name: "PingFangSC-Medium", size: size) else {
            return UIFont.systemFont(ofSize: size)
        }
        return font
    }

    public static func pingFangSemibold(size: CGFloat) -> UIFont {
        guard let font = UIFont(name: "PingFangSC-Semibold", size: size) else {
            return UIFont.systemFont(ofSize: size)
        }
        return font
    }

}
