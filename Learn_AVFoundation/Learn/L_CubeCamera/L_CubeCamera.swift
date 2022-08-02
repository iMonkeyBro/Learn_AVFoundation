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
    
    private lazy var testButton: UIButton = {
        let btn: UIButton = UIButton(type: .custom)
        /**
         normal 常规状态，默认该状态，代码切换
         selected 选中状态，点击无法触发，代码切换
         btn.state = .selected
         highlighted 点击高亮时
         disabled 按钮设置无法点击时
         */
        btn.setImage(R.image.voiceMemo_stop(), for: .normal)
        btn.setImage(R.image.voiceMemo_stop(), for: .selected)
        btn.setImage(R.image.voiceMemo_stop(), for: .highlighted)
        btn.setImage(R.image.voiceMemo_stop(), for: .disabled)
        btn.setTitle("test", for: .normal)
        btn.setTitle("test", for: .selected)
        btn.setTitle("test", for: .highlighted)
        btn.setTitle("test", for: .disabled)
        btn.setTitleColor(.blue, for: .normal)
        btn.setTitleColor(.blue, for: .selected)
        btn.setTitleColor(.blue, for: .highlighted)
        btn.setTitleColor(.blue, for: .disabled)
        btn.setBackgroundImage(R.image.voiceMemo_stop(), for: .normal)
        btn.setBackgroundImage(R.image.voiceMemo_stop(), for: .selected)
        btn.setBackgroundImage(R.image.voiceMemo_stop(), for: .highlighted)
        btn.setBackgroundImage(R.image.voiceMemo_stop(), for: .disabled)
        btn.titleLabel?.font = .systemFont(ofSize: 14)
        btn.layer.masksToBounds = true
        btn.layer.cornerRadius = 3
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.black.cgColor
        return btn
    }()
    
    private lazy var testLabel: UILabel = {
        let label: UILabel = UILabel()
        // 字体
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        label.backgroundColor = .gray
        label.textColor = .blue
        label.text = "test"
        label.layer.masksToBounds = true
        // 圆角
        label.layer.cornerRadius = 3
        // 包边
        label.layer.borderWidth = 1
        // 包边颜色
        label.layer.borderColor = UIColor.black.cgColor
        return label
    }()

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
