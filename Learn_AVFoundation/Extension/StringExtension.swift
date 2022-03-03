//
//  StringExtension.swift
//  CQKit
//
//  Created by 刘超群 on 2021/5/18.
//

import Foundation

extension String: CQCompatible {}

public extension CQ where Base == String {
    /// 字符串里数字的个数
    var numberCount: Int {
        base.filter { (c) in
            ("0"..."9").contains(c)
        }.count
    }
}
