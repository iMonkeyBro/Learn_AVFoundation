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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        captureManager.delegate = self
        captureManager.configSessionPreset(.medium)
        
        preview = ImageBufferPreview(frame: view.bounds, context: ContextManager.shared.eaglContext)
        view.addSubview(preview)
        
        captureManager.startCaptureMuteVideoData()
        
        let temp: NSString = ""
        
    }
    

}

extension L_CameraWrite: CQCaptureManagerDelegate {
    func captureVideoSampleBuffer(_ sampleBuffer: CMSampleBuffer) {
        let imageBuffer: CVPixelBuffer? = CMSampleBufferGetImageBuffer(sampleBuffer)
        if imageBuffer != nil {
            let image = CIImage(cvPixelBuffer: imageBuffer!, options: nil)
            preview.image = image
        }
    }
    
    func captureAudioSampleBuffer(_ sampleBuffer: CMSampleBuffer) {
        
    }
}
