//
//  WaveformView.swift
//  Learn_AVFoundation
//
//  Created by 刘超群 on 2022/6/15.
//

import UIKit

class WaveformView: UIView {
    var asset: AVAsset? {
        didSet {
            
        }
    }
    var waveColor: UIColor? {
        didSet {
            
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        
    }
    
    override func draw(_ rect: CGRect) {
        
    }
}
