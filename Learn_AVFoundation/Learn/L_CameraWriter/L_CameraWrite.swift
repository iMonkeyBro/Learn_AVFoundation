//
//  L_CameraWrite.swift
//  Learn_AVFoundation
//
//  Created by 刘超群 on 2022/8/11.
//

import UIKit

class L_CameraWrite: BaseViewController {

    private let captureManager: CQCaptureManager = CQCaptureManager()
    private var preview: ImageBufferPreview!
    private var movieWriter: MovieWriter!
    private var currentFilter: CIFilter = FilterManager.filters[2]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        do {
            try captureManager.configVideoInput()
            captureManager.configVideoDataOutput()
            captureManager.configAudioDataOutput()
            captureManager.configSessionPreset(.hd1920x1080)
        } catch let error {
            print("Error-\(error.localizedDescription)")
        }
        
        captureManager.delegate = self
        
        let videoSettings: [String: Any]? = captureManager.videoDataOutput.recommendedVideoSettingsForAssetWriter(writingTo: .mov)
        let audioSettings: [String: Any]? = captureManager.audioDataOutput.recommendedAudioSettingsForAssetWriter(writingTo: .mov)
        movieWriter = MovieWriter(videoSettings: videoSettings, audioSettings: audioSettings)
        
        preview = ImageBufferPreview(frame: view.bounds, context: ContextManager.shared.eaglContext)
        preview.coreImageContext = ContextManager.shared.ciContext
        view.addSubview(preview)
        
        captureManager.startCaptureVideoData()
        
        movieWriter.startWriting()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        movieWriter.stopWriting()
    }

}

extension L_CameraWrite: CQCaptureManagerDelegate {
    func captureVideoSampleBuffer(_ sampleBuffer: CMSampleBuffer) {
        
        /**
         原书中Demo，将原始CMSampleBuffer 分别传给展示层和写入层，展示层和写入层分别加滤镜，从代码维护和性能上都不好，改为这里加滤镜，给到展示和写入的都是加了滤镜的
         */
        
        guard let imageBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let filteredImage = FilterManager.filterImage(for: currentFilter, pixelBuffer: imageBuffer)
        
        // 写入
        movieWriter.process(image: filteredImage, atTime: CMSampleBufferGetPresentationTimeStamp(sampleBuffer))

        // 展示
        preview.image = filteredImage  
    }
    
    func captureAudioSampleBuffer(_ sampleBuffer: CMSampleBuffer) {
        movieWriter.process(audioBuffer: sampleBuffer)
    }
}
