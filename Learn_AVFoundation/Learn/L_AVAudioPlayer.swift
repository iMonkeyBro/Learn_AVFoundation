//
//  L_AVAudioPlayer.swift
//  Learn_AVFoundation
//
//  Created by 刘超群 on 2022/4/7.
//

import UIKit
import AVFAudio

/// 学习AVAudioPlayer
class L_AVAudioPlayer: BaseViewController {

    private var audioPlayer: AVAudioPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        testAudioPlayer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 音频并不会立即释放，在这里stop比在deinit里更好
        audioPlayer.stop()
    }
}

// MARK: - test AVAudioPlayer
private extension L_AVAudioPlayer {
    
    private func testAudioPlayer() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleInterruptionNotification(_:)), name: AVAudioSession.interruptionNotification, object: AVAudioSession.sharedInstance())
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleRouteChangeNotification(_:)), name: AVAudioSession.routeChangeNotification, object: AVAudioSession.sharedInstance())
        
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
    }
}

// MARK: - 测试中断、线路改变
private extension L_AVAudioPlayer {
    /// 处理中断
    @objc private func handleInterruptionNotification(_ notification: Notification) {
        // 接收一个字典 AVAudioSessionInterruptionTypeKey确定中断类型
        let info: Dictionary = notification.userInfo!
//        CQLog(info)
        let interruptionType: AVAudioSession.InterruptionType = AVAudioSession.InterruptionType(rawValue: info[AVAudioSessionInterruptionTypeKey]! as! UInt)!
        switch interruptionType {
        case .began:
            CQLog("中断开始")
        case .ended:
            CQLog("中断结束")
            let options: AVAudioSession.InterruptionOptions = AVAudioSession.InterruptionOptions(rawValue: info[AVAudioSessionInterruptionOptionKey]! as! UInt)
            // 是否已经重新激活，是否可以再次播放
            if options == .shouldResume {
                CQLog("中断结束，已经重新激活，可以再次播放")
            } else {
                CQLog("中断结束，尚未激活，无法播放")
            }
        @unknown default:
            fatalError("未知的音频中断类型")
        }
    }
    
    /// 处理线路变化
    @objc private func handleRouteChangeNotification(_ notification: Notification) {
        // 判断线路变化原因
        let info: Dictionary = notification.userInfo!
//        CQLog(info)
        let routeChangeReason: AVAudioSession.RouteChangeReason = AVAudioSession.RouteChangeReason(rawValue: info[AVAudioSessionRouteChangeReasonKey]! as! UInt)!
        switch routeChangeReason {
        case .unknown:
            CQLog("线路变化原因-未知")
        case .newDeviceAvailable:
            CQLog("线路变化原因-接入的新设备可用(例如，插入了耳机)")
        case .oldDeviceUnavailable:
            CQLog("线路变化原因-旧设备无法使用(例如，耳机被拔下)")
        case .categoryChange:
            CQLog("线路变化原因-音频类别发生了变化(例如重新设定了AVAudioSession.sharedInstance().setCategory)")
        case .override:
            CQLog("线路变化原因-这条线路已被重写(例如音频会话分类是AVAudioSessionCategoryPlayAndRecord时，改变了options)")
        case .wakeFromSleep:
            CQLog("线路变化原因-装置唤醒")
        case .noSuitableRouteForCategory:
            CQLog("线路变化原因-当没有当前类别路由时，例如音频会话分类是AVAudioSessionCategoryRecord时，却没有输入设备可用")
        case .routeConfigurationChange:
            CQLog("线路变化原因-输入/输出端口的集合没有改变，但某些方面他们的配置已经改变(例如，端口选择的数据源发生了变化)")
        @unknown default:
            fatalError("未知的音频线路变化类型")
        }
        
        // 获取前一个线路的描述
        let previousRoute: AVAudioSessionRouteDescription = info[AVAudioSessionRouteChangePreviousRouteKey] as! AVAudioSessionRouteDescription
        // 输出端口描述
        let previousRouteOutputs: [AVAudioSessionPortDescription] = previousRoute.outputs
        let previousOutput = previousRoute.outputs[0]
        // 获取输出端口类型
        let portType: AVAudioSession.Port = previousOutput.portType
        // 判断端口类型
        if portType == AVAudioSession.Port.lineIn {
            CQLog("端口类型-停靠连接器上的线电平输入")
        } else if portType == AVAudioSession.Port.builtInMic {
            CQLog("端口类型-iOS设备内置麦克风")
        } else if portType == AVAudioSession.Port.headsetMic {
            CQLog("端口类型-有线耳机上的麦克风")
        } else if portType == AVAudioSession.Port.lineOut {
            CQLog("端口类型-停靠连接器上的线电平输出")
        } else if portType == AVAudioSession.Port.headphones {
            CQLog("端口类型-耳机")
        } else if portType == AVAudioSession.Port.bluetoothA2DP {
            CQLog("端口类型-蓝牙A2DP输出")
        } else if portType == AVAudioSession.Port.builtInReceiver {
            CQLog("端口类型-打电话时贴在耳朵上的扬声器")
        } else if portType == AVAudioSession.Port.builtInSpeaker {
            CQLog("端口类型-iOS设备内置扬声器")
        } else if portType == AVAudioSession.Port.HDMI {
            CQLog("端口类型-高清多媒体接口输出")
        } else if portType == AVAudioSession.Port.airPlay {
            CQLog("端口类型-airPlay设备输出")
        } else if portType == AVAudioSession.Port.bluetoothLE {
            CQLog("端口类型-低功耗蓝牙设备输出")
        } else if portType == AVAudioSession.Port.bluetoothHFP {
            CQLog("端口类型-蓝牙免提配置文件设备上的输入或输出")
        } else if portType == AVAudioSession.Port.usbAudio {
            CQLog("端口类型-usb设备上的输入或输出")
        } else if portType == AVAudioSession.Port.carAudio {
            CQLog("端口类型-通过汽车音频输入或输出")
        } else if #available(iOS 14.0, *) {
            if portType == AVAudioSession.Port.virtual {
                CQLog("端口类型-与实际音频硬件不对应的输入或输出")
            } else if portType == AVAudioSession.Port.PCI {
                CQLog("端口类型-通过PCI(外围组件互连)总线连接的输入或输出")
            } else if portType == AVAudioSession.Port.fireWire {
                CQLog("端口类型-通过火线连接输入或输出")
            } else if portType == AVAudioSession.Port.displayPort {
                CQLog("端口类型-displayPort输入输出")
            } else if portType == AVAudioSession.Port.AVB {
                CQLog("端口类型-通过AVB(音视频桥接)连接输入或输出")
            } else if portType == AVAudioSession.Port.thunderbolt {
                CQLog("端口类型-通过雷电接口连接输入或输出")
            }
        } else {
            CQLog("端口类型-未知类型")
        }
    }
}

