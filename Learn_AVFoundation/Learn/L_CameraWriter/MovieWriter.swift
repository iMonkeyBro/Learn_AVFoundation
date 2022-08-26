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
    
    private let videoSettings: [String: String]
    private let audioSettings: [String: String]
    private let dispatchQueue: DispatchQueue
    
    private var assetWriterInputPixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor!
    private var assetWriter: AVAssetWriter!
    private var assetWriterVideoInput: AVAssetWriterInput!
    private var assetWriterAudioInput: AVAssetWriterInput!
    private let ciContext: CIContext = ContextManager.shared.ciContext
    private let colorSpace: CGColorSpace = CGColorSpaceCreateDeviceRGB()
    private var activeFilter: CIFilter = PhotoFilters.filters.first!
    private var firstSample: Bool = false
    
    
    init(videoSettings: [String: String], audioSettings: [String: String], dispatchQueue: DispatchQueue) {
        self.videoSettings = videoSettings
        self.audioSettings = audioSettings
        self.dispatchQueue = dispatchQueue
        
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
        let attributes: [String: Any] = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32RGBA,
                                                     kCVPixelBufferWidthKey as String: videoSettings[AVVideoWidthKey],
                                                    kCVPixelBufferHeightKey as String: videoSettings[AVVideoHeightKey], kCVPixelFormatOpenGLESCompatibility as String: kCFBooleanTrue]
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
        firstSample = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(filterChanged), name: FilterSelectionChangedNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func filterChanged(_ notification: NSNotification) {
        activeFilter = (notification.object as? CIFilter)!
    }
    
    private func outputURL() -> URL {
        let filePath = NSTemporaryDirectory() + "movie.mov"
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
        
    }
    
    func stopWriting() {
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
            var outputRenderBuffer: UnsafeMutablePointer<CVPixelBuffer?> = UnsafeMutablePointer.allocate(capacity: 100)
            let pixelBufferPool: CVPixelBufferPool? = assetWriterInputPixelBufferAdaptor.pixelBufferPool
            let createResult = CVPixelBufferPoolCreatePixelBuffer(nil, pixelBufferPool!, outputRenderBuffer)
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
            
            ciContext.render(filteredImage!, to: outputRenderBuffer as! CVPixelBuffer, bounds: filteredImage!.extent, colorSpace: colorSpace)
            
            if assetWriterVideoInput.isReadyForMoreMediaData == true {
                if assetWriterInputPixelBufferAdaptor.append(outputRenderBuffer as! CVPixelBuffer, withPresentationTime: timestamp) == false {
                    print("Error appending pixel buffer.")
                }
            }
            
            
        }
        
        else if mediaType == kCMMediaType_Audio {
            if assetWriterAudioInput.isReadyForMoreMediaData == true {
                if assetWriterAudioInput.append(sampleBuffer) == false {
                    print("Error appending audio sample buffer.")
                }
            }
        }
    }
    
    var isWriting: Bool {
        return false
    }
    
    
}


