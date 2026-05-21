//
//  ShopBenefitPageControl.swift
//  koin
//
//  Created by 홍기정 on 5/19/26.
//

import UIKit

final class ShopBenefitPageControl: UIPageControl {
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        preferredIndicatorImage = makeCircleImage(
            frameSize: .init(width: 6, height: 6),
            circleSize: .init(width: 4, height: 4)
        )
        preferredCurrentPageIndicatorImage = makeCircleImage(
            frameSize: .init(width: 6, height: 6),
            circleSize: .init(width: 6, height: 6)
        )
        pageIndicatorTintColor = .appColor(.neutral300)
        currentPageIndicatorTintColor = .appColor(.new500)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    func configure(numberOfPages: Int) {
        self.numberOfPages = numberOfPages
        self.setNeedsLayout()
    }
    func configure(currentPage: Int) {
        self.currentPage = currentPage
    }
}

extension ShopBenefitPageControl {
    
    private func makeCircleImage(frameSize: CGSize, circleSize: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: frameSize)
        return renderer.image { context in
            let x = (frameSize.width - circleSize.width) / 2
            let y = (frameSize.height - circleSize.height) / 2
            let rect = CGRect(x: x, y: y, width: circleSize.width, height: circleSize.height)
            context.cgContext.fillEllipse(in: rect)
        }
    }
}
