//
//  MovieWriter.swift
//  Learn_AVFoundation
//
//  Created by 刘超群 on 2022/8/25.
//

import Foundation
import UIKit

protocol MovieWriterDelegate {
    func didWriteMovieSuccess(at url: URL)
    func didWriteMovieFailed()
}

extension MovieWriterDelegate {
    func didWriteMovieSuccess(at url: URL) {}
    func didWriteMovieFailed() {}
}

final class MovieWriter {
    /// 代理回调
    var delegate: MovieWriterDelegate?
    /// 是否正在写入标识
    private(set) var isWritingFlag: Bool = false
    /// coreImage上下文
    var ciContext: CIContext = {
        let eaglContext = EAGLContext(api: .openGLES2)!
        let ciContext = CIContext(eaglContext: eaglContext, options: [CIContextOption.workingColorSpace: nil])
        return ciContext
    }()
    
    private let videoSettings: [String: Any]?
    private let audioSettings: [String: Any]?
    
    private let inputPixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor
    private let assetWriter: AVAssetWriter!
    private let videoInput: AVAssetWriterInput!
    private let audioInput: AVAssetWriterInput!
    
    /// 色彩空间
    private let colorSpace: CGColorSpace = CGColorSpaceCreateDeviceRGB()
    /// 是否是第一帧标识
    private var isFirstSampleFlag: Bool = true
    
    init(videoSettings: [String: Any]?, audioSettings: [String: Any]?) {
        self.videoSettings = videoSettings
        self.audioSettings = audioSettings
        
        /**
         AVAssetWriter通过多个(音频、视频等)AVAssetWriterInput对象配置。AVAssetWriterInput通过mediaType和outputSettings来初始化，我们可以在outputSettings中进行视频比特率、视频宽高、关键帧间隔等细致的配置，这也是AVAssetWrite相比AVAssetExportSession明显的优势。AVAssetWriterInput在附加数据后会在最终输出时生成一个独立的AVAssetTrack.

         此处用到了PixelBufferAdaptor来附加CVPixelBuffer类型的数据，它在附加CVPixelBuffer对象的视频样本时能提供最优性能。
         */
        
        // assetWriter
        assetWriter = try! AVAssetWriter(url: WriteUtil.outputURL(), fileType: .mov)
        
        // 添加videoInput
        // 每个AssetWriterInput都期望接收CMSampelBufferRef格式的数据，如果是CVPixelBuffer格式的数据，就需要通过adaptor来格式化后再写入
        videoInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
        // 针对实时性进行优化
        videoInput.expectsMediaDataInRealTime = true
        videoInput.transform = WriteUtil.writeTransform(for: UIDevice.current.orientation)
        if (assetWriter.canAdd(videoInput) == true) {
            assetWriter.add(videoInput)
        } else {
            print("MovieWriter-无法添加视频输入.")
        }
        
        // 处理inputPixelBufferAdaptor，一定注意kCVPixelFormatType_32BGRA
        var videoAttributes: [String: Any] = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
                                         kCVPixelFormatOpenGLESCompatibility as String: true]
        if let videoWidthKey = videoSettings?[AVVideoWidthKey] {
            videoAttributes[kCVPixelBufferWidthKey as String] = videoWidthKey
        }
        if let videoHeightKey = videoSettings?[AVVideoHeightKey] {
            videoAttributes[kCVPixelBufferHeightKey as String] = videoHeightKey
        }
        inputPixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: videoInput, sourcePixelBufferAttributes: videoAttributes)
        
        // 添加audioInput
        self.audioInput = AVAssetWriterInput(mediaType: .audio, outputSettings: audioSettings)
        // 针对实时性进行优化
        audioInput.expectsMediaDataInRealTime = true
        if (assetWriter.canAdd(audioInput) == true) {
            assetWriter.add(audioInput)
        } else {
            print("MovieWriter-无法添加音频输入.")
        }
    }
    
    deinit {
        CQLog("MovieWriter-deinit")
    }

}

// MARK: - Public Func
extension MovieWriter {
    func startWriting() {
        isWritingFlag = true
        isFirstSampleFlag = true
    }
    
    func stopWriting() {
        isWritingFlag = false;
        assetWriter.finishWriting {
            if self.assetWriter.status == .completed {
                self.delegate?.didWriteMovieSuccess(at: WriteUtil.outputURL())
            } else {
                self.delegate?.didWriteMovieFailed()
                print("MovieWriter-写入视频失败.")
            }
        }
    }
    
