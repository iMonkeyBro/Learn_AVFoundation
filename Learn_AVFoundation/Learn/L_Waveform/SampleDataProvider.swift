//
//  SamepleDataProvider.swift
//  Learn_AVFoundation
//
//  Created by 刘超群 on 2022/6/13.
//

import Foundation

class SampleDataProvider {
    /**
     从音频资源加载样本数据
     */
    static func loadAudioSamples(from asset: AVAsset, completion:(@escaping (_ data: NSData?)->Void)) {
        // 对资源所需的键异步载入，保证后续访问tracks操作不会遇到问题
        asset.loadValuesAsynchronously(forKeys: ["tracks"]) {
            let status: AVKeyValueStatus = asset.statusOfValue(forKey: "tracks", error: nil)
            var sampleData: NSData? = nil
            if status == .loaded {
                sampleData = SampleDataProvider.readAudioSamples(from: asset)
            }
            DispatchQueue.main.async {
                completion(sampleData)
            }
        }
    }
    
    /**
     从音频的资源轨道读取样本
     */
    private static func readAudioSamples(from asset: AVAsset) -> NSData? {
        let tryAssetReader: AVAssetReader? = try? AVAssetReader(asset: asset)
        guard let assetReader: AVAssetReader = tryAssetReader else {
            print("Asset Error!!!")
            return nil
        }
        // MARK: 最好根据媒体类型来获取轨道，这里只写一个演示
        let track: AVAssetTrack = asset.tracks(withMediaType: .audio).first!
        // 以未压缩pcm读取 大端字节序 整型  16位
        let outputSettings: [String: Any] = [AVFormatIDKey: kAudioFormatLinearPCM,
                  AVLinearPCMIsBigEndianKey: false,
                      AVLinearPCMIsFloatKey: false,
                     AVLinearPCMBitDepthKey: 16]
        let trackOutput: AVAssetReaderTrackOutput = AVAssetReaderTrackOutput(track: track, outputSettings: outputSettings)
        guard assetReader.canAdd(trackOutput) else {
            print("AssetReader add Error！！！")
            return nil
        }
        assetReader.add(trackOutput)
        // 读取样本数据
        assetReader.startReading()
        
        let sampleData: NSMutableData = NSMutableData.init()
        // 循环调用copyNextSampleBuffer 迭代buffer
        while assetReader.status == .reading {
            let samepleBuffer: CMSampleBuffer? = trackOutput.copyNextSampleBuffer()
            if samepleBuffer != nil {
                let blockBuffer: CMBlockBuffer = CMSampleBufferGetDataBuffer(samepleBuffer!)!
                // 确定数据长度
                let length: Int = CMBlockBufferGetDataLength(blockBuffer)
                let rawPointer: UnsafeMutableRawPointer = UnsafeMutableRawPointer.allocate(byteCount: length, alignment: 16)
                CMBlockBufferCopyDataBytes(blockBuffer, atOffset: 0, dataLength: length, destination: rawPointer)
                sampleData.append(rawPointer, length: length)
                CMSampleBufferInvalidate(samepleBuffer!)
                rawPointer.deallocate()
            }
        }
        if assetReader.status == .completed {
            return sampleData
        } else {
            print("Failed to read audio samples from asset")
            return nil
        }
    }
}
