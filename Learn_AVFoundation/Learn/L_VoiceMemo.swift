//
//  L_VoiceMemo.swift
//  Learn_AVFoundation
//
//  Created by 刘超群 on 2022/3/5.
//

import UIKit
import AVFAudio

/// 学习利用AVAudioRecorder 做一个语音备忘录
class L_VoiceMemo: BaseViewController {

    private let recordBtn: UIButton = UIButton(type: .custom).cq.then {
        $0.setImage(R.image.voiceMemo_play(), for: .normal)
        $0.setImage(R.image.voiceMemo_pause(), for: .selected)
        $0.addTarget(self, action: #selector(recorderAction(_:)), for: .touchUpInside)
    }
    
    private let stopBtn: UIButton = UIButton(type: .custom).cq.then {
        $0.setImage(R.image.voiceMemo_stop(), for: .normal)
        $0.addTarget(self, action: #selector(stopAction(_:)), for: .touchUpInside)
    }
    
    private let timeLabel: UILabel = UILabel().cq.then {
        $0.textColor = .white
        $0.font = UIFont.pingFangMedium(size: 25)
        $0.text = "00:00:00"
    }
    
    private let volumeLabel: UILabel = UILabel().cq.then {
        $0.textColor = .white
        $0.font = UIFont.pingFangMedium(size: 25)
        $0.text = "--"
    }
    
    private let recorder: VoiceMemoRecorder = VoiceMemoRecorder()
    private var observerRecorder: NSKeyValueObservation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        observerRecorder = recorder.observe(\VoiceMemoRecorder.formattedCurrentTime) { voiceMemoRecorder, change in
            self.timeLabel.text = voiceMemoRecorder.formattedCurrentTime
        }
    }
}

// MARK: - Event
private extension L_VoiceMemo {
    @objc func recorderAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            recorder.record()
        } else {
            recorder.pause()
        }
    }
    
    @objc func stopAction(_ sender: UIButton) {
        recorder.stop { isSuccess in
            if isSuccess {
                // 录制成功，保存
                CQLog("录制成功")
                self.recorder.saveRecording(name: "测试录制成功", completionHandler: nil)
            } else {
                // 录制失败
                CQLog("录制失败")
            }
        }
    }
}

// MARK: - UI
private extension L_VoiceMemo {
    func configUI() {
        let topBackView = UIView().cq.then {
            $0.backgroundColor = .black
        }
        view.addSubview(topBackView)
        view.addSubview(timeLabel)
        view.addSubview(recordBtn)
        view.addSubview(stopBtn)
        topBackView.snp.makeConstraints { make in
            make.top.left.right.equalTo(view)
            make.height.equalTo(220)
        }
        timeLabel.snp.makeConstraints { make in
            make.centerX.equalTo(view.snp.centerX)
            make.top.equalTo(topBackView.snp.top).offset(10)
        }
        recordBtn.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 65, height: 65))
            make.right.equalTo(view.snp.centerX).offset(-15)
            make.top.equalTo(timeLabel.snp.bottom).offset(15)
        }
        stopBtn.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 65, height: 65))
            make.left.equalTo(view.snp.centerX).offset(15)
            make.top.equalTo(timeLabel.snp.bottom).offset(15)
        }
    }
}


// MARK: - testRecorder
private extension L_VoiceMemo {
    // 简单测试
    func testRecorder() {
        let directory = NSTemporaryDirectory()
        let filePath = directory + "voice.m4a"
        let url = URL(fileURLWithPath: filePath)
        /**
         AVFormatIDKey： 音频格式key
         AVSampleRateKey: 采样率
         AVNumberOfChannelsKey 通道数，1单声道录制，2立体声录制，除非使用全部外部硬件进行录制，否则应该创建单声道录音
         */
        let settings: [String: Any] = [AVFormatIDKey: kAudioFormatMPEG4AAC,
                                     AVSampleRateKey: 22050.0,
                                     AVNumberOfChannelsKey: 1]
        let recorder: AVAudioRecorder? = try? AVAudioRecorder(url: url, settings: settings)
        recorder?.prepareToRecord()
    }
}

