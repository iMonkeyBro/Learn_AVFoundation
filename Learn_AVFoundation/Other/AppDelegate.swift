//
//  AppDelegate.swift
//  Learn_AVFoundation
//
//  Created by 刘超群 on 2022/3/2.
//

import UIKit
import AVFAudio

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = UIColor.white
        window?.rootViewController = BaseNavController(rootViewController: CatalogVC())
        window?.makeKeyAndVisible()
        confitAudioSession()
        return true
    }
}

private extension AppDelegate {
    /**
     配置音频会话，音频会话的详细介绍，书籍22页
     */
    private func confitAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            _ = try audioSession.setCategory(.playAndRecord)
        } catch {
            CQLog(error)
        }
        do {
            _ = try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            CQLog(error)
        }
    }
}
