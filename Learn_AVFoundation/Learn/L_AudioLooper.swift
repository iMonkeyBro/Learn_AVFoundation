//
//  L_AudioLooper.swift
//  Learn_AVFoundation
//
//  Created by 刘超群 on 2022/3/4.
//

import UIKit
import AVFAudio

/// 学习利用AVAudioPlayer 做一个Looper
class L_AudioLooper: BaseViewController {

    private lazy var playBtn: UIButton = UIButton(type: .custom).cq.then {
        $0.setTitleColor(.black, for: .normal)
        $0.setTitle("Play", for: .normal)
        $0.setTitle("Stop", for: .selected)
        $0.addTarget(self, action: #selector(playAction(_:)), for: .touchUpInside)
    }
    private lazy var rateSlider: UISlider = UISlider().cq.then {
        $0.minimumValue = 0.5
        $0.maximumValue = 2.0
        $0.addTarget(self, action: #selector(rateChangeAction(_:)), for: .valueChanged)
        $0.value = 1.0
    }
    private lazy var rateLabel: UILabel = UILabel().cq.then {
        $0.textColor = .black
        $0.text = "速率1.0"
    }
    
    private let looperPlayer: AudioLooperPlayer = AudioLooperPlayer()
    
    private var audioPlayer: AVAudioPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        testAudioPlayer()
    
//        looperPlayer.delegate = self
//        configUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 音频并不会立即释放，在这里stop比在deinit里更好
        audioPlayer.stop()
        looperPlayer.stop()
    }

}

// MARK: - testAudioPlayer
private extension L_AudioLooper {
    
    private func testAudioPlayer() {
        let fileUrl: URL = Bundle.main.url(forResource: "kenengfou", withExtension: "mp3")!
//        let musicData: Data = try! Data(contentsOf: fileUrl)
//        audioPlayer = try! AVAudioPlayer(data: musicData)
        audioPlayer = try! AVAudioPlayer(contentsOf: fileUrl)
        // 开始加载，不调用也会隐性调用，但会增加play和听到之间的延时
        audioPlayer.prepareToPlay()
        
        // 播放
        audioPlayer.play()
        // 暂停，play会继续播放
//        audioPlayer.pause()
        // 停止，play同样会继续播放，和pause的区别是，stop会撤销调用prepareToPlay时所作的设置，pause则不会
//        audioPlayer.stop()
        
        // 修改音量，独立于系统音量，可以实现很多有趣的效果，例如渐隐，0.0-1.0
        audioPlayer.volume = 1
        Asyncs.asyncDelayMain(seconds: 5) {
            self.audioPlayer.volume = 0.1
        }
        Asyncs.asyncDelayMain(seconds: 7) {
            self.audioPlayer.volume = 1
        }
        
        // pan值，允许使用立体声，pan的范围-1.0(左)-1.0(右)，默认0.0居中
        audioPlayer.pan = 0
        // 速率，在不改变音调的情况下调整播放速率，0.5(半速)-2.0(2倍速),1.0正常速度，部分资源可能无效
        audioPlayer.rate = 1.0
        // 循环次数，-1无限循环，
        audioPlayer.numberOfLoops = -1
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleInterruption(_:)), name: AVAudioSession.interruptionNotification, object: AVAudioSession.sharedInstance())
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleInterruption(_:)), name: AVAudioSession.interruptionNotification, object: AVAudioSession.sharedInstance())
    }
}

// MARK: - 测试中断、线路改变
private extension L_AudioLooper {
    @objc private func handleInterruption(_ center: NotificationCenter) {
        
    }
}

// MARK: - Private Func（Looper相关）
private extension L_AudioLooper {
    @objc private func playAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            looperPlayer.play()
        } else {
            looperPlayer.stop()
        }
    }
    
    @objc private func rateChangeAction(_ sender: UISlider) {
        looperPlayer.adjust(rate: sender.value)
        rateLabel.text = "速率:\(sender.value)"
    }
    
    @objc private func panChangeAction(_ sender: UISlider) {
        let index: Int = sender.tag-200
        looperPlayer.adjust(pan: sender.value, forPlayerAtIndex: index)
        let label: UILabel = view.viewWithTag(sender.tag+50) as! UILabel
        label.text = "pan:\(sender.value)"
    }
    
    @objc private func volumeChangeAction(_ sender: UISlider) {
        let index: Int = sender.tag-300
        looperPlayer.adjust(volume: sender.value, forPlayerAtIndex: index)
        let label: UILabel = view.viewWithTag(sender.tag+50) as! UILabel
        label.text = "声音:\(sender.value)"
    }
}