// MARK: - VioceMemoRecorder
private class VoiceMemoRecorder: NSObject {
    typealias StopCompletionClosure = (Bool) -> ()
    typealias SaveCompletionClosure = (Bool, Any) -> ()
    
    @objc dynamic var formattedCurrentTime: String = ""
    var averagePower: Float = 0.0
    var peakPower: Float = 0.0
    
    // MARK: - Public
    @discardableResult
    func record() -> Bool {
        CQLog("开始录制")
        let result = recorder.record()
        if result == true {
            timer?.schedule(deadline: .now(), repeating: .milliseconds(100))
            timer?.setEventHandler(handler: {
                DispatchQueue.main.async {
                    self.reloadCuttentTimeAndVolum()
                }
            })
            timer?.resume()
        }
        return result
    }
    
    func pause() {
        timer?.suspend()
        CQLog("暂停录制")
        recorder.pause()
    }
    
    func stop(_ handler: StopCompletionClosure?) {
        timer?.suspend()
        CQLog("结束录制")
        stopHandler = handler
        recorder.stop()
    }
    
    func saveRecording(name: String, completionHandler: SaveCompletionClosure?) {
        // 将临时文件夹的问价赋值到doc目录
        let timestamp = Date.timeIntervalSinceReferenceDate
        let fileName = "\(name)-\(timestamp).caf"
        let destPath = String.cq.documentsDirectory+fileName
        let destUrl = URL(fileURLWithPath: destPath)
        do {
            try FileManager.default.copyItem(at: recorder.url, to: destUrl)
            removeTmpFile()
            completionHandler?(true, "")
            recorder.prepareToRecord()
        } catch {
            completionHandler?(false, "")
        }
        
    }
    
    func playbackMemo(memo: VoiceMemoRecorder) -> Bool {
        false
    }
    
    // MARK: - Init
    override init() {
        let filePath = NSTemporaryDirectory() + "momo.caf"
        let filerUrl = URL(fileURLWithPath: filePath)
        let settings: [String: Any] = [AVFormatIDKey: kAudioFormatAppleIMA4,
                                     AVSampleRateKey: 44100.0,
                               AVNumberOfChannelsKey: 1,
                            AVEncoderBitDepthHintKey: 16,]
//                            AVEncoderAudioQualityKey: AVAudioQuality.min]
        recorder = try! AVAudioRecorder(url: filerUrl, settings: settings)
        recorder.isMeteringEnabled = true
        recorder.prepareToRecord()
        timer = DispatchSource.makeTimerSource(queue: DispatchQueue.global())
        super.init()
        recorder.delegate = self
    }
    
    deinit {
        removeTmpFile()
    }
    
    // MARK: - Private
    private var recorder: AVAudioRecorder
    private var stopHandler: StopCompletionClosure?
    var timer: DispatchSourceTimer?
    
    private func reloadCuttentTimeAndVolum() {
        let time = recorder.currentTime
        let hours: Int = Int(time/3600)
        let minutes: Int = Int((time/60).truncatingRemainder(dividingBy: 60))
        let seconds: Int = Int(time.truncatingRemainder(dividingBy: 60))
        formattedCurrentTime = String(format: "%02i:%02i:%02i", hours, minutes, seconds)
        
        // 该方法一定要在读取之前调用
        recorder.updateMeters()
        // 平均，因为是单声道录制，所以询问第一个声道即可 ,范围0 - -160
        averagePower = recorder.averagePower(forChannel: 0)
        // 峰值，因为是单声道录制，所以询问第一个声道即可 ,范围0 - -160
        peakPower = recorder.peakPower(forChannel: 0)
        
        CQLog("录制时间:\(formattedCurrentTime),平均功率：\(averagePower)，峰值功率：\(peakPower)")
    }
    
    private func removeTmpFile() {
        do {
            let filePath = NSTemporaryDirectory() + "momo.caf"
            try FileManager.default.removeItem(atPath: filePath)
        } catch {
            CQLog("删除临时文件失败")
        }
    }

}

extension VoiceMemoRecorder: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        stopHandler?(flag)
    }
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        CQLog("编码错误")
    }
}
