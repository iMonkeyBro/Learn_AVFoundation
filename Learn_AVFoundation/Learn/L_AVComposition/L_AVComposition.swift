//
//  L_AVComposition.swift
//  Learn_AVFoundation
//
//  Created by 刘超群 on 2022/10/8.
//

import Foundation
import AVKit

class L_AVComposition: AVPlayerViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        testComposition()
    }
    
    private func testComposition() {
        let optionl: [String: Bool] = [AVURLAssetPreferPreciseDurationAndTimingKey: true]
        let keys: [String] = ["tracks", "duration", "commonMetadata"]
        
        // 音频资源1
        let audioUrl: URL = Bundle.main.url(forResource: "02 Keep Going", withExtension: "m4a")!
        let audioAsset1 = AVURLAsset(url: audioUrl, options: optionl)
        audioAsset1.loadValuesAsynchronously(forKeys: keys)
        // 视频资源1
        let videoUrl1: URL = Bundle.main.url(forResource: "01_nebula", withExtension: "mp4")!
        let videoAsset1 = AVURLAsset(url: videoUrl1, options: optionl)
        videoAsset1.loadValuesAsynchronously(forKeys: keys)
        // 视频资源2
        let videoUrl2: URL = Bundle.main.url(forResource: "02_blackhole", withExtension: "mp4")!
        let videoAsset2 = AVURLAsset(url: videoUrl2, options: optionl)
        videoAsset2.loadValuesAsynchronously(forKeys: keys)
        // 创建可变创作，添加视频轨道 音频轨道
        let composition: AVMutableComposition = AVMutableComposition()
        let videoTrack: AVMutableCompositionTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)!
        let audioTrack: AVMutableCompositionTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)!
        
        var cursorTime: CMTime = .zero
        let videoDuration: CMTime = CMTimeMake(value: 5, timescale: 1)
        let videoRange: CMTimeRange = CMTimeRange(start: .zero, duration: videoDuration)
        // 从视频资源1获取轨道
        let videoTrack1: AVAssetTrack = videoAsset1.tracks(withMediaType: .video).first!
        // 将视频资源1的轨道添加到视频轨道
        try! videoTrack.insertTimeRange(videoRange, of: videoTrack1, at: cursorTime)
        
        cursorTime = CMTimeAdd(cursorTime, videoDuration)
        // 从视频资源2获取轨道
        let videoTrack2: AVAssetTrack = videoAsset2.tracks(withMediaType: .video).first!
        // 将视频资源2的轨道添加到视频轨道
        try! videoTrack.insertTimeRange(videoRange, of: videoTrack2, at: cursorTime)
        
        cursorTime = .zero
        let audioRange: CMTimeRange = CMTimeRange(start: .zero, duration: composition.duration)
        // 从音频资源1获取轨道
        let audioTrack1: AVAssetTrack = audioAsset1.tracks(withMediaType: .audio).first!
        // 将音频资源1的轨道添加到音频轨道
        try! audioTrack.insertTimeRange(audioRange, of: audioTrack1, at: cursorTime)
        
        // 测试播放创作效果
        player = AVPlayer(playerItem: AVPlayerItem(asset: composition))
        
    }
}
