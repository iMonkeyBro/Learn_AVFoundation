//
//  AVCompositionExtension.swift
//  Learn_AVFoundation
//
//  Created by 刘超群 on 2022/10/11.
//

import Foundation
import AVFoundation

extension AVComposition: CQCompatible { }

public extension CQ where Base == AVComposition {
    func makePlayItem() -> AVPlayerItem {
        // AVComposition遵循NSCoding协议，这里copy一个不可变的副本，防止呈现时对象状态发生改变
        return AVPlayerItem(asset: self.base.copy() as! AVAsset)
    }
    
    func makeExportSession() -> AVAssetExportSession? {
        return AVAssetExportSession(asset: self.base.copy() as! AVAsset, presetName: AVAssetExportPresetHighestQuality)
    }
}
