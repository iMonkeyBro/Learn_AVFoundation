//
//  Asyncs.swift
//  Learn_AVFoundation
//
//  Created by 刘超群 on 2022/3/5.
//

import Foundation


/**
 异步操作的一些封装
 */
public struct Asyncs {
    
    public typealias Task = () -> Void
    
    // MARK: - 异步执行任务
    /**
     异步到主线程执行任务
     - parameter task: 子线程任务
     */
    public static func asyncMain(mainTask: @escaping Task) {
        let item: DispatchWorkItem = DispatchWorkItem(block: mainTask)
        DispatchQueue.main.async(execute: item)
    }
    
    /**
     异步到子线程执行任务
     - parameter task: 子线程任务
     */
    public static func asyncSub(subTask: @escaping Task) {
        _async(subTask)
    }
    
    /**
     异步到子线程执行任务，子线程执行完再执行主线程任务
     - parameter subTask: 子线程任务
     - parameter mainTask: 主线程任务
     */
    public static func async(subTask: @escaping Task,
                             mainTask: @escaping Task) {
        _async(subTask, mainTask)
    }
    
    private static func _async(_ subTask: @escaping Task,
                               _ mainTask: Task? = nil) {
        let item: DispatchWorkItem = DispatchWorkItem(block: subTask)
        DispatchQueue.global().async(execute: item)
        if let main = mainTask {
            item.notify(queue: DispatchQueue.main, execute: main)
        }
    }
    
    // MARK: - 延迟异步执行任务
    /**
     延迟异步到主线程执行任务
     - parameter seconds: 延迟时间
     - parameter mainTask: 主线程任务
     - returns: DispatchWorkItem,可以做取消等操作
     */
    @discardableResult
    public static func asyncDelayMain(seconds: Double,
                                  mainTask: @escaping Task) -> DispatchWorkItem {
        let item = DispatchWorkItem(block: mainTask)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + seconds,
                                      execute: item)
        return item
    }
    
    /**
     延迟异步到子线程执行任务
     - parameter seconds: 延迟时间
     - parameter subTask: 子线程任务
     - returns: DispatchWorkItem,可以做取消等操作
     */
    @discardableResult
    public static func asyncDelaySub(seconds: Double,
                                  subTask: @escaping Task) -> DispatchWorkItem {
        return _asyncDelay(seconds, subTask)
    }
    
    /**
     延迟异步到子线程执行任务，子线程执行完再执行主线程任务
     - parameter seconds: 延迟时间
     - parameter subTask: 子线程任务
     - parameter mainTask: 主线程任务
     - returns: DispatchWorkItem,可以做取消等操作
     */
    @discardableResult
    public static func asyncDelay(seconds: Double,
                                  subTask: @escaping Task,
                                  mainTask: @escaping Task) -> DispatchWorkItem {
        return _asyncDelay(seconds, subTask, mainTask)
    }
    
    private static func _asyncDelay(_ seconds: Double,
                                    _ subTask: @escaping Task,
                                    _ mainTask: Task? = nil) -> DispatchWorkItem {
        let item = DispatchWorkItem(block: subTask)
        DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + seconds,
                                          execute: item)
        if let main = mainTask {
            item.notify(queue: DispatchQueue.main, execute: main)
        }
        return item
    }
    

}
