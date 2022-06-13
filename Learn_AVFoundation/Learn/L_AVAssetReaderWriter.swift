//
//  L_AVAssetReaderWriter.swift
//  Learn_AVFoundation
//
//  Created by 刘超群 on 2022/6/13.
//

import UIKit
import AVFoundation

class L_AVAssetReaderWriter: BaseViewController {
    
    private var assetReader: AVAssetReader!
    private var  assetWriter: AVAssetWriter!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 创建AVAssetReader AVAssetReaderTrackOutput
        let videoUrl: URL = Bundle.main.url(forResource: "hubblecast2", withExtension: "m4v")!
        let asset: AVAsset = AVAsset(url: videoUrl)
        let track: AVAssetTrack = asset.tracks(withMediaType: .video).first!
        assetReader = try! AVAssetReader(asset: asset)
        let readerOutSettings: [String : Any] = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        let trackOutput: AVAssetReaderTrackOutput = AVAssetReaderTrackOutput(track: track, outputSettings: readerOutSettings)
        // AVAssetReader添加AVAssetReaderTrackOutput
        guard assetReader.canAdd(trackOutput) else { return }
        assetReader.add(trackOutput)
        assetReader.startReading()
        
        // 创建AVAssetWriter AVAssetWriterInput
        let outputPath = String.cq.documentsDirectory+"\("/testWriter").mp4"
        let outputUrl: URL = URL(fileURLWithPath: outputPath)
        try? FileManager.default.removeItem(at: outputUrl)
        assetWriter = try! AVAssetWriter(outputURL: outputUrl, fileType: .mp4)
        let writeOutputSettings: [String: Any] = [AVVideoCodecKey: AVVideoCodecType.h264,
                                               AVVideoWidthKey: 1280,
                                              AVVideoHeightKey: 720,
                               AVVideoCompressionPropertiesKey: [AVVideoMaxKeyFrameIntervalKey: 1,
                                                                      AVVideoAverageBitRateKey: 10500000,
                                                                        AVVideoProfileLevelKey: AVVideoProfileLevelH264Main31]]
        let writerInput: AVAssetWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: writeOutputSettings)
        // AVAssetWriter添加AVAssetWriterInput
        guard assetWriter.canAdd(writerInput) else { return }
        assetWriter.add(writerInput)
        assetWriter.startWriting()
        
        // 处理写入
        let dispathQueue: DispatchQueue = DispatchQueue(label: "writerQueue")
        assetWriter.startSession(atSourceTime: CMTime.zero)
        writerInput.requestMediaDataWhenReady(on: dispathQueue) {
            print("开始写入")
            var complete = false
            var buffIndex = 1
            // 如果可以写入更多的数据，继续写，如果不可以或者下一个buffer为空(或者有一个写入失败)，则结束写 跳出循环
            while writerInput.isReadyForMoreMediaData && !complete {
                let samepleBuffer = trackOutput.copyNextSampleBuffer()
                if samepleBuffer != nil {
                    print("写入数据中...\(buffIndex)")
                    buffIndex += 1
                    let result: Bool = writerInput.append(samepleBuffer!)
                    complete = !result
                } else {
                    // 添加操作已完成
                    writerInput.markAsFinished()
                    complete = true
                }
            }
            if complete == true {
                // 关闭写入会话
                self.assetWriter.finishWriting {
                    let status: AVAssetWriter.Status = self.assetWriter.status
                    if status == .completed {
                        print("写入成功")
                    } else {
                        print("写入失败")
                    }
                }
            }
            
            
        }
        
    }
    

    

}
