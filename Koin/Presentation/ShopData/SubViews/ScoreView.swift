//
//  ScoreView.swift
//  koin
//
//  Created by 김나훈 on 7/9/24.
//

import Cosmos
import UIKit

final class ScoreView: CosmosView {
    
    override init(frame: CGRect, settings: CosmosSettings) {
        super.init(frame: frame, settings: settings)
        configureView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureView() {
        settings.filledImage = UIImage.appImage(asset: .star)
        settings.emptyImage = UIImage.appImage(asset: .emptyStar)
    }
}
