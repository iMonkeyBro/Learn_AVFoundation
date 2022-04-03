//
//  AVSpeechSynthesizer.swift
//  Learn_AVFoundation
//
//  Created by 刘超群 on 2022/3/4.
//

import UIKit
import AVFoundation

/// 语音播放
class L_AVSpeechSynthesizer: BaseViewController {
    private let synthesizer: AVSpeechSynthesizer = AVSpeechSynthesizer()
    private let voices: [AVSpeechSynthesisVoice?] = [AVSpeechSynthesisVoice(language: "en-US"),
                                                    AVSpeechSynthesisVoice(language: "en-GB")]
    private let speechStrings:[String] = ["Hello AV Foundation. How are you?",
                                          "I am well! Thanks for asking.",
                                          "Are you excited about the book?",
                                          "Very! I have always felt so misunderstood",
                                          "What is your favorite feature?",
                                          "Oh, they are all my babies, I could not possibly choose.",
                                          "It was great to speak with you!",
                                          "The pleasure was all mine! Hava fun!"]
    
    private var touchNumber: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        synthesizer.delegate = self
        test()
        
    }
    
    private func test() {
        
        // 创建播放话语
        let utterance = AVSpeechUtterance(string: "Hello AV Foundation")
        // 话语声音
//        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")  // 美式英语
        utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")  // 英式英语
//        utterance.voice = AVSpeechSynthesisVoice(identifier: "com.apple.ttsbundle.Daniel-compact")
        // 标识符
        CQLog(utterance.voice?.identifier)
        // 语音
        CQLog(utterance.voice?.language)
        // 性别，返回枚举0-未知，1-男性，2女性
        CQLog(utterance.voice?.gender)
        // 姓名
        CQLog(utterance.voice?.name)
        // 声音质量， 1默认质量，2增强质量
        CQLog(utterance.voice?.quality)
        
        // 查看所有的语音播放人员 Language: en-GB, Name: Arthur, Quality: Default
//        CQLog(AVSpeechSynthesisVoice.speechVoices())
        // 用户当前选择的语言编码
        CQLog(AVSpeechSynthesisVoice.currentLanguageCode())
        
        // 播放速率，略低于默认，可以用最大最小之间的百分比AVSpeechUtteranceMaximumSpeechRate AVSpeechUtteranceMinimumSpeechRate
//        utterance.rate = AVSpeechUtteranceMinimumSpeechRate
        utterance.rate = 0.4
        
        // 音调，0.5(地音调)-2.0(高音调)
        utterance.pitchMultiplier = 0.8
        
        // 播放下一段前暂停
        utterance.postUtteranceDelay = 0.1
        // 上一句播放完后暂停
//        utterance.preUtteranceDelay = 0.1
        
        // 音量 0-1
        utterance.volume = 1
        // 话语内容
        CQLog(utterance.speechString)
        
        // 播放
        synthesizer.speak(utterance)
        synthesizer.speak(AVSpeechUtterance(string: "Hello World"))
        // 读取播放时的AVAudioBuffer write和speak不可同时调用，会触发代理函数，
//        synthesizer.write(utterance) { audioBuffer in
//            CQLog(audioBuffer)
//        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touchNumber%2==0 {
            // 停止播放，触发播放完成代理回调,immediatel立即停止，word播放完当前段停止
            synthesizer.stopSpeaking(at: .word)
            // 暂停播放，触发暂停代理回调，可继续播放
//            synthesizer.pauseSpeaking(at: .immediate)
        } else {
            // 继续播放
            synthesizer.continueSpeaking()
        }
        
        touchNumber+=1
    }
    

    /*
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for i in 0..<speechStrings.count {
            let utterance = AVSpeechUtterance(string: speechStrings[i])
            // 语音声音，男生女生，英式美式
            utterance.voice = voices[i%2]
            // 播放速率，略低于默认，可以用最大最小之间的百分比AVSpeechUtteranceMaximumSpeechRate AVSpeechUtteranceMinimumSpeechRate
            utterance.rate = 0.4
            // 音调，0.5(地音调)-2.0(高音调)
            utterance.pitchMultiplier = 0.8
            // 播放下一段有所暂停，同理preUtteranceDelay
            utterance.postUtteranceDelay = 0.1
            synthesizer.speak(utterance)
        }
    }
     */
}

// MARK: - AVSpeechSynthesizerDelegate
extension L_AVSpeechSynthesizer: AVSpeechSynthesizerDelegate {
    // 开始播放回调
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        CQLog(utterance.speechString + "开始播放")
    }
    // 播放完成回调
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        CQLog(utterance.speechString + "播放完成")
    }
    // 暂停播放回调
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        CQLog(utterance.speechString + "暂停播放")
    }
    // 继续播放回调
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {
        CQLog(utterance.speechString + "继续播放")
    }
    // 取消播放回调
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        CQLog(utterance.speechString + "取消播放")
    }
    // 实时播放位置回调
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        CQLog(utterance.speechString + "播放位置\(characterRange.location)")
    }
    
    
}
