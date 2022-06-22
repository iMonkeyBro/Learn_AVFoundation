//
//  L_Waveform.swift
//  Learn_AVFoundation
//
//  Created by 刘超群 on 2022/6/13.
//

import UIKit

class L_Waveform: BaseViewController {

    private var waveformView: WaveformView!
    private var asset: AVAsset!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let fileUrl: URL = Bundle.main.url(forResource: "kenengfou", withExtension: "mp3")!
        asset = AVAsset(url: fileUrl)
        
        test()
        
        return
        waveformView = WaveformView(frame: CGRect(x: 10, y: 100, width: 286, height: 80))
        waveformView.waveColor = .red
        waveformView.backgroundColor = .green
        waveformView.asset = asset
        
        view.addSubview(waveformView)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        waveformView.frame = CGRect(x: 10, y: 100, width: waveformView.frame.width-10, height: waveformView.frame.height-10)
    }
    
    
    private func test() {
        THSampleDataProvider.loadAudioSamples(from: asset) { data in
            let filter: THSampleDataFilter = THSampleDataFilter(data: data!)
            let filteredSamples = filter.filteredSamples(for: self.view.bounds.size)
        }
    }

}
