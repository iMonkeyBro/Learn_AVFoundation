//
//  CatalogVC.swift
//  Learn_AVFoundation
//
//  Created by 刘超群 on 2022/3/4.
//

import UIKit

class CatalogVC: BaseViewController {
    private lazy var mainTableView: UITableView = UITableView().cq.then {
        $0.delegate = self
        $0.dataSource = self
        $0.estimatedRowHeight = 50
        $0.backgroundColor = .white
        $0.cq.register(cellClass: UITableViewCell.self)
    }
    private lazy var rightBtn: UIButton = UIButton(type: .custom).cq.then {
        $0.setTitle("沙盒", for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 13)
        $0.setTitleColor(.systemBlue, for: .normal)
        $0.addTarget(self, action: #selector(pushFileBrowser), for: .touchUpInside)
    }
    
    private let dataList: [[String: String]] = [["title": "AVSpeechSynthesizer(语音播放)", "vc": "L_AVSpeechSynthesizer"],
                                                ["title": "AVAudioPlayer(音频播放)", "vc": "L_AVAudioPlayer"],
                                                ["title": "Audio Looper Demo(AVAudioPlayer示例)", "vc": "L_AudioLooper"],
                                                ["title": "AVAudioRecorder(音频录制,Voice Memo)", "vc": "L_VoiceMemo"],
                                                ["title": "AVAsset(AVAsset学习)", "vc": "L_AVAsset"],
                                                ["title": "AVPlayer(AVPlayer学习)", "vc": "L_AVPlayer"],
                                                ["title": "AVKit(AVKit学习)", "vc": "L_AVKit"],
                                                ["title": "AVFoundation捕捉", "vc": "L_Capture"],
                                                ["title": "Cube相机", "vc": "L_CubeCamera"],
                                                ["title": "AVAssetReader/Writer(读取和写入资源)", "vc": "L_AVAssetReaderWriter"],
                                                ["title": "学习音频波形图", "vc": "L_Waveform"],
                                                ["title": "相机(AVAssetWrite写入)", "vc": "L_CameraWrite"],
                                                ["title": "--", "vc": "BaseViewController"],
                                                ["title": "--", "vc": "BaseViewController"],
                                                ["title": "--", "vc": "BaseViewController"],]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Learn_AVFoundation"
        view.addSubview(mainTableView)
        mainTableView.delegate = self
        mainTableView.dataSource = self
        mainTableView.frame = view.bounds
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightBtn)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mainTableView.reloadData()
    }
    
    // 测试打印FontName
    func testPrintFontNames() {
        for fontfamilyName in UIFont.familyNames {
            CQLog(fontfamilyName)
            let fontNames = UIFont.fontNames(forFamilyName: fontfamilyName)
            for fontName in fontNames {
                CQLog(fontName)
            }
        }
    }
    
    @objc private func pushFileBrowser() {
        let classType = NSClassFromString(KPROJECT_NAME+"JXFileBrowserController") as! UIViewController.Type
        let viewController = classType.init().cq.then {
            $0.title = "沙盒目录"
        }
        navigationController?.pushViewController(viewController, animated: true)
    }
}

// MARK: - UITableViewDelegate,UITableViewDataSource
extension CatalogVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let classType = NSClassFromString(KPROJECT_NAME+dataList[indexPath.row]["vc"]!) as! UIViewController.Type
        let viewController = classType.init().cq.then {
            $0.title = dataList[indexPath.row]["title"]!
        }
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.cq.dequeueReusableCell(UITableViewCell.self, for: indexPath).cq.then {
            $0.textLabel?.text = dataList[indexPath.row]["title"]
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataList.count
    }
    
}
