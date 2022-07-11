//
//  L_CubeCamera.swift
//  Learn_AVFoundation
//
//  Created by 刘超群 on 2022/7/8.
//

import UIKit

class L_CubeCamera: BaseViewController {

    private lazy var cubeViewController: CQCubeViewController = CQCubeViewController()
    private let captureManager: CQCaptureManager = CQCaptureManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cubeViewController.view.frame = view.bounds
        view.addSubview(cubeViewController.view)
        addChild(cubeViewController)
        captureManager.delegate = self
        captureManager.configSessionPreset(.vga640x480)
        captureManager.startCaptureMuteVideoData()
    }
    


}

extension L_CubeCamera: CQCaptureManagerDelegate {
    func captureVideoSampleBuffer(_ sampleBuffer: CMSampleBuffer) {
//        let pixelBuffer: CVImageBuffer? = CMSampleBufferGetImageBuffer(sampleBuffer)
//        if pixelBuffer != nil {
//            cubeView.pixelBuffer = pixelBuffer!
//        }
        Asyncs.asyncMain { [weak self] in
            self?.cubeViewController.sampleBuffer = sampleBuffer
        }
        
    }
}
