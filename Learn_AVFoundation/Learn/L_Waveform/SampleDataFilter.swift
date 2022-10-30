//
//  SampleDataFilter.swift
//  Learn_AVFoundation
//
//  Created by 刘超群 on 2022/6/14.
//

import Foundation

/// 缩减数据，没写完不能用
class SampleDataFilter {
    
    private let sampleData: Data
    
    required init(sampleData: Data) {
        self.sampleData = sampleData
    }
    
    /// 没写完
    func filteredSamples(for size: CGSize) -> Array<Float> {
        // 创建出租保存筛选的样本，确定样本总数并计算传入方法的尺寸约束相应箱尺寸值
        // 一个箱包含一个需要被筛选的样本子集
        var filteredSamples: [Float] = []
        let sampleCount: UInt = UInt(sampleData.count/2)
        let binSize = sampleCount/UInt(size.width)
        
        var bytes = [UInt8](sampleData)
//        let bytes3 = sampleData.withUnsafeBytes {
//            [UInt8](UnsafeBufferPointer(start: $0, count: sampleData.count))
//        }
//        let bytes2 = UnsafeMutablePointer(&bytes)
//        let dataBytes = (sampleData as NSData).bytes
        
        var maxSample: Int = 0
        
        for i in stride(from: 0, to: sampleCount, by: UInt16.Stride(binSize)) {
            var sampleBin: [Int] = []
            
            for j:UInt in 0..<binSize {
                var value : Int = Int(bytes[Int(i+j)])
//                let vv = CFSwapInt16LittleToHost(dataBytes.loa)
                sampleBin.append(value)
            }
            
            let value = maxValue(in: sampleBin, of: binSize)
            filteredSamples.append(Float(value))
            if value > maxSample {
                maxSample = value
            }
        }
        let scaleFactor = Float(size.height/2)/Float(maxSample);
        for i in 0..<filteredSamples.count {
            filteredSamples[i] = filteredSamples[i] * scaleFactor
        }
        
        return filteredSamples
    }
     
    
    /// 迭代所有样本并找到最大值
    private func maxValue(in array:[Int], of size: UInt) -> Int {
        var maxValue: Int = 0
        for i in 0..<size {
            if abs(array[Int(i)]) > maxValue { maxValue = abs(array[Int(i)]) }
        }
        return maxValue
    }
}
