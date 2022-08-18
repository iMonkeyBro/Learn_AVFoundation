//
//  PhotoFilters.swift
//  Learn_AVFoundation
//
//  Created by 刘超群 on 2022/8/18.
//

import Foundation

final class PhotoFilters {
    
    private let filterNames: [String] = ["CIPhotoEffectChrome",
                                         "CIPhotoEffectFade",
                                         "CIPhotoEffectInstant",
                                         "CIPhotoEffectMono",
                                         "CIPhotoEffectNoir",
                                         "CIPhotoEffectProcess",
                                         "CIPhotoEffectTonal",
                                         "CIPhotoEffectTransfer"]
    let filterDisplayNames: [String] = ["CIPhotoEffectChrome",
                                         "CIPhotoEffectFade",
                                         "CIPhotoEffectInstant",
                                         "CIPhotoEffectMono",
                                         "CIPhotoEffectNoir",
                                         "CIPhotoEffectProcess",
                                         "CIPhotoEffectTonal",
                                         "CIPhotoEffectTransfer"]
    
    
}

extension CIFilter {
    var displayName: String {
        get {
            let tempName: NSString = self.name as NSString
            tempName.strings(byAppendingPaths: [""])
            return ""
        }
    }
}
