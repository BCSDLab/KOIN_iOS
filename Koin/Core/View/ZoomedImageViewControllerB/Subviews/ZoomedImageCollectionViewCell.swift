//
//  ZoomedImageCollectionViewCell.swift
//  koin
//
//  Created by 홍기정 on 11/14/25.
//

import UIKit
import Combine

final class ZoomedImageCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    let hideNavigationBarPublisher = PassthroughSubject<Bool, Never>()
    
    // MARK: - UI Components
    let scrollView = UIScrollView().then {
        $0.minimumZoomScale = 1.0
        $0.maximumZoomScale = 3.0
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
    }
    let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: .zero)
        configureView()
        setDelegate()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configure
    func configure(url: String) {
        imageView.kf.setImage(
            with: URL(string: url)
        )
    }
    
    // MARK: - PrepareForReuse
    override func prepareForReuse() {
        super.prepareForReuse()
        
        scrollView.zoomScale = 1.0
        imageView.image = nil
    }
}

extension ZoomedImageCollectionViewCell: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        hideNavigationBarPublisher.send(true)
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.scrollView.zoomScale = 1.0
        }
        hideNavigationBarPublisher.send(false)
    }
}

extension ZoomedImageCollectionViewCell {
    
    private func setDelegate() {
        scrollView.delegate = self
    }
    
    private func configureView() {
        contentView.addSubview(scrollView)
        scrollView.addSubview(imageView)
        
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }
        imageView.snp.makeConstraints {
            $0.height.equalToSuperview()
            $0.width.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
    }
}