    func process(image: CIImage, atTime time: CMTime) {
        /**
         数据保存阶段将加工后的媒体资源进行编码并写入到容器文件中，比如mp4文件或.mov文件等。此处使用AVAssetWriter，它支持实时写入。
         它默认期望接收到的数据也是CMSampleBuffer格式。但也可以通过pixelBufferAdaptor适配成它所期望的数据，这里改为了写入CVPixelBuffer。
         这里函数我们要求传入CIImage,然后将CIImage渲染成CVPixelBuffer，再进行写入。
         */
        
        guard isWritingFlag == true else { return }
        if isFirstSampleFlag == true {
            if assetWriter.startWriting() == true {
                assetWriter.startSession(atSourceTime: time)
            } else {
                print("MovieWriter-开始写入失败.")
            }
            isFirstSampleFlag = false
        }
        
        guard let pixelBufferPool: CVPixelBufferPool = inputPixelBufferAdaptor.pixelBufferPool else {
            print("MovieWriter-缓冲池为空.")
            return
        }
        // 从池中创建一个新的PixelBuffer对象。
        var outputRenderBuffer: CVPixelBuffer?
        let createResult = CVPixelBufferPoolCreatePixelBuffer(nil, pixelBufferPool, &outputRenderBuffer)
        if createResult != kCVReturnSuccess {
            print("MovieWriter-无法从池中获取像素缓冲区.")
            return
        }
        
        // 将CIImage渲染到CVPixelBuffer，再进行写入
        ciContext.render(image, to: outputRenderBuffer!, bounds: image.extent, colorSpace: colorSpace)
        if videoInput.isReadyForMoreMediaData == true {
            let result = inputPixelBufferAdaptor.append(outputRenderBuffer!, withPresentationTime: time)
            if result == false {
                print("MovieWriter-附加像素缓冲区错误.")
            }
        }
    }
    
    func process(audioBuffer: CMSampleBuffer) {
        guard isWritingFlag == true else { return }
        guard isFirstSampleFlag == false else { return }
        if audioInput.isReadyForMoreMediaData == true {
            let result = audioInput.append(audioBuffer)
            if result == false {
                print("MovieWriter-附加音频样本缓冲区错误.")
            }
        }
    }
    
}

// MARK: - Public Func 书中原版，在这里处理滤镜，不太好，废弃
/*
extension MovieWriter {
    func startWriting() {
        self._startWriting()
    }
    
    private func _startWriting() {
        isWritingFlag = true
        isFirstSampleFlag = true
    }
    
    func stopWriting() {
        isWritingFlag = false;
        dispatchQueue.async {
            self._stopWriting()
        }
    }
    
    private func _stopWriting() {
        assetWriter.finishWriting {
            if self.assetWriter.status == .completed {
                self.delegate?.didWriteMovieSuccess(at: WriteUtil.outputURL())
            } else {
                self.delegate?.didWriteMovieFailed()
                print("MovieWriter-写入视频失败.")
            }
        }
    }
    
    func process(sampleBuffer: CMSampleBuffer) {
        dispatchQueue.async {
            self._process(sampleBuffer: sampleBuffer)
        }
    }
    
    private func _process(sampleBuffer: CMSampleBuffer) {
        guard isWritingFlag == true else { return }
        let formatDesc: CMFormatDescription = CMSampleBufferGetFormatDescription(sampleBuffer)!
        let mediaType: CMMediaType = CMFormatDescriptionGetMediaType(formatDesc)
        if mediaType == kCMMediaType_Video {
            let timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
            if isFirstSampleFlag == true {
                if assetWriter.startWriting() == true {
                    assetWriter.startSession(atSourceTime: timestamp)
                } else {
                    print("MovieWriter-开始写入失败.")
                }
                isFirstSampleFlag = false
            }
            
            guard let pixelBufferPool: CVPixelBufferPool = inputPixelBufferAdaptor.pixelBufferPool else {
                print("MovieWriter-缓冲池为空.")
                return
            }
            // 从池中创建一个新的PixelBuffer对象。
            var outputRenderBuffer: CVPixelBuffer?
            let createResult = CVPixelBufferPoolCreatePixelBuffer(nil, pixelBufferPool, &outputRenderBuffer)
            if createResult != kCVReturnSuccess {
                print("MovieWriter-无法从池中获取像素缓冲区.")
                return
            }
            
            let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
            let sourceImage = CIImage(cvPixelBuffer: imageBuffer!)
            activeFilter.setValue(sourceImage, forKey: kCIInputImageKey)
            var filteredImage = activeFilter.outputImage
            if filteredImage == nil {
                filteredImage = sourceImage
            }
            
            if outputRenderBuffer != nil {
                let pixBuffer: CVPixelBuffer = outputRenderBuffer!
                ciContext.render(filteredImage!, to: pixBuffer, bounds: filteredImage!.extent, colorSpace: colorSpace)
                
                if videoInput.isReadyForMoreMediaData == true {
                    if inputPixelBufferAdaptor.append(pixBuffer, withPresentationTime: timestamp) == false {
                        print("MovieWriter-附加像素缓冲区错误.")
                    }
                }
            }
        }
        
        else if mediaType == kCMMediaType_Audio {
            guard isFirstSampleFlag == true else { return }
            if audioInput.isReadyForMoreMediaData == true {
                if audioInput.append(sampleBuffer) == false {
                    print("MovieWriter-附加音频样本缓冲区错误.")
                }
            }
        }
    }
    
}
*/

