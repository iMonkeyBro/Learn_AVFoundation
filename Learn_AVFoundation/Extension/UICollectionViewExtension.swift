//
//  UICollectionViewExtension.swift
//  CQKit
//
//  Created by 刘超群 on 2021/5/18.
//

import Foundation
import UIKit

extension UICollectionView: CQCompatible { }

public extension CQ where Base == UICollectionView {
    /// 通过Cell类自动获取类名注册cell
    @discardableResult
    func register<T: UICollectionViewCell>(cellClass: T.Type) -> UICollectionView {
        base.register(cellClass, forCellWithReuseIdentifier: String(describing: T.self))
        return base
    }
    /// 通过Cell类获取复用cell
    func dequeueReusableCell<T: UICollectionViewCell>(_ cellClass: T.Type, for indexPath: IndexPath) -> T {
        guard let cell = base.dequeueReusableCell(withReuseIdentifier: String(describing: T.self), for: indexPath) as? T else {
            fatalError("未能通过 \(String(describing: T.self)) 取出 \(String(describing: cellClass))，请检查注册的实际情况")
        }
        return cell
    }
}
