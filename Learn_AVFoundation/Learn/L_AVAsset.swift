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
//        testAVURLAsset()
        
        print(CMTimeCompare(CMTime(value: 99999, timescale: 600), CMTime.invalid))
    }
}

private extension L_AVAsset {
    
    func testAVURLAsset() {
        // 生成asset
        let assetURL = URL(fileURLWithPath: Bundle.main.path(forResource: "01 Demo AAC", ofType: "m4a")!)
        // 更精确的时长和计时信息，但加载时间也会长一些
        let options = [AVURLAssetPreferPreciseDurationAndTimingKey: true]
        let asset: AVURLAsset = AVURLAsset(url: assetURL, options: options)
        
        // 获取asset的属性，当然可以直接获取不用这么麻烦
        let keys = ["tracks", "availableMetadataFormats"]
        asset.loadValuesAsynchronously(forKeys: keys) {
            var error: NSError? = nil
            let tracksStatus = asset.statusOfValue(forKey: "tracks", error: &error)
            switch tracksStatus {
            case .loaded:
//                CQLog(asset.tracks)
                break
            case .loading: break
            case .cancelled: break
            case .failed: break
            case .unknown: break
            @unknown default: break
            }
        }
        
        // 获取asset的AVMetadataItem
        var metadataItems: [AVMetadataItem] = []
        for format: AVMetadataFormat in asset.availableMetadataFormats {
            metadataItems.append(contentsOf: asset.metadata(forFormat: format))
        }
        CQLog("\(metadataItems.last!.key!)"+"--"+"\(metadataItems.last!.keyString())"+"--"+"\(metadataItems.last!.value!)")
        // 根据键空间和键筛选AVMetadataItem
        let keySpace: AVMetadataKeySpace = AVMetadataKeySpace.audioFile
        let artisKey = AVMetadataKey.iTunesMetadataKeyArtist
        let albumKey = AVMetadataKey.iTunesMetadataKeyAlbum
        let artistMetadata = AVMetadataItem.metadataItems(from: metadataItems, withKey: artisKey, keySpace: keySpace)
        let albumMetadata = AVMetadataItem.metadataItems(from: metadataItems, withKey: albumKey, keySpace: keySpace)
        let artistItem, albumItem : AVMetadataItem?
        artistItem = artistMetadata.first
        albumItem = albumMetadata.first
        if artistItem != nil {CQLog(artistItem!)}
        if albumItem != nil {CQLog(albumItem!)}
        // 根据标识符筛选AVMetadataItem
        let nameKeyId: AVMetadataIdentifier = AVMetadataIdentifier.iTunesMetadataSongName
        let nameMetadata = AVMetadataItem.metadataItems(from: metadataItems, filteredByIdentifier: nameKeyId)
        let nameItem: AVMetadataItem? = nameMetadata.first
        if nameItem != nil {CQLog(nameItem!.keyString())}
        
        // 使用AVMetadataItem
        
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
