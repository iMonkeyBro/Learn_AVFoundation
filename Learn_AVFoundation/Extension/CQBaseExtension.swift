//
//  CQBaseExtension.swift
//  CQKit
//
//  Created by 刘超群 on 2021/5/18.
//

import Foundation

// 定义前缀类型
public struct CQ<Base> {
    public var base: Base
    public init(_ base: Base) {
        self.base = base
    }
}

// 利用协议扩展前缀属性
public protocol CQCompatible {}

extension CQCompatible {
    // 这里不要只读，方便扩展mutating函数
    // 让cq扩展实例属性方法
    var cq: CQ<Self> {
        set {}
        get {
            CQ(self)
        }
    }
    
    // 让cq能扩展类属性类方法
    static var cq: CQ<Self>.Type {
        set {}
        get {
            CQ<Self>.self
        }
    }
}
