//
//  ContextManager.swift
//  Learn_AVFoundation
//
//  Created by 刘超群 on 2022/8/12.
//

import Foundation

final class ContextManager {
    
    let eaglContext: EAGLContext
    let ciContext: CIContext
    
    static let shared = ContextManager()
    private init() {
        eaglContext = EAGLContext(api: .openGLES2)!
        ciContext = CIContext(eaglContext: eaglContext, options: [CIContextOption.workingColorSpace: nil])
    }
    
    
    
}
