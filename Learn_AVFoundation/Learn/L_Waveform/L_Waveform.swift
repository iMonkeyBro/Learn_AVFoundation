//
//  L_Waveform.swift
//  Learn_AVFoundation
//
//  Created by 刘超群 on 2022/6/13.
//

import UIKit

class L_Waveform: BaseViewController {

    private var waveformView: WaveformView!
    private var waveformView2: THWaveformView!
    private var asset: AVAsset!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let fileUrl: URL = Bundle.main.url(forResource: "01 Demo AAC", withExtension: "m4a")!
        asset = AVAsset(url: fileUrl)
        waveformView = WaveformView(frame: CGRect(x: 10, y: 100, width: 286, height: 80))
        waveformView.waveColor = .red
        waveformView.backgroundColor = .green
        waveformView.asset = asset
        
        waveformView2 = THWaveformView(frame: CGRect(x: 10, y: 200, width: 286, height: 80))
        waveformView2.waveColor = .red
        waveformView2.backgroundColor = .green
        waveformView2.asset = asset
        
        view.addSubview(waveformView)
        view.addSubview(waveformView2)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        waveformView.frame = CGRect(x: 10, y: 100, width: waveformView.frame.width-10, height: waveformView.frame.height-10)
        waveformView2.frame = CGRect(x: 10, y: 100, width: waveformView2.frame.width-10, height: waveformView2.frame.height-10)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        waveformView.frame = CGRect(x: 10, y: 100, width: waveformView.frame.width+10, height: waveformView.frame.height+10)
        waveformView2.frame = CGRect(x: 10, y: 100, width: waveformView2.frame.width-10, height: waveformView2.frame.height-10)
    }
    
    private func test() {
        SampleDataProvider.loadAudioSamples(from: asset) { data in
            let filter: SampleDataFilter = SampleDataFilter(sampleData: data!)
            let filteredSamples = filter.filteredSamples(for: self.view.bounds.size)
        }
    }

}
