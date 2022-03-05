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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    private func test() {
        let speechSynthesizer: AVSpeechSynthesizer = AVSpeechSynthesizer()
        let utterance = AVSpeechUtterance(string: "Hello AV Foundation")
        speechSynthesizer.speak(utterance)
    }

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
}
