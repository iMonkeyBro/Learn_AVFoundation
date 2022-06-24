//
//  SampleDataFilter.swift
//  Learn_AVFoundation
//
//  Created by 刘超群 on 2022/6/14.
//

import Foundation

/// 没写完不能用
class SampleDataFilter {
    
    private let sampleData: NSData
    
    required init(sampleData: NSData) {
        self.sampleData = sampleData
    }
    
    /// 没写完
    func filteredSamples(for size: CGSize) -> Array<Any> {
        /*
        var filteredSamples: [Any] = []
        let sampleCount: UInt = UInt(sampleData.length/16)
        let binSize = sampleCount/UInt(size.width)
        var bytes: UnsafeRawPointer = UnsafeRawPointer(sampleData.bytes)
        var maxSample: Int = 0
        for i in stride(from: 0, to: sampleCount, by: UInt16.Stride(binSize)) {
//            var sampleBin: [Int] = []
            var sampleBin: [Int] = Array(repeating: 0, count: Int(binSize))
            
            for j in 0..<binSize {
                let v: Int = Int(CFSwapInt16LittleToHost(bytes.))
//                sampleBin.append(v)
                sampleBin[Int(j)] = v
            }
        }
        
        return filteredSamples
         */
        []
         
    }
    
    private func maxValue(in array:[Int]) -> Int {
        var maxValue: Int = 0
        array.forEach {
            if abs($0) > maxValue { maxValue = abs($0) }
        }
        return maxValue
    }
}
