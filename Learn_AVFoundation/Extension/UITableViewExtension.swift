//
//  UITableViewExtension.swift
//  CQKit
//
//  Created by 刘超群 on 2021/5/18.
//

import Foundation
import UIKit

extension UITableView: CQCompatible { }

public extension CQ where Base == UITableView {
    /// 通过Cell类自动获取类名注册cell
    @discardableResult
    func register<T: UITableViewCell>(cellClass: T.Type) -> UITableView {
        base.register(cellClass, forCellReuseIdentifier: String(describing: T.self))
        return base
    }
    
    /// 通过Cell类获取复用cell
    func dequeueReusableCell<T: UITableViewCell>(_ cellClass: T.Type, for indexPath: IndexPath) -> T {
        guard let cell = base.dequeueReusableCell(withIdentifier: String(describing: T.self), for: indexPath) as? T else {
            fatalError("未能通过 \(String(describing: T.self)) 取出 \(String(describing: cellClass))，请检查注册的实际情况")
        }
        return cell
    }
}

