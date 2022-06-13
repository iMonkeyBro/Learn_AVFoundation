//
//  SamepleDataProvider.swift
//  Learn_AVFoundation
//
//  Created by 刘超群 on 2022/6/13.
//

import Foundation

class SamepleDataProvider {
    static func loadAudioSamples(from asset: AVAsset, completion:( @escaping (_ data: Data?)->Void)) {
        asset.loadValuesAsynchronously(forKeys: ["tracks"]) {
            let status: AVKeyValueStatus = asset.statusOfValue(forKey: "tracks", error: nil)
            var sampleData: Data? = nil
            if status == .loaded {
                sampleData = SamepleDataProvider.readAudioSamples(from: asset)
            }
            DispatchQueue.main.async {
                completion(sampleData)
            }
        }
    }
    
    private static func readAudioSamples(from asset: AVAsset) -> Data? {
        let tryAssetReader: AVAssetReader? = try? AVAssetReader(asset: asset)
        guard let assetReader: AVAssetReader = tryAssetReader else { return nil }
        let track: AVAssetTrack = asset.tracks(withMediaType: .audio).first!
        let outputSettings: [String: Any] = [AVFormatIDKey: kAudioFormatLinearPCM,
                  AVLinearPCMIsBigEndianKey: false,
                      AVLinearPCMIsFloatKey: false,
                     AVLinearPCMBitDepthKey: 16] as [String : Any] as [String : Any]
        let trackOutput: AVAssetReaderTrackOutput = AVAssetReaderTrackOutput(track: track, outputSettings: outputSettings)
        guard assetReader.canAdd(trackOutput) else {return nil}
        assetReader.add(trackOutput)
        assetReader.startReading()
        
        var sampleData: Data = Data.init()
        while assetReader.status == .reading {
            let samepleBuffer: CMSampleBuffer? = trackOutput.copyNextSampleBuffer()
            if samepleBuffer != nil {
                let blockBuffer: CMBlockBuffer = CMSampleBufferGetDataBuffer(samepleBuffer!)!
                let length: Int = CMBlockBufferGetDataLength(blockBuffer)
                let rawPointer: UnsafeMutableRawPointer = UnsafeMutableRawPointer.allocate(byteCount: length, alignment: 1)
                CMBlockBufferCopyDataBytes(blockBuffer, atOffset: 0, dataLength: length, destination: rawPointer)
                sampleData.append(rawPointer as! UnsafePointer<UInt8>, count: length)
                CMSampleBufferInvalidate(samepleBuffer!)
                rawPointer.deallocate()
            }
        }
        if assetReader.status == .completed {
            return sampleData
        } else {
            return nil
        }
        
    }
}
