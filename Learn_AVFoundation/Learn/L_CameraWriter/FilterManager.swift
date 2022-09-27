//
//  PhotoFilters.swift
//  Learn_AVFoundation
//
//  Created by 刘超群 on 2022/8/18.
//

import Foundation

final class FilterManager {
    static let filters: [CIFilter] = [CIFilter(name: "CIPhotoEffectChrome")!,
                                      CIFilter(name: "CIPhotoEffectFade")!,
                                      CIFilter(name: "CIPhotoEffectInstant")!,
                                      CIFilter(name: "CIPhotoEffectMono")!,
                                      CIFilter(name: "CIPhotoEffectNoir")!,
                                      CIFilter(name: "CIPhotoEffectProcess")!,
                                      CIFilter(name: "CIPhotoEffectTonal")!,
                                      CIFilter(name: "CIPhotoEffectTransfer")!]
    
    
    static func filterImage(for filter: CIFilter, pixelBuffer: CVPixelBuffer) -> CIImage {
        // 原始Image
        let sourceImage: CIImage = CIImage(cvPixelBuffer: pixelBuffer)
        // 添加了滤镜Image
        FilterManager.filters.first!.setValue(sourceImage, forKey: kCIInputImageKey)
        var filteredImage: CIImage = FilterManager.filters.first!.outputImage ?? sourceImage
        FilterManager.filters.first!.setValue(nil, forKey: kCIInputImageKey)
        return filteredImage
    }
    
}

extension CIFilter {
    var displayName: String {
        get {
            let tempName: NSString = self.name as NSString
            return tempName.matchingRegex("CIPhotoEffect(.*)", capture: 1)
        }
    }
}
