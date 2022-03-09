//
//  L_AVAsset.swift
//  Learn_AVFoundation
//
//  Created by 刘超群 on 2022/3/9.
//

import UIKit
import AVFoundation
import Photos
import MediaPlayer

class L_AVAsset: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        
      
        
        
    }
}

private extension L_AVAsset {

    func testAVURLAsset() {
        let assetURL = URL(fileURLWithPath: Bundle.main.path(forResource: "可能否-木小雅", ofType: "mp3")!)
        // 更精确的时长和计时信息，但加载时间也会长一些
        let options = [AVURLAssetPreferPreciseDurationAndTimingKey: true]
        let asset = AVURLAsset(url: assetURL, options: options)
    }
    
    func testPhotos() {
        // 利用Phtots框架获取用户相册的资源
        let photo: PHPhotoLibrary = PHPhotoLibrary()
    }
    
    func testQueryIPod() {
        // 利用MediaPlayer 查询iPod库，查询到后创建一个AVAsset
        let artistPredicate: MPMediaPropertyPredicate = MPMediaPropertyPredicate(value: "Foo Fighters", forProperty: MPMediaItemPropertyArtist)
        let albumPredicate: MPMediaPropertyPredicate = MPMediaPropertyPredicate(value: "In Your Honor", forProperty: MPMediaItemPropertyTitle)
        let songPredicate: MPMediaPropertyPredicate = MPMediaPropertyPredicate(value: "Best of You", forProperty: MPMediaItemPropertyTitle)
        let query: MPMediaQuery = MPMediaQuery()
        query.addFilterPredicate(artistPredicate)
        query.addFilterPredicate(albumPredicate)
        query.addFilterPredicate(songPredicate)
        let results = query.items
        if let tempResults = results, tempResults.count > 0 {
            let item: MPMediaItem = tempResults.first!
            let assetURL: URL = item.value(forProperty: MPMediaItemPropertyAssetURL)
            let asset: AVAsset = AVAsset(url: assetURL)
        }
    }
}
