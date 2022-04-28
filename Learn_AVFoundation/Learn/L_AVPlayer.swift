//
//  L_AVPlayer.swift
//  Learn_AVFoundation
//
//  Created by 刘超群 on 2022/4/23.
//

import Foundation
import UIKit
import CoreMedia

class L_AVPlayer: BaseViewController {
    
    var playerLayer: AVPlayerLayer!
    var player: AVPlayer!
    var playerItem: AVPlayerItem!
    var timeObserver: Any!
    var endObserver: Any!
    var timeSlider: UISlider!
    var lastRate: Float!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setPlayer()
        addPlayerItemTimeObserver()
        addPlayerItemTimeEndObserver()
    }
    
    private func setUI() {
        let playerBtn = UIButton(type: .custom)
        playerBtn.setTitle("播放", for: .normal)
        playerBtn.setTitleColor(.black, for: .normal)
        playerBtn.frame = CGRect(x: 10, y: 600, width: 50, height: 20)
        playerBtn.addTarget(self, action: #selector(playAction), for: .touchUpInside)
        view.addSubview(playerBtn)
        let pauseBtn = UIButton(type: .custom)
        pauseBtn.setTitle("暂停", for: .normal)
        pauseBtn.setTitleColor(.black, for: .normal)
        pauseBtn.frame = CGRect(x: 70, y: 600, width: 50, height: 20)
        pauseBtn.addTarget(self, action: #selector(pauseAction), for: .touchUpInside)
        view.addSubview(pauseBtn)
        timeSlider = UISlider(frame: CGRect(x: 10, y: 700, width: 222, height: 22))
        timeSlider.minimumValue = 0
        timeSlider.maximumValue = 100
        timeSlider.addTarget(self, action: #selector(timeSliderEditingDidBegin(sender:)), for: .touchDown)
        timeSlider.addTarget(self, action: #selector(timeSliderActionEditingChanged(sender:)), for: .valueChanged)
        timeSlider.addTarget(self, action: #selector(timeSliderEditingDidEnd(sender:)), for: .touchUpInside)
        view.addSubview(timeSlider)
    }
    
    private func setPlayer() {
        let videoUrl: URL = Bundle.main.url(forResource: "hubblecast2", withExtension: "m4v")!
        playerItem = AVPlayerItem(url: videoUrl)
        player = AVPlayer(playerItem: playerItem)
        playerLayer = AVPlayerLayer(player: player)
        // 显示比例，默认resizeAspect，会在承载范围内缩放视频大小保持原始宽高比
        // resizeAspectFill会保持视频的宽高比，并使其通过缩放填满层的范围区域，通常会导致图像被部分裁剪
        // resize会将视频内容拉伸来匹配承载层的范围，这种情况最不常用，因为他通常会导致图片扭曲而导致的funhouse effect效应
        playerLayer.videoGravity = .resize
        playerLayer.frame = CGRect(x: 0, y: 100, width: SCREEN_WIDTH, height: 300)
        view.layer.addSublayer(playerLayer)
        playerItem.addObserver(self, forKeyPath: "status", options: .new, context: nil)
    }
    
    private func addPlayerItemTimeObserver() {
        timeObserver = player.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 10, timescale: 600), queue: DispatchQueue.main) {  [weak self] (time) in
            guard let `self` = self else { return }
            let currentTime: TimeInterval = CMTimeGetSeconds(time)
            self.timeSlider.value = Float(currentTime/CMTimeGetSeconds(self.playerItem.duration))*self.timeSlider.maximumValue
            CQLog("当前播放时间\(currentTime)")
        }
    }
    
    private func addPlayerItemTimeEndObserver() {
        endObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem, queue: OperationQueue.main, using: { notification in
            CQLog("播放完成了")
        })
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "status" {
            if playerItem.status == .readyToPlay {
                CQLog("可以播放了")
            }
        }
    }
    
    @objc private func playAction() {
        player.play()
    }
    
    @objc private func pauseAction() {
        player.pause()
    }
    
    @objc private func timeSliderEditingDidBegin(sender: UISlider) {
        lastRate = player.rate
        player.pause()
        player.removeTimeObserver(timeObserver!)
    }
    
    @objc private func timeSliderActionEditingChanged(sender: UISlider) {
        playerItem.cancelPendingSeeks()
        let currTime: CMTime = CMTimeMultiplyByFloat64(playerItem.duration, multiplier: Float64(sender.value/sender.maximumValue))
        playerItem.seek(to: currTime) { isCompletion in

        }
    }
    
    @objc private func timeSliderEditingDidEnd(sender: UISlider) {
        addPlayerItemTimeObserver()
        player.rate = lastRate
    }
}
