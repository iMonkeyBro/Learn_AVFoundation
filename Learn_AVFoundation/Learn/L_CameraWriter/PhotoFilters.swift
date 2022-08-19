//
//  PhotoFilters.swift
//  Learn_AVFoundation
//
//  Created by 刘超群 on 2022/8/18.
//

import Foundation

final class PhotoFilters {
    static let filters: [CIFilter] = [CIFilter(name: "CIPhotoEffectChrome")!,
                                      CIFilter(name: "CIPhotoEffectFade")!,
                                      CIFilter(name: "CIPhotoEffectInstant")!,
                                      CIFilter(name: "CIPhotoEffectMono")!,
                                      CIFilter(name: "CIPhotoEffectNoir")!,
                                      CIFilter(name: "CIPhotoEffectProcess")!,
                                      CIFilter(name: "CIPhotoEffectTonal")!,
                                      CIFilter(name: "CIPhotoEffectTransfer")!]
}

extension CIFilter {
    var displayName: String {
        get {
            let tempName: NSString = self.name as NSString
            return tempName.matchingRegex("CIPhotoEffect(.*)", capture: 1)
        }
    }
}