// MARK: - AudioLooperPlayerDelegate
extension L_AudioLooper: AudioLooperPlayerDelegate {
    func playbackBegan() {
        CQLog("中断开始")
        playBtn.isSelected = true
    }
    
    func playbackStopped() {
        CQLog("强制中断")
        playBtn.isSelected = false
    }
}

// MARK: - UI（Looper相关）
private extension L_AudioLooper {
    private func configUI() {
        view.addSubview(playBtn)
        view.addSubview(rateLabel)
        view.addSubview(rateSlider)
        playBtn.snp.makeConstraints { make in
            make.left.equalTo(view).offset(30)
            make.top.equalTo(view).offset(15)
        }
        rateSlider.snp.makeConstraints { make in
            make.centerY.equalTo(playBtn.snp.centerY)
            make.right.equalTo(-10)
            make.size.equalTo(CGSize(width: 150, height: 25))
        }
        rateLabel.snp.makeConstraints { make in
            make.centerY.equalTo(playBtn.snp.centerY)
            make.right.equalTo(rateSlider.snp.left).offset(-10)
        }
        
        let iconImgArr = [R.image.looper_guitar(), R.image.looper_bass(), R.image.looper_drum()]
        for i in 0..<3 {
            let icon = UIImageView(image: iconImgArr[i])
            let panSlider: UISlider = UISlider().cq.then {
                $0.minimumValue = -1.0
                $0.maximumValue = 1.0
                $0.addTarget(self, action: #selector(panChangeAction(_:)), for: .valueChanged)
                $0.value = 0.0
                $0.tag = 200+i
            }
            let panLabel: UILabel = UILabel().cq.then {
                $0.textColor = .black
                $0.text = "pan:0.0"
                $0.tag = 250+i
            }
            let volumeSlider: UISlider = UISlider().cq.then {
                $0.minimumValue = 0.0
                $0.maximumValue = 1.0
                $0.addTarget(self, action: #selector(volumeChangeAction(_:)), for: .valueChanged)
                $0.value = 0.5
                $0.tag = 300+i
            }
            let volumeLabel: UILabel = UILabel().cq.then {
                $0.textColor = .black
                $0.text = "音量:0.5"
                $0.tag = 350+i
            }

            view.addSubview(icon)
            view.addSubview(panLabel)
            view.addSubview(panSlider)
            view.addSubview(volumeLabel)
            view.addSubview(volumeSlider)

            icon.snp.makeConstraints { make in
                make.top.equalTo(playBtn.snp.bottom).offset(50)
                make.size.equalTo(CGSize(width: 65, height: 65))
                if i == 0 {
                    make.left.equalTo(30);
                } else if i == 1 {
                    make.centerX.equalTo(view.snp.centerX).offset(0)
                } else if i == 2 {
                    make.right.equalTo(-30);
                }
            }
            panLabel.snp.makeConstraints { make in
                make.top.equalTo(icon.snp.bottom).offset(20)
                make.centerX.equalTo((icon.snp.centerX))
            }
            panSlider.snp.makeConstraints { make in
                make.top.equalTo(panLabel.snp.bottom).offset(15)
                make.centerX.equalTo((icon.snp.centerX))
                make.size.equalTo(CGSize(width: 90, height: 25))
            }
            volumeLabel.snp.makeConstraints { make in
                make.top.equalTo(panSlider.snp.bottom).offset(15)
                make.centerX.equalTo((icon.snp.centerX))
            }
            volumeSlider.snp.makeConstraints { make in
                make.top.equalTo(volumeLabel.snp.bottom).offset(15)
                make.centerX.equalTo((icon.snp.centerX))
                make.size.equalTo(CGSize(width: 90, height: 25))
            }
        }
    }
}


// MARK: - Delegate
fileprivate protocol AudioLooperPlayerDelegate {
    func playbackStopped()
    func playbackBegan()
}

fileprivate extension AudioLooperPlayerDelegate {
    func playbackStopped(){ }
    func playbackBegan(){ }
}

// MARK: - AudioLooperPlayer
fileprivate class AudioLooperPlayer {
    
    // MARK: - Public
    var isPlaying: Bool = false
    
    var delegate: AudioLooperPlayerDelegate?
    
    func play() {
        // 要对三个播放器进行同步，需要捕捉当前设备并添加一个小延时，这样就会具有一个从开始播放时间计算的才找时间，保证播放器同步
        if !isPlaying {
            let delayTime: TimeInterval = players[0].deviceCurrentTime + 0.01
            for player: AVAudioPlayer in players {
                player.play(atTime: delayTime)
            }
            isPlaying = true
        }
    }
    
    func stop() {
        if isPlaying {
            for player: AVAudioPlayer in players {
                player.stop()
                player.currentTime = 0.0
            }
            isPlaying = false
        }
    }
    
    /// 速率，0.5(半速)-2.0(2倍速)
    func adjust(rate: Float) {
        for player: AVAudioPlayer in players {
            player.rate = rate
        }
    }
    
    /// pan -1.0-1.0
    func adjust(pan: Float, forPlayerAtIndex index: Int) {
        if isVaild(index: index) {
            let player = players[index]
            player.pan = pan
        }
    }
    
    /// volume 0.0-1.0
    func adjust(volume: Float, forPlayerAtIndex index: Int) {
        if isVaild(index: index) {
            let player = players[index]
            player.volume = volume
        }
    }
    
    // MARK: - Init
    init() {
        let guitarPlayer = player(forFile: "guitar")
        let bassPlayer = player(forFile: "bass")
        let drumsPlayer = player(forFile: "drums")
        players = [guitarPlayer, bassPlayer, drumsPlayer]
        
        let nsnc = NotificationCenter.default
        nsnc.addObserver(self, selector: #selector(self.handleInterruption(_:)), name: AVAudioSession.interruptionNotification, object: AVAudioSession.sharedInstance())
        nsnc.addObserver(self, selector: #selector(handleRouteChange(_:)), name: AVAudioSession.routeChangeNotification, object: AVAudioSession.sharedInstance())
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Private
    private var players: [AVAudioPlayer] = []
    
    private func player(forFile name: String) -> AVAudioPlayer {
        let fileUrl: URL = Bundle.main.url(forResource: name, withExtension: "caf")!
        let player: AVAudioPlayer = try! AVAudioPlayer(contentsOf: fileUrl)
        player.numberOfLoops = -1
        player.enableRate = true
        player.prepareToPlay()
        return player
    }
    
    private func isVaild(index: Int) -> Bool {
        index >= 0 && index < players.count
    }
    
    /// 处理音频会话中断通知
    @objc private func handleInterruption(_ notification: Notification) {
        // 接收一个字典 AVAudioSessionInterruptionTypeKey确定中断类型
        let info: Dictionary = notification.userInfo!
        CQLog(info)
        let type: AVAudioSession.InterruptionType = AVAudioSession.InterruptionType(rawValue: info[AVAudioSessionInterruptionTypeKey]! as! UInt)!
     
        if type == AVAudioSession.InterruptionType.began {
            stop()
            delegate?.playbackStopped()
        } else if type == AVAudioSession.InterruptionType.ended {
            let options: AVAudioSession.InterruptionOptions = AVAudioSession.InterruptionOptions(rawValue: info[AVAudioSessionInterruptionOptionKey]! as! UInt)
            // 是否已经重新激活，是否可以再次播放
            if options == .shouldResume {
                play()
                delegate?.playbackBegan()
            }
        }
    }
    
    @objc private func handleRouteChange(_ notification: Notification) {
        // 判断线路变化原因
        let info: Dictionary = notification.userInfo!
        CQLog(info)
        let reason: AVAudioSession.RouteChangeReason = AVAudioSession.RouteChangeReason(rawValue: info[AVAudioSessionRouteChangeReasonKey]! as! UInt)!
        if reason == .oldDeviceUnavailable {
            let previousRoute: AVAudioSessionRouteDescription = info[AVAudioSessionRouteChangePreviousRouteKey] as! AVAudioSessionRouteDescription
            let previousOutput = previousRoute.outputs[0]
            let portType: AVAudioSession.Port = previousOutput.portType
            if portType == .headphones {
                stop()
                delegate?.playbackStopped()
            }
        }
    }
}

