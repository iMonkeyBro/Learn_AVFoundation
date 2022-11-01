//
//  L_AVAduioMix.swift
//  Learn_AVFoundation
//
//  Created by 刘超群 on 2022/10/31.
//

import Foundation

class L_AVAuidoMix: BaseViewController {
    
    var player: AVPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let optionl: [String: Bool] = [AVURLAssetPreferPreciseDurationAndTimingKey: true]
        let keys: [String] = ["tracks", "duration", "commonMetadata"]
        let audioUrl: URL = Bundle.main.url(forResource: "01 Demo AAC", withExtension: "m4a")!
        let audioAsset = AVURLAsset(url: audioUrl, options: optionl)
        audioAsset.loadValuesAsynchronously(forKeys: keys)
        guard let audioTrack: AVAssetTrack = audioAsset.tracks(withMediaType: .audio).first else { return }
        
        let twoSeconds = CMTime(value: 2, timescale: 1)
        let fourSeconds = CMTime(value: 4, timescale: 1)
        let sevenSeconds = CMTime(value: 7, timescale: 1)
        
        let parameters: AVMutableAudioMixInputParameters = AVMutableAudioMixInputParameters(track: audioTrack)
        // 0秒声音0.5
        parameters.setVolume(0.5, at: .zero)
        // 2-4秒声音0.5-0.8
        let range = CMTimeRange(start: twoSeconds, end: fourSeconds)
        parameters.setVolumeRamp(fromStartVolume: 0.5, toEndVolume: 0.8, timeRange: range)
        // 7秒时声音0.1
        parameters.setVolume(0.1, at: sevenSeconds)
        
        var audioMix: AVMutableAudioMix = AVMutableAudioMix()
        audioMix.inputParameters = [parameters]
        
        let playerItem = AVPlayerItem(asset: audioAsset)
        // 对playerItem赋值，同样有导出需求，也可以对AVAssetExportSession赋值
        playerItem.audioMix = audioMix
        player = AVPlayer(playerItem: playerItem)
        player.play()
    }
    
}

