//
//  L_CubeCamera.swift
//  Learn_AVFoundation
//
//  Created by 刘超群 on 2022/7/8.
//

import UIKit

class L_CubeCamera: BaseViewController {

    private lazy var cubeView: CQCubeView = CQCubeView()
    private let captureManager: CQCaptureManager = CQCaptureManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cubeView.view.frame = view.bounds
        view.addSubview(cubeView.view)
        addChild(cubeView)
        captureManager.delegate = self
        captureManager.startCaptureMuteVideoData()
    }
    


}

extension L_CubeCamera: CQCaptureManagerDelegate {
    func captureVideoSampleBuffer(_ sampleBuffer: CMSampleBuffer) {
//        let pixelBuffer: CVImageBuffer? = CMSampleBufferGetImageBuffer(sampleBuffer)
//        if pixelBuffer != nil {
//            cubeView.pixelBuffer = pixelBuffer!
//        }
        cubeView.sampleBuffer = sampleBuffer
    }
}
