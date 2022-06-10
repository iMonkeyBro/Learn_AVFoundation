//
//  L_AVKit.swift
//  Learn_AVFoundation
//
//  Created by 刘超群 on 2022/6/8.
//

import UIKit
import AVKit

class L_AVKit: AVPlayerViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let videoUrl: URL = Bundle.main.url(forResource: "hubblecast2", withExtension: "m4v")!
        player = AVPlayer(url: videoUrl)
    }
}
