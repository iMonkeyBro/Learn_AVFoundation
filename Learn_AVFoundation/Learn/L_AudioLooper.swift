//
//  L_AudioLooper.swift
//  Learn_AVFoundation
//
//  Created by 刘超群 on 2022/3/4.
//

import UIKit
import AVFAudio

class L_AudioLooper: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        testAudioPlayer()
        
    }
    
    private func testAudioPlayer() {
        let fileUrl: URL = Bundle.main.url(forResource: "bass", withExtension: "caf")!
        let player: AVAudioPlayer = try! AVAudioPlayer(contentsOf: fileUrl)
        // 开始加载，不调用也会隐性调用，但会增加play和听到之间的延时
        player.prepareToPlay()
        player.play()
        return
        // 暂停，play会继续播放
        player.pause()
        // 停止，play会继续播放，和pause的区别是，stop会撤销调用prepareToPlay时所作的设置，pause则不会
        player.stop()
        // 修改音量，独立于系统音量，可以实现很多有趣的效果，例如渐隐，0.0-1.0
        player.volume = 1
        // pan值，允许使用立体声，pan的范围-1.0(左)-1.0(右)，默认0.0居中
        player.pan = 0
        // 速率，0.5(半速)-2.0(2倍速)
        player.rate = 1.0
        // 循环次数，-1无限循环
        player.numberOfLoops = -1
        
       
    }
    
    
    
}

fileprivate class AudioLooperPlayer {
    var isPlaying: Bool = false
    
    func play() {
        
    }
    
    func stop() {
        
    }
    
    func adjust(rate: Float) {
        
    }
    
    func adjust(pan: Float, forPlayerAtIndex index: Int) {
        
    }
    
    func adjust(volum: Float, forPlayerAtIndex index: Int) {
        
    }
    
    private var players: [AVAudioPlayer]
    init() {
        
    }
}

