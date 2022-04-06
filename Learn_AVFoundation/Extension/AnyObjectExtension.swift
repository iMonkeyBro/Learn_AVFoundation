//
//  CustomExtension.swift
//  CQKit
//
//  Created by 刘超群 on 2021/5/18.
//

import Foundation

public protocol CQThen { }
extension CQThen where Self: AnyObject {
    @discardableResult
    public func ddy_then(_ block: (Self) throws -> Void) rethrows -> Self {
        try block(self)
        return self
    }
}
extension NSObject: CQThen { }


extension NSObject: CQCompatible { }
public extension CQ where Base: AnyObject {
    @discardableResult
    func then(_ block: (Base) throws -> Void) rethrows -> Base {
        try block(base)
        return base
    }
}
