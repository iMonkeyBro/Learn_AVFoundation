//
//  L_AVPlayer.swift
//  Learn_AVFoundation
//
//  Created by 刘超群 on 2022/4/23.
//

import Foundation

class L_AVPlayer: BaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let time: CMTime = CMTimeMake(value: 1, timescale: 5)
        CMTIME_IS_INVALID(time)
        
    }
}
