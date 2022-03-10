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
        testAVURLAsset()
  
    }
}

private extension L_AVAsset {

    func testAVURLAsset() {
        let assetURL = URL(fileURLWithPath: Bundle.main.path(forResource: "可能否-木小雅", ofType: "mp3")!)
        // 更精确的时长和计时信息，但加载时间也会长一些
        let options = [AVURLAssetPreferPreciseDurationAndTimingKey: true]
        let asset = AVURLAsset(url: assetURL, options: options)
//        CQLog(asset.duration.seconds)
        
        let keys = ["tracks", "availableMetadataFormats"]
        asset.loadValuesAsynchronously(forKeys: keys) {
            var error: NSError? = nil
            let tracksStatus = asset.statusOfValue(forKey: "tracks", error: &error)
            switch tracksStatus {
            case .loaded:
                CQLog(asset.tracks)
            case .loading: break
            case .cancelled: break
            case .failed: break
            case .unknown: break
            @unknown default: break
            }
            var metadata: [Any] = []
            for format: AVMetadataFormat in asset.availableMetadataFormats {
                metadata.append(asset.metadata(forFormat: format))
            }
            let keySpace: AVMetadataKeySpace = AVMetadataKeySpace.iTunes
            let artisKey = AVMetadataKey.iTunesMetadataKeyArtist
            let albumKey = AVMetadataKey.iTunesMetadataKeyAlbum
            
        }
    }
    
    func testPhotos() {
        // 利用Phtots框架获取用户相册的资源
        let allPhotoOptions = PHFetchOptions()
//        allPhotoOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let allPhotos: PHFetchResult = PHAsset.fetchAssets(with: allPhotoOptions)
        allPhotos.enumerateObjects { asset, index, stop in
            if asset.mediaType == .video {
                let options = PHVideoRequestOptions()
                options.version = .current
                options.deliveryMode = .automatic
                PHImageManager.default().requestAVAsset(forVideo: asset, options: options) { avAsset, audioMix, info in
                    if let urlAsset: AVURLAsset = avAsset as? AVURLAsset {
                        CQLog(urlAsset.url)
                    }
                }
            } else if asset.mediaType == .image {
                let options: PHImageRequestOptions = PHImageRequestOptions()
                options.resizeMode = .exact
                options.isNetworkAccessAllowed = true
                options.isSynchronous = true
                PHImageManager.default().requestImageData(for: asset, options: options) { data, uti, orientation, info in
                    if uti == "com.compuserve.fig" {
                    }
                    if uti == "public.heif" || uti == "public.heic" {
                    }
                }
            }
        }
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
            if let assetURL: URL = item.value(forProperty: MPMediaItemPropertyAssetURL) as? URL {
                CQLog(assetURL)
                let asset: AVAsset = AVAsset(url: assetURL)
            }
        }
    }
}
