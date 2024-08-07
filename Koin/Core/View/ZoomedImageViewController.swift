//
//  ImageZoomViewController.swift
//  koin
//
//  Created by 김나훈 on 4/8/24.
//

import Combine
import UIKit

class ZoomedImageViewController: UIViewController, UIScrollViewDelegate {
    
    // MARK: - Properties
    private var imageWidth: CGFloat
    private var imageHeight: CGFloat
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 6.0
        scrollView.backgroundColor = .clear
        return scrollView
    }()
    
    private let zoomingView: ZoomingView = {
        let zoomingView = ZoomingView()
        return zoomingView
    }()
    
    // MARK: - Initialization
    
    init(imageWidth: CGFloat, imageHeight: CGFloat) {
        self.imageWidth = imageWidth
        self.imageHeight = imageHeight
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve
        configureView()
        scrollView.delegate = self
        zoomingView.closeButtonPublisher.sink { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }.store(in: &cancellables)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateZoomScaleForSize(view.bounds.size)
    }
    
    private func configureView() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        view.addSubview(scrollView)
        scrollView.addSubview(zoomingView)
        scrollView.frame = view.bounds
        zoomingView.frame = CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight)
        scrollView.contentSize = zoomingView.frame.size
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return zoomingView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let offsetX = max((scrollView.bounds.width - scrollView.contentSize.width) * 0.5, 0)
        let offsetY = max((scrollView.bounds.height - scrollView.contentSize.height) * 0.5, 0)
        scrollView.contentInset = UIEdgeInsets(top: offsetY, left: offsetX, bottom: offsetY, right: offsetX)
    }
    
    //손을 떼면 다시 줌 아웃되게 구현
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
            UIView.animate(withDuration: 0.3) {
                self.scrollView.setZoomScale(0, animated: true)
            }
    }
    
    func setImage(_ image: UIImage?) {
        zoomingView.setImage(image)
        if let image = image {
            let widthScale = imageWidth / image.size.width
            let heightScale = imageHeight / image.size.height
            let initialScale = min(widthScale, heightScale)
            
            scrollView.setZoomScale(initialScale, animated: false)
            scrollView.minimumZoomScale = initialScale
        }
        
        updateZoomScaleForSize(view.bounds.size)
    }
    
    func setImages(_ images: [UIImage?]) {
        let imageList = images.compactMap { $0 }
        zoomingView.setImages(imageList)
        if let firstImage = imageList.first {
            let widthScale = imageWidth / firstImage.size.width
            let heightScale = imageHeight / firstImage.size.height
            let initialScale = min(widthScale, heightScale)
            
            scrollView.setZoomScale(initialScale, animated: false)
            scrollView.minimumZoomScale = initialScale
        }
        updateZoomScaleForSize(view.bounds.size)
    }
    
    private func updateZoomScaleForSize(_ size: CGSize) {
        
        scrollView.minimumZoomScale = 1
        scrollViewDidZoom(scrollView)
        
    }
}
