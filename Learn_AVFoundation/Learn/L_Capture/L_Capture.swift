//
//  L_Capture.swift
//  Learn_AVFoundation
//
//  Created by 刘超群 on 2022/6/13.
//

import UIKit
import AVFoundation

class L_Capture: BaseViewController {
    
    private let captureManager: CQCaptureManager = CQCaptureManager()
    private var previewView: CQCapturePreviewView!
    private let statusView: CQCameraStatusView = CQCameraStatusView()
    private let operateView: CQCameraOperateView = CQCameraOperateView()
    private let zoomView: CQCameraZoomView = CQCameraZoomView()
    private var cameraMode: CQCameraMode = .photo
    private var isStartFace: Bool = false
    private var isStartCode: Bool = false
    private var timer: DispatchSourceTimer?

    override func viewDidLoad() {
        super.viewDidLoad()

        CQAuthorizationTool.checkCameraAuthorization { isAuthorization in
            CQAuthorizationTool.checkMicrophoneAuthorization { isAuthorization in
                if isAuthorization == true {
                    Asyncs.asyncMain { [weak self] in
                        guard let `self` = self else { return }
                        self.configUI()
                        self.bindUIEvent()
                        self.configCaptureSession()
                    }
                }
            }
        }
        
    }
    
    private func configUI() {
        captureManager.delegate = self
        previewView = CQCapturePreviewView(frame: view.bounds)
        previewView.delegate = self
        
        view.addSubview(previewView)
        view.addSubview(statusView)
        view.addSubview(operateView)
        view.addSubview(zoomView)
        previewView.snp.makeConstraints { make in
            make.bottom.left.right.equalTo(view)
            make.top.equalTo(view.snp.top).offset(CQScreenTool.safeAreaTop()+64)
        };
        statusView.snp.makeConstraints { make in
            make.top.equalTo(view.snp.top).offset(CQScreenTool.safeAreaTop()+64)
            make.left.right.equalTo(view)
            make.height.equalTo(45)
        }
        operateView.snp.makeConstraints { make in
            make.bottom.left.right.equalTo(view)
            make.height.equalTo(85+CQScreenTool.safeAreaBottom())
        }
        zoomView.snp.makeConstraints { make in
            make.left.right.equalTo(view)
            make.height.equalTo(45)
            make.top.equalTo(statusView.snp.bottom)
        }
    }
    
    private func configCaptureSession() {
        captureManager.configSessionPreset(AVCaptureSession.Preset.iFrame1280x720)
        do {
            try captureManager.configVideoInput()
            captureManager.configStillImageOutput()
            captureManager.configMovieFileOutput()
            previewView.session = captureManager.captureSession
            captureManager.startSessionAsync()
        } catch let error {
            print("Error-\(error.localizedDescription)")
        }
        
        previewView.isFocusEnabled = captureManager.isSupportTapFocus
        previewView.isExposeEnabled = captureManager.isSupportTapExpose
        captureManager.flashMode = .auto
        statusView.flashMode = .auto
    }
    
    private func bindUIEvent() {
        statusView.flashBtnCallbackBlock = { [weak self] in
            guard let `self` = self else { return }
            if self.statusView.flashMode.rawValue < 2 {
                let rv = self.statusView.flashMode.rawValue + 1
                self.captureManager.flashMode = AVCaptureDevice.FlashMode(rawValue: rv)!
                self.statusView.flashMode = AVCaptureDevice.FlashMode(rawValue: rv)!
            } else {
                self.captureManager.flashMode = AVCaptureDevice.FlashMode(rawValue: 0)!
                self.statusView.flashMode = AVCaptureDevice.FlashMode(rawValue: 0)!
            }
        }
        
        statusView.switchCameraBtnCallbackBlock = { [weak self] in
            guard let `self` = self else { return }
            self.captureManager.switchCamera()
        }
        
        // 快门按钮
        operateView.shutterBtnCallbackBlock = { [weak self] in
            guard let `self` = self else { return }
            if self.cameraMode == .photo {
                self.captureManager.captureStillImage()
            }
            if self.cameraMode == .video {
                if self.captureManager.isRecordingMovieFile() == false {
                    self.captureManager.startRecordingMovieFile()
                    self.startListeningRecording()
                } else {
                    self.captureManager.stopRecordingMovieFile()
                    self.stopListeningRecording()
                }
            }
        }
        
        // 封面相册按钮
        operateView.coverBtnCallbackBlock = { [weak self] in
            guard self != nil else { return }
            let deviceVersion: Float = Float(UIDevice.current.systemVersion) ?? 0
            if deviceVersion < 10 {
                UIApplication.shared.openURL(URL(string: "PHOTOS://")!)
            } else {
                UIApplication.shared.openURL(URL(string: "photos-redirect://")!)
            }
        }
        
        // 更换相机模式
        operateView.changeModeCallbackBlock = { [weak self] mode in
            guard let `self` = self else { return }
            self.cameraMode = mode
            self.statusView.timeLabel.isHidden = self.cameraMode == .photo
            if self.cameraMode == .video {
                self.captureManager.configVideoFps(60)
            }
        }
        
        // 人脸识别开关
        operateView.faceSwitchCallbackBlock = { [weak self] isFace in
            guard let `self` = self else { return }
            self.isStartFace = isFace
            if isFace {
                self.captureManager.configMetadataOutput(withType: [.face])
            } else {
                self.captureManager.removeMetadataOutput()
                self.previewView.faceMetadataObjects = []
            }
        }
        
        // 条码识别开关
        operateView.codeSwitchCallbackBlock = { [weak self] isCode in
            guard let `self` = self else { return }
            self.isStartCode = isCode
            if isCode {
                self.captureManager.configMetadataOutput(withType: [.qr, .aztec])
            } else {
                self.captureManager.removeMetadataOutput()
                self.previewView.faceMetadataObjects = []
            }
        }
        
        operateView.fpsBtnCallbackBlock = { [weak self] in
            guard let `self` = self else { return }
            self.captureManager.enableHighFrameRateCapture()
        }
        
        zoomView.sliderChangeCallbackBlock = { [weak self] sliderValue in
            guard let `self` = self else { return }
            self.captureManager.configZoomValue(sliderValue)
        }
        
        zoomView.addBtnTouchDownCallbackBlock = { [weak self] in
            guard let `self` = self else { return }
            self.captureManager.ramp(toZoomValue: 1.0)
        }
        
        zoomView.addBtnTouchUpCallbackBlock = { [weak self] in
            guard let `self` = self else { return }
            self.captureManager.cancelZoom()
        }
        
        zoomView.subtractBtnTouchDownCallbackBlock = { [weak self] in
            guard let `self` = self else { return }
            self.captureManager.ramp(toZoomValue: 0.0)
        }
        
        zoomView.subtractBtnTouchUpCallbackBlock = { [weak self] in
            guard let `self` = self else { return }
            self.captureManager.cancelZoom()
        }
        
        
    }
    
