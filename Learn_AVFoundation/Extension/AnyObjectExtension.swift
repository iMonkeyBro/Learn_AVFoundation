//
//  CustomExtension.swift
//  CQKit
//
//  Created by 刘超群 on 2021/5/18.
//

import Foundation

public protocol DDYThen { }
extension DDYThen where Self: AnyObject {
    @discardableResult
    public func ddy_then(_ block: (Self) throws -> Void) rethrows -> Self {
        try block(self)
        return self
    }
}

extension NSObject: DDYThen { }



extension NSObject: CQCompatible { }
public extension CQ where Base: AnyObject {
    @discardableResult
    func then(_ block: (Base) throws -> Void) rethrows -> Base {
        try block(base)
        return base
    }
}
