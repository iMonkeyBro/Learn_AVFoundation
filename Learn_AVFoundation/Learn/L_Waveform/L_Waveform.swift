//
//  L_Waveform.swift
//  Learn_AVFoundation
//
//  Created by 刘超群 on 2022/6/13.
//

import UIKit

class L_Waveform: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let fileUrl: URL = Bundle.main.url(forResource: "kenengfou", withExtension: "mp3")!
        let asset: AVAsset = AVAsset(url: fileUrl)
        SampleDataProvider.loadAudioSamples(from: asset) { data in
            print(data?.length)
            let dataFilter = SampleDataFilter(sampleData: data!)
            dataFilter.filteredSamples(for: CGSize.zero)
        }
        
    }
    

    

}
