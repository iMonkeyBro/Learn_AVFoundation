//
//  BaseViewController.swift
//  Learn_AVFoundation
//
//  Created by 刘超群 on 2022/3/4.
//

import UIKit

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    deinit {
        CQLog("deinit:- \(type(of: self))")
    }
}