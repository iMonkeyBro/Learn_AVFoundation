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
    
    var delegate: MovieWriterDelegate?
    var isWriting: Bool = false
    
    private let videoSettings: [String: Any]?
    private let audioSettings: [String: Any]?
    private let dispatchQueue: DispatchQueue
    
    private var assetWriterInputPixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor!
    private var assetWriter: AVAssetWriter!
    private var assetWriterVideoInput: AVAssetWriterInput!
    private var assetWriterAudioInput: AVAssetWriterInput!
    
    private let ciContext: CIContext = ContextManager.shared.ciContext
    private let colorSpace: CGColorSpace = CGColorSpaceCreateDeviceRGB()
    
    private var activeFilter: CIFilter = PhotoFilters.filters.first!
    private var firstSample: Bool = true
    
    init(videoSettings: [String: Any]?, audioSettings: [String: Any]?, dispatchQueue: DispatchQueue) {
        self.videoSettings = videoSettings
        self.audioSettings = audioSettings
        self.dispatchQueue = dispatchQueue

        NotificationCenter.default.addObserver(self, selector: #selector(filterChanged), name: FilterSelectionChangedNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func filterChanged(_ notification: NSNotification) {
        activeFilter = (notification.object as? CIFilter)!
    }
    
    private func outputURL() -> URL {
        let filePath = NSTemporaryDirectory() + "AVAssetWriter_movie.mov"
        let filerUrl = URL(fileURLWithPath: filePath)
        if FileManager.default.fileExists(atPath: filePath) {
            try? FileManager.default.removeItem(atPath: filePath)
        }
        return filerUrl
    }
}

// MARK: - Public Func
extension MovieWriter {
    func startWriting() {
        dispatchQueue.async {
            self._startWriting()
        }
    }
    
    private func _startWriting() {
        // assetWriter
        do {
            assetWriter = try AVAssetWriter(url: self.outputURL(), fileType: .mov)
        } catch _ {
            print("Could not create AVAssetWriter")
        }
        
        // assetWriterVideoInput
        assetWriterVideoInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
        assetWriterVideoInput.expectsMediaDataInRealTime = true
        assetWriterVideoInput.transform = transform(for: UIDevice.current.orientation)
        var attributes: [String: Any] = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32RGBA,
                                           kCVPixelFormatOpenGLESCompatibility as String: kCFBooleanTrue]
        if let videoWidthKey = videoSettings?[AVVideoWidthKey] {
            attributes[kCVPixelBufferWidthKey as String] = videoWidthKey
        }
        if let videoHeightKey = videoSettings?[AVVideoHeightKey] {
            attributes[kCVPixelBufferHeightKey as String] = videoHeightKey
        }
        
        assetWriterInputPixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: assetWriterVideoInput, sourcePixelBufferAttributes: attributes)
        if (assetWriter.canAdd(assetWriterVideoInput) == true) {
            assetWriter.add(assetWriterVideoInput)
        } else {
            print("Unable to add video input.")
        }
        
        // assetWriterAudioInput
        self.assetWriterAudioInput = AVAssetWriterInput(mediaType: .audio, outputSettings: audioSettings)
        assetWriterAudioInput.expectsMediaDataInRealTime = true
        if (assetWriter.canAdd(assetWriterAudioInput) == true) {
            assetWriter.add(assetWriterAudioInput)
        } else {
            print("Unable to add audio input.")
        }
        isWriting = true
        firstSample = true
    }
    
    func stopWriting() {
        isWriting = false;
        dispatchQueue.async {
            self._stopWriting()
        }
    }
    
    private func _stopWriting() {
        assetWriter.finishWriting {
            if self.assetWriter.status == .completed {
                self.delegate?.didWriteMovieSuccess(at: self.outputURL())
            } else {
                self.delegate?.didWriteMovieFailed()
                print("Failed to write movie")
            }
        }
    }
    
    func process(sampleBuffer: CMSampleBuffer) {
        guard isWriting == true else { return }
        let formatDesc: CMFormatDescription = CMSampleBufferGetFormatDescription(sampleBuffer)!
        let mediaType: CMMediaType = CMFormatDescriptionGetMediaType(formatDesc)
        if mediaType == kCMMediaType_Video {
            let timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
            if firstSample == true {
                if assetWriter.startWriting() == true {
                    assetWriter.startSession(atSourceTime: timestamp)
                } else {
                    print("Failed to start writing.")
                }
                firstSample = false
            }
            // MARK: UnsafeMutablePointer
            var outputRenderBuffer: CVPixelBuffer?
            let pixelBufferPool: CVPixelBufferPool? = assetWriterInputPixelBufferAdaptor.pixelBufferPool
            let createResult = CVPixelBufferPoolCreatePixelBuffer(nil, pixelBufferPool!, &outputRenderBuffer)
            if createResult == kCVReturnError {
                print("Unable to obtain a pixel buffer from the pool.")
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
                
                if assetWriterVideoInput.isReadyForMoreMediaData == true {
                    if assetWriterInputPixelBufferAdaptor.append(pixBuffer, withPresentationTime: timestamp) == false {
                        print("Error appending pixel buffer.")
                    }
                }
            }
        }
        
        else if firstSample == false && mediaType == kCMMediaType_Audio {
            if assetWriterAudioInput.isReadyForMoreMediaData == true {
                if assetWriterAudioInput.append(sampleBuffer) == false {
                    print("Error appending audio sample buffer.")
                }
            }
        }
    }
    
}