    /// 开始录制，处理时间显示
    private func startListeningRecording() {
        timer = DispatchSource.makeTimerSource(flags: DispatchSource.TimerFlags(rawValue: 3), queue: DispatchQueue.main)
        timer?.schedule(deadline: .now(), repeating: .microseconds(250))
        timer?.setEventHandler {
            self.statusView.time = self.captureManager.movieFileRecordedDuration()
        }
        timer?.resume()
    }
    
    /// 结束录制
    private func stopListeningRecording() {
        timer?.cancel()
        self.statusView.time = .zero
    }

}

extension L_Capture: CQCaptureManagerDelegate {
    func deviceConfigurationFailedWithError(_ error: Error) {
        
    }
    
    func switchCameraSuccess() {
        previewView.isFocusEnabled = captureManager.isSupportTapFocus
        previewView.isExposeEnabled = captureManager.isSupportTapExpose
        captureManager.flashMode = .auto
        statusView.flashMode = .auto
    }
    
    func switchCameraFailed() {
        
    }
    
    func mediaCaptureImageFailedWithError(_ error: Error) {
        
    }
    
    func mediaCaptureImageFileSuccess() {
        captureManager.stopSessionAsync()
        Asyncs.asyncDelayMain(seconds: 0.2) { [weak self] in
            guard let `self` = self else { return }
            self.captureManager.startSessionAsync()
        }
    }
    
    func assetLibraryWriteImageSuccess(with image: UIImage) {
        Asyncs.asyncDelayMain(seconds: 0.2) { [weak self] in
            guard let `self` = self else { return }
            self.operateView.coverBtn.setImage(image, for: .normal)
        }
    }
    
    func assetLibraryWriteImageFailedWithError(_ error: Error) {
        
    }
    
    func mediaCaptureMovieFileSuccess() {
        
    }
    
    func mediaCaptureMovieFileFailedWithError(_ error: Error) {
        CQLog("捕捉视频失败")
    }
    
    func assetLibraryWriteMovieFileSuccess(withCover coverImage: UIImage) {
        Asyncs.asyncDelayMain(seconds: 0.2) { [weak self] in
            guard let `self` = self else { return }
            self.operateView.coverBtn.setImage(coverImage, for: .normal)
        }
    }
    
    func assetLibraryWriteMovieFileFailedWithError(_ error: Error) {
        
    }
    
    func mediaCaptureMetadataSuccess(with metadataObjects: [AVMetadataObject]) {
        if (isStartFace == true) {
            var faceObjs: [AVMetadataFaceObject] = []
            for metadataObj in metadataObjects {
                if let faceObj: AVMetadataFaceObject = metadataObj as? AVMetadataFaceObject {
                    faceObjs.append(faceObj)
                }
            }
            previewView.faceMetadataObjects = faceObjs
        }
        if (isStartCode == true) {
            var codeObjs: [AVMetadataMachineReadableCodeObject] = []
            for metadataObj in metadataObjects {
                if let codeObj: AVMetadataMachineReadableCodeObject = metadataObj as? AVMetadataMachineReadableCodeObject {
                    codeObjs.append(codeObj)
                    print("codeObj-\(codeObj.stringValue ?? "")")
                }
            }
        }
    }
    
    func zoomCameraFailed() {
        print("zoomCameraFailed")
    }
    
    func zoomCameraSuccess(_ zoomValue: CGFloat) {
//        print("zoomValue\(zoomValue)")
        zoomView.slider.value  = Float(zoomValue)
    }
}

extension L_Capture: CQCapturePreviewViewDelegate {
    func didTapFocus(at point: CGPoint) {
        captureManager.focus(at: point)
    }
    
    func didTapExpose(at point: CGPoint) {
        captureManager.expose(at: point)
    }
    
    func didTapResetFocusAndExposure() {
        captureManager.resetFocusAndExposureModes()
    }
}
