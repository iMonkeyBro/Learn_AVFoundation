//
//  BaseNavController.swift
//  Learn_AVFoundation
//
//  Created by 刘超群 on 2022/3/4.
//

import UIKit

class BaseNavController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    deinit {
        CQLog("deinit:- \(type(of: self))")
    }

}
