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
    
    private var xButtonWidth: CGFloat = 30
    private var xButtonHeight: CGFloat = 30
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
    
    func changeXButtonSize(width: CGFloat, height: CGFloat) {
        self.xButtonWidth = width
        self.xButtonHeight = height
    }
    
    func setUpGif(fileName: String) {
        guard let gifURL = Bundle.main.url(forResource: fileName, withExtension: "gif"),
            let gifData = try? Data(contentsOf: gifURL),
            let source = CGImageSourceCreateWithData(gifData as CFData, nil)
        else { return }
    
        let frameCount = CGImageSourceGetCount(source)
        var images = [UIImage]()

        (0..<frameCount)
            .compactMap { CGImageSourceCreateImageAtIndex(source, $0, nil) }
            .forEach { images.append(UIImage(cgImage: $0)) }
        
        DispatchQueue.main.async {
            self.imageView.animationImages = images
            self.imageView.animationDuration = TimeInterval(frameCount) * 0.05
            self.imageView.animationRepeatCount = 0
            self.imageView.startAnimating()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)
    
        let xButtonFrame = CGRect(x: self.bounds.width - xButtonWidth, y: 0, width: xButtonWidth, height: xButtonHeight)
        
        if xButtonFrame.contains(touchLocation) {
            onXButtonTapped?()
        } else {
            onImageTapped?()
        }
    }
}
