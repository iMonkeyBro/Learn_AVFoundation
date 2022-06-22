//
//  WaveformView.swift
//  Learn_AVFoundation
//
//  Created by 刘超群 on 2022/6/15.
//

import UIKit

fileprivate struct Metric {
    static let widthScaling: CGFloat = 0.95
    static let heightScaling: CGFloat = 0.85
}

class WaveformView: UIView {
    /// 绘制资源
    var asset: AVAsset? {
        didSet {
            SampleDataProvider.loadAudioSamples(from: asset!) {[weak self] data in
                guard let `self` = self else { return }
                self.filter = THSampleDataFilter(data: data)
                self.loadingView.stopAnimating()
                
                // 调用该函数会调用drawRect
//                self.setNeedsDisplay()
            }
            
        }
    }
    /// 波形绘制颜色
    var waveColor: UIColor = .white {
        didSet {
            layer.borderWidth = 2.0
            layer.borderColor = oldValue.cgColor
            setNeedsDisplay()
        }
    }
    private var filter: THSampleDataFilter!
    private lazy var loadingView: UIActivityIndicatorView = {
        let loading: UIActivityIndicatorView = UIActivityIndicatorView(style: .whiteLarge)
        loading.center = CGPoint(x: bounds.width/2, y: bounds.height/2)
        return loading
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        Asyncs.asyncDelayMain(seconds: 3) {
            let filteredSamples = self.filter.filteredSamples(for: self.bounds.size)
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = .clear
        layer.cornerRadius = 2.0
        layer.masksToBounds = true
        addSubview(loadingView)
        loadingView.startAnimating()
    }
    
    override func draw(_ rect: CGRect) {
        guard filter != nil else { return }
        
        let contenxt: CGContext = UIGraphicsGetCurrentContext()!
        // 1.我们希望在试图内呈现这个波形，所以首先基于自定的高宽常量来缩放图像上下文
        // 人后计算xy偏移量，转换上下文，在缩放上下文中适当调整偏移
        contenxt.scaleBy(x: Metric.widthScaling, y: Metric.heightScaling)
        let xOffset: CGFloat = (1-Metric.widthScaling)*bounds.width
        let yOffset: CGFloat = (1-Metric.heightScaling)*bounds.height
        contenxt.translateBy(x: xOffset/2, y: yOffset/2)
        
        // 2.根据视图尺寸获取筛选样本，
        let filteredSamples = filter.filteredSamples(for: bounds.size)
        guard let `filteredSamples` = filteredSamples else { return }
        
        let midY = rect.midY
        
        // 3.创建CGMutablePath，用来绘制波形Bezier路径上半部
        let halfPath = CGMutablePath()
        halfPath.move(to: CGPoint(x: 0.0, y: midY))
        // 迭代向路径中添加点，索引作为x，样本值为y
        for (index,element) in filteredSamples.enumerated() {
            let sample: CGFloat = CGFloat(element.floatValue)
            halfPath.addLine(to: CGPoint(x: CGFloat(index), y: midY - sample))
        }
        // 上半部的最后一个点
        halfPath.addLine(to: CGPoint(x: CGFloat(filteredSamples.count), y: midY))
        
        // 4.创建第二个CGMutablePath，传递halfPath，使用这个Bezier路径绘制完整的波形
        let fullPath = CGMutablePath()
        fullPath.addPath(halfPath)
        
        // 5.要绘制下半部，需要对上半部路径translate和scale，使上半部路径翻转到下面，填满整个波形
        let transform = CGAffineTransform.identity
        transform.translatedBy(x: 0, y: rect.height)
        transform.scaledBy(x: 1.0, y: -1.0)
        
        // 6.将完成的路径添加到图像上下文，根据指定的waveColor填充颜色，
        contenxt.addPath(fullPath)
        contenxt.setFillColor(waveColor.cgColor)
        // 将填充好的路径绘制到图像上下文
        contenxt.drawPath(using: CGPathDrawingMode.fill)
        
        // 7.Swift不用调用CGPathRelease，
    }
}
