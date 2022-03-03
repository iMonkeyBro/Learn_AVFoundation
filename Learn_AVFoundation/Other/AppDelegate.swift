//
//  AppDelegate.swift
//  Learn_AVFoundation
//
//  Created by 刘超群 on 2022/3/2.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let vc = CatalogVC()
        let nav = BaseNavController(rootViewController: vc);
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = UIColor.white
        window?.rootViewController = nav
        window?.makeKeyAndVisible()
        return true
    }

}

