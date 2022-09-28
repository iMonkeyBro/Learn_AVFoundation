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
    private var currentFilter: CIFilter = FilterManager.filters[0]
    
    private lazy var recordBtn: UIButton = UIButton(type: .custom).cq.then {
        $0.setTitle("录制", for: .normal)
        $0.setTitle("停止", for: .selected)
        $0.titleLabel?.font = .systemFont(ofSize: 15)
        $0.setTitleColor(.systemBlue, for: .normal)
        $0.frame = CGRect(x: 10, y: CQScreenTool.safeAreaTop()+64, width: 50, height: 25)
        $0.addTarget(self, action: #selector(recordAction), for: .touchUpInside)
    }
    private lazy var filterBtn: UIButton = UIButton(type: .custom).cq.then {
        $0.setTitle(currentFilter.displayName, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 15)
        $0.setTitleColor(.orange, for: .normal)
        $0.frame = CGRect(x: 60, y: CQScreenTool.safeAreaTop()+64, width: 100, height: 25)
        $0.addTarget(self, action: #selector(filterAction), for: .touchUpInside)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        do {
            try captureManager.configVideoInput()
            captureManager.configVideoDataOutput()
            captureManager.configAudioDataOutput()
            captureManager.configSessionPreset(.hd1920x1080)
            captureManager.delegate = self
        } catch let error {
            print("Error-\(error.localizedDescription)")
        }
        
        // 写入
        let videoSettings: [String: Any]? = captureManager.videoDataOutput.recommendedVideoSettingsForAssetWriter(writingTo: .mov)
        let audioSettings: [String: Any]? = captureManager.audioDataOutput.recommendedAudioSettingsForAssetWriter(writingTo: .mov)
        movieWriter = MovieWriter(videoSettings: videoSettings, audioSettings: audioSettings)
        
        // 预览
        let eaglContext = EAGLContext(api: .openGLES2)!
        let ciContext = CIContext(eaglContext: eaglContext, options: [CIContextOption.workingColorSpace: nil])
        preview = ImageBufferPreview(frame: CGRect(x: 0, y: CQScreenTool.safeAreaTop()+64, width: view.bounds.size.width, height: view.bounds.size.height-CQScreenTool.safeAreaTop()-64), context: eaglContext)
        preview.coreImageContext = ciContext
        view.addSubview(preview)
        
        captureManager.startCaptureVideoData()
        
        view.addSubview(recordBtn)
        view.addSubview(filterBtn)
    }
    
    @objc private func recordAction(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            movieWriter.startWriting()
        } else {
            movieWriter.stopWriting()
        }
    }

    @objc private func filterAction(sender: UIButton) {
        var index: Int = FilterManager.filters.firstIndex(of: currentFilter) ?? 0
        if index >= FilterManager.filters.count-1 {
            index = -1
        }
        currentFilter = FilterManager.filters[index+1]
        filterBtn.setTitle(currentFilter.displayName, for: .normal)
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
