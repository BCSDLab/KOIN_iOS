//
//  CancelableImageView.swift
//  koin
//
//  Created by 김나훈 on 7/29/24.
//

import UIKit

final class CancelableImageView: UIView {
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    var onXButtonTapped: (() -> Void)?
    var onImageTapped: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        addSubview(imageView)
        imageView.frame = self.bounds
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    func setUpImage(image: UIImage) {
        imageView.image = image
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)
        
        let xButtonWidth: CGFloat = 30
        let xButtonHeight: CGFloat = 30
        let xButtonFrame = CGRect(x: self.bounds.width - xButtonWidth, y: 0, width: xButtonWidth, height: xButtonHeight)
        
        if xButtonFrame.contains(touchLocation) {
            onXButtonTapped?()
        } else {
            onImageTapped?()
        }
    }
}
