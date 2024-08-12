//
//  ScoreView.swift
//  koin
//
//  Created by 김나훈 on 7/9/24.
//

import Cosmos
import UIKit

final class ScoreView: CosmosView {
    
    var onRatingChanged: ((Double) -> Void)?
    
    override var rating: Double {
        didSet {
            onRatingChanged?(rating)
        }
    }
    
    override init(frame: CGRect, settings: CosmosSettings) {
        super.init(frame: frame, settings: settings)
        configureView()
        bind()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureView() {
        settings.filledImage = UIImage.appImage(asset: .star)
        settings.emptyImage = UIImage.appImage(asset: .emptyStar)
    }
    
    private func bind() {
        didFinishTouchingCosmos = { [weak self] score in
            self?.onRatingChanged?(score)
        }
    }
}
