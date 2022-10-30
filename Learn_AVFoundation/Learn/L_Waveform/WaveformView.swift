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

/// 渲染
class WaveformView: UIView {
    /// 绘制资源
    var asset: AVAsset? {
        didSet {
            SampleDataProvider.loadAudioSamples(from: asset!) {[weak self] data in
                guard let `self` = self else { return }
                self.filter = SampleDataFilter(sampleData: data!)
                self.loadingView.stopAnimating()
                
                // 调用该函数会调用drawRect
                self.setNeedsDisplay()
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
    private var filter: SampleDataFilter?
    private lazy var loadingView: UIActivityIndicatorView = {
        let loading: UIActivityIndicatorView = UIActivityIndicatorView(style: .whiteLarge)
        loading.center = CGPoint(x: bounds.width/2, y: bounds.height/2)
        return loading
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
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
        // 1.自定的高宽常量来缩放图像上下文
        // 然后计算xy偏移量，转换上下文，在缩放上下文中适当调整偏移
        contenxt.scaleBy(x: Metric.widthScaling, y: Metric.heightScaling)
        let xOffset: CGFloat = (1-Metric.widthScaling)*bounds.width
        let yOffset: CGFloat = (1-Metric.heightScaling)*bounds.height
        contenxt.translateBy(x: xOffset/2, y: yOffset/2)
        
        // 2.根据视图尺寸获取筛选样本，
        let filteredSamples =  filter?.filteredSamples(for: bounds.size)
        guard let `filteredSamples` = filteredSamples else { return }
        
        let midY = rect.midY
        
        // 3.创建CGMutablePath，用来绘制波形Bezier路径上半部
        let halfPath = CGMutablePath()
        halfPath.move(to: CGPoint(x: 0.0, y: midY))
        // 迭代向路径中添加点，索引作为x，样本值为y
        for (index,element) in filteredSamples.enumerated() {
            let sample: CGFloat = CGFloat(element)
            halfPath.addLine(to: CGPoint(x: CGFloat(index), y: midY - sample))
        }
        // 上半部的最后一个点
        halfPath.addLine(to: CGPoint(x: CGFloat(filteredSamples.count), y: midY))
        
        // 4.基于halfPath创建fullPath，用来绘制完整波形
        let fullPath = CGMutablePath()
        fullPath.addPath(halfPath)
        
        // 5.绘制下半部，对上半部translate和scale，使上半部翻转到下面，填满整个波形
        var transform = CGAffineTransform.identity
        transform = transform.translatedBy(x: 0, y: rect.height)
        transform = transform.scaledBy(x: 1.0, y: -1.0)
        fullPath.addPath(halfPath,transform: transform)
        
        // 6.将完成的路径添加到图像上下文，根据指定的waveColor填充颜色，
        contenxt.addPath(fullPath)
        contenxt.setFillColor(waveColor.cgColor)
        // 将填充好的路径绘制到图像上下文
        contenxt.drawPath(using: CGPathDrawingMode.fill)
        
        // 7.Swift不用调用CGPathRelease，
    }
}
