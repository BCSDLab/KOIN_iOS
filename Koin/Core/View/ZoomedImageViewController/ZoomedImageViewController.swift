//
//  ZoomedImageViewController.swift
//  koin
//
//  Created by 김나훈 on 4/8/24.
//

import Combine
import UIKit

final class ZoomedImageViewController: UIViewController {
    
    // MARK: - Properties
    
    private var imageWidth: CGFloat
    private var imageHeight: CGFloat
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    
    private let scrollView = UIScrollView().then {
        $0.minimumZoomScale = 1.0
        $0.maximumZoomScale = 6.0
        $0.backgroundColor = .clear
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
    }
    
    private let zoomingView = ZoomingView()
    
    // MARK: - Initialize
    
    init(imageWidth: CGFloat, imageHeight: CGFloat) {
        self.imageWidth = imageWidth
        self.imageHeight = imageHeight
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve
        
        configureView()
        setupScrollView()
        bind()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateZoomScaleForSize(view.bounds.size)
    }
        
    func setImage(_ image: UIImage?) {
        zoomingView.setImage(image)
        guard let image = image else { return }
        
        let widthScale = imageWidth / image.size.width
        let heightScale = imageHeight / image.size.height
        let initialScale = min(widthScale, heightScale)
        
        scrollView.minimumZoomScale = initialScale
        scrollView.setZoomScale(initialScale, animated: false)
        updateZoomScaleForSize(view.bounds.size)
    }
    
    func setImages(_ images: [UIImage?]) {
        let imageList = images.compactMap { $0 }
        zoomingView.setImages(imageList)
        
        guard let firstImage = imageList.first else { return }
        
        let widthScale = imageWidth / firstImage.size.width
        let heightScale = imageHeight / firstImage.size.height
        let initialScale = min(widthScale, heightScale)
        
        scrollView.minimumZoomScale = initialScale
        scrollView.setZoomScale(initialScale, animated: false)
        updateZoomScaleForSize(view.bounds.size)
    }
}

extension ZoomedImageViewController {
    
    private func configureView() {
        view.backgroundColor = .black
        view.addSubview(scrollView)
        scrollView.addSubview(zoomingView)
        scrollView.frame = view.bounds
        zoomingView.frame = CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight)
        scrollView.contentSize = zoomingView.frame.size
    }
    
    private func setupScrollView() {
        scrollView.delegate = self
    }
    
    private func bind() {
        zoomingView.closeButtonPublisher
            .sink { [weak self] in
                self?.dismiss(animated: true)
            }
            .store(in: &cancellables)
    }
    
    private func updateZoomScaleForSize(_ size: CGSize) {
        if scrollView.zoomScale < scrollView.minimumZoomScale {
            scrollView.zoomScale = scrollView.minimumZoomScale
        }
        centerScrollViewContents()
    }
    
    private func centerScrollViewContents() {
        let offsetX = max((scrollView.bounds.width - scrollView.contentSize.width) * 0.5, 0)
        let offsetY = max((scrollView.bounds.height - scrollView.contentSize.height) * 0.5, 0)
        scrollView.contentInset = UIEdgeInsets(top: offsetY, left: offsetX, bottom: offsetY, right: offsetX)
    }
}

// MARK: - UIScrollViewDelegate

extension ZoomedImageViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return zoomingView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerScrollViewContents()
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        UIView.animate(withDuration: 0.3) {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: false)
        }
    }
}
