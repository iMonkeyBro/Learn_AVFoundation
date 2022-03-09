//
//  CatalogVC.swift
//  Learn_AVFoundation
//
//  Created by 刘超群 on 2022/3/4.
//

import UIKit

class CatalogVC: BaseViewController {
    private let cellIdentifier = "CatalogVCCell"
    private lazy var mainTableView: UITableView = UITableView().cq.then {
        $0.delegate = self
        $0.dataSource = self
        $0.estimatedRowHeight = 50
        
        $0.backgroundColor = .white
//        $0.separatorStyle = .none
        $0.frame = view.bounds
        $0.cq.register(cellClass: UITableViewCell.self)
    }
    private let dataList: [[String: String]] = [["title": "AVSpeechSynthesizer(语音播放)", "vc": "L_AVSpeechSynthesizer"],
                                                ["title": "AVAudioPlayer(音频播放,Audio Looper)", "vc": "L_AudioLooper"],
                                                ["title": "AVAudioRecorder(音频录制,Voice Memo)", "vc": "L_VoiceMemo"],
                                                ["title": "AVAsset(AVAsset学习)", "vc": "L_AVAsset"],
                                                ["title": "--", "vc": "BaseViewController"],
                                                ["title": "--", "vc": "BaseViewController"],
                                                ["title": "--", "vc": "BaseViewController"],
                                                ["title": "--", "vc": "BaseViewController"],
                                                ["title": "--", "vc": "BaseViewController"],
                                                ["title": "--", "vc": "BaseViewController"],
                                                ["title": "沙盒目录查看", "vc": "JXFileBrowserController"],]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Learn_AVFoundation"
        view.addSubview(mainTableView)
        mainTableView.delegate = self
        mainTableView.dataSource = self
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
        return tableView.cq.dequeueReusableCell(UITableViewCell.self, for: indexPath).cq.then {
            $0.textLabel?.text = dataList[indexPath.row]["title"]
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataList.count
    }
    
}
