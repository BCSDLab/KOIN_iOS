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
    
    private var cancellables: Set<AnyCancellable> = []
    private var currentIndex = 0
    
    // MARK: - UI Components
    
    private let scrollView = UIScrollView().then {
        $0.minimumZoomScale = 1.0
        $0.maximumZoomScale = 6.0
        $0.backgroundColor = .clear
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
    }
    
    private let collectionView = ZoomingCollectionView()
    
    private let nextButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "arrow.right")?
            .withTintColor(UIColor.appColor(.neutral0), renderingMode: .alwaysOriginal)
        button.setImage(image, for: .normal)
        button.layer.cornerRadius = 22
        button.backgroundColor = UIColor.appColor(.neutral800).withAlphaComponent(0.5)
        return button
    }()
    
    private let prevButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "arrow.left")?
            .withTintColor(UIColor.appColor(.neutral0), renderingMode: .alwaysOriginal)
        button.setImage(image, for: .normal)
        button.layer.cornerRadius = 22
        button.backgroundColor = UIColor.appColor(.neutral800).withAlphaComponent(0.5)
        return button
    }()
    
    // MARK: - Initialize
    
    init() {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
        modalTransitionStyle = .crossDissolve
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        setupScrollView()
        bind()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if scrollView.zoomScale == scrollView.minimumZoomScale {
            centerScrollViewContents()
        }
    }
        
    func setImage(_ image: UIImage?) {
        currentIndex = 0
        collectionView.setImage(image)
        scrollView.setZoomScale(scrollView.minimumZoomScale, animated: false)
        updateButtonVisibility()
        centerScrollViewContents()
    }
    
    func setImages(_ images: [UIImage?]) {
        currentIndex = 0
        collectionView.setImages(images)
        scrollView.setZoomScale(scrollView.minimumZoomScale, animated: false)
        updateButtonVisibility()
        centerScrollViewContents()
    }
}

extension ZoomedImageViewController {
    
    private func configureView() {
        view.backgroundColor = .black
        view.addSubview(scrollView)
        scrollView.addSubview(collectionView)
        view.addSubview(nextButton)
        view.addSubview(prevButton)
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
            make.height.equalTo(scrollView.frameLayoutGuide)
        }
        
        nextButton.snp.makeConstraints { make in
            make.centerY.equalTo(view.safeAreaLayoutGuide)
            make.trailing.equalToSuperview()
            make.width.height.equalTo(44)
        }
        
        prevButton.snp.makeConstraints { make in
            make.centerY.equalTo(view.safeAreaLayoutGuide)
            make.leading.equalToSuperview()
            make.width.height.equalTo(44)
        }
    }
    
    private func setupScrollView() {
        scrollView.delegate = self
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        prevButton.addTarget(self, action: #selector(prevButtonTapped), for: .touchUpInside)
    }
    
    private func bind() {
        collectionView.closeButtonPublisher
            .sink { [weak self] in
                self?.dismiss(animated: true)
            }
            .store(in: &cancellables)
    }
    
    private func centerScrollViewContents() {
        let offsetX = max((scrollView.bounds.width - scrollView.contentSize.width) * 0.5, 0)
        let offsetY = max((scrollView.bounds.height - scrollView.contentSize.height) * 0.5, 0)
        scrollView.contentInset = UIEdgeInsets(top: offsetY, left: offsetX, bottom: offsetY, right: offsetX)
    }
    
    private func updateButtonVisibility() {
        nextButton.isHidden = currentIndex >= collectionView.imageCount - 1
        prevButton.isHidden = currentIndex <= 0
    }
    
    @objc private func nextButtonTapped() {
        if currentIndex < collectionView.imageCount - 1 {
            currentIndex += 1
            collectionView.showImage(at: currentIndex, animated: true)
        }
        updateButtonVisibility()
    }
    
    @objc private func prevButtonTapped() {
        if currentIndex > 0 {
            currentIndex -= 1
            collectionView.showImage(at: currentIndex, animated: true)
        }
        updateButtonVisibility()
    }
}

extension ZoomedImageViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        collectionView
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
