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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        do {
            try captureManager.configVideoInput()
            captureManager.configVideoDataOutput()
            captureManager.configAudioDataOutput()
            captureManager.configSessionPreset(.medium)
        } catch let error {
            print("Error-\(error.localizedDescription)")
        }
        
        let videoSettings: [String: Any]? = captureManager.videoDataOutput.recommendedVideoSettingsForAssetWriter(writingTo: .mov)
        let audioSettings: [String: Any]? = captureManager.audioDataOutput.recommendedAudioSettingsForAssetWriter(writingTo: .mov)
        movieWriter = MovieWriter(videoSettings: videoSettings, audioSettings: audioSettings, dispatchQueue: captureManager.captureQueue)
        
        captureManager.delegate = self
        preview = ImageBufferPreview(frame: view.bounds, context: ContextManager.shared.eaglContext)
        preview.coreImageContext = ContextManager.shared.ciContext
        view.addSubview(preview)
        
        captureManager.startCaptureMuteVideoData()
        
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
         这里按照书中Demo，将原始CMSampleBuffer 分别传给展示层和写入层，展示层和写入层分别加滤镜，从代码维护和性能上都不太好
         */
        
        // 展示
        let imageBuffer: CVPixelBuffer? = CMSampleBufferGetImageBuffer(sampleBuffer)
        if imageBuffer != nil {
            let image = CIImage(cvPixelBuffer: imageBuffer!, options: nil)
            preview.image = image
        }
        // 写入
        movieWriter.process(sampleBuffer: sampleBuffer)
    }
    
    func captureAudioSampleBuffer(_ sampleBuffer: CMSampleBuffer) {
        
    }
}
