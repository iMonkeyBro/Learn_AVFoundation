//
//  L_CMTime.swift
//  Learn_AVFoundation
//
//  Created by 刘超群 on 2022/10/30.
//

import Foundation

class L_CMTime: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let time1 = CMTime(value: 1800, timescale: 600)
        let time2 = CMTimeMake(value: 3000, timescale: 1000)
        // 打印CMTime
        CMTimeShow(time1) //{1800/600 = 3.000}
        CMTimeShow(time2) //{3000/1000 = 3.000}
        // 方法传入的CMTime时间对应的一个Value和这个时间的timescale
        let time3 = CMTimeMakeWithSeconds(5, preferredTimescale: 600)
        let time4 = CMTime(seconds: 5, preferredTimescale: 600)
        CMTimeShow(time3) //{3000/600 = 5.000}得到的是5.000
        
        let addTime1 = CMTimeAdd(time1, time2)
        let addTime2 = time1 + time2
        CMTimeShow(addTime2) //{18000/3000 = 6.000}
        
        let subTime1 = CMTimeSubtract(time3, time2)
        let subTime2 = time3 - time2
        CMTimeShow(subTime2) //{6000/3000 = 2.000}
        
        let mulTime1 = CMTimeMultiply(time1, multiplier: 2) //乘以2
        let mulTime2 = CMTimeMultiplyByFloat64(time1, multiplier: 1.5) // 乘以1.5
        let mulTime3 = CMTimeMultiplyByRatio(time1, multiplier: 2, divisor: 3) // 乘以(2/3)
        CMTimeShow(mulTime1) //{3600/600 = 6.000}
        CMTimeShow(mulTime2) //{4500000000/1000000000 = 4.500}
        CMTimeShow(mulTime3) //{3600/1800 = 2.000}
        
        //CMTimeCompare(time1, time2) time1小于time2返回-1，等于返回0，大于返回1，
        let comResult1 = CMTimeCompare(time1, time2)
        let comResult2 = time1 == time2
        let comResult3 = time1 > time2
        let comResult4 = time1 <= time2
        print(comResult1, comResult2, comResult3, comResult4)
        let minTime = CMTimeMinimum(time1, time2)
        let maxTime = CMTimeMaximum(time1, time2)
        CMTimeShow(minTime) //{3000/1000 = 3.000}
        CMTimeShow(maxTime) //{1800/600 = 3.000}
        
        let timeRange1 = CMTimeRange(start: time1, end: time1)
        let timeRange2 = CMTimeRange(start: time1, duration: time1)
        CMTimeRangeShow(timeRange1) //{{1800/600 = 3.000}, {0/600 = 0.000}}
        CMTimeRangeShow(timeRange2) // {{1800/600 = 3.000}, {1800/600 = 3.000}}
        
        let intersectionRange = CMTimeRangeGetIntersection(timeRange1, otherRange: timeRange2)
        CMTimeRangeShow(intersectionRange)//{{0/1 = 0.000}, {0/1 = 0.000}}
        let unionRange = CMTimeRangeGetUnion(timeRange1, otherRange: timeRange2)
        CMTimeRangeShow(unionRange)//{{1800/600 = 3.000}, {1800/600 = 3.000}}
        let endTime = CMTimeRangeGetEnd(timeRange2)
        CMTimeShow(endTime)//{3600/600 = 6.000}
    }
}

