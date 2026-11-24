//
//  ZoomableImageView.swift
//  koin
//
//  Created by 홍기정 on 11/24/26.
//

import Combine
import Kingfisher
import UIKit

final class ZoomableImageView: UIScrollView {

    // MARK: - Properties

    @Published private(set) var isZoomed = false
    @Published private(set) var fittedImageFrame: CGRect = .zero
    private var lastBoundsSize: CGSize = .zero
    private let maximumZoomFactor: CGFloat = 3

    // MARK: - UI Components

    private let imageView = UIImageView()

    // MARK: - Initializer

    init() {
        super.init(frame: .zero)
        delegate = self
        contentInsetAdjustmentBehavior = .never
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        decelerationRate = .fast
        addSubview(imageView)

        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        doubleTapGesture.numberOfTapsRequired = 2
        addGestureRecognizer(doubleTapGesture)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        guard bounds.size != lastBoundsSize else { return }
        lastBoundsSize = bounds.size
        updateZoomScales()
    }

    // MARK: - Configure

    func setImage(_ image: UIImage?) {
        imageView.image = image
        resetImageLayout()
    }

    func setImage(url: String) {
        imageView.kf.setImage(with: URL(string: url), completionHandler: { [weak self] result in
            if case .failure(let error) = result, error.isNotCurrentTask { return }
            self?.resetImageLayout()
        })
    }

    func resetZoom() {
        setZoomScale(minimumZoomScale, animated: false)
    }
}

extension ZoomableImageView {

    private func resetImageLayout() {
        minimumZoomScale = 1
        maximumZoomScale = 1
        zoomScale = 1
        let imageSize = imageView.image?.size ?? .zero
        imageView.frame = CGRect(origin: .zero, size: imageSize)
        contentSize = imageSize
        updateZoomScales()
    }

    private func updateZoomScales() {
        guard let imageSize = imageView.image?.size,
              imageSize.width > 0, imageSize.height > 0,
              bounds.width > 0, bounds.height > 0 else {
            fittedImageFrame = CGRect(origin: .zero, size: bounds.size)
            return
        }
        let fitScale = min(bounds.width / imageSize.width, bounds.height / imageSize.height)
        minimumZoomScale = fitScale
        maximumZoomScale = fitScale * maximumZoomFactor
        zoomScale = fitScale
        centerImage()
        contentOffset = CGPoint(x: -contentInset.left, y: -contentInset.top)
        isZoomed = false

        let fittedSize = CGSize(width: imageSize.width * fitScale, height: imageSize.height * fitScale)
        fittedImageFrame = CGRect(
            x: (bounds.width - fittedSize.width) / 2,
            y: (bounds.height - fittedSize.height) / 2,
            width: fittedSize.width,
            height: fittedSize.height
        )
    }

    private func centerImage() {
        let horizontalInset = max((bounds.width - contentSize.width) / 2, 0)
        let verticalInset = max((bounds.height - contentSize.height) / 2, 0)
        contentInset = UIEdgeInsets(top: verticalInset, left: horizontalInset, bottom: verticalInset, right: horizontalInset)
    }

    @objc private func doubleTapped(_ gesture: UITapGestureRecognizer) {
        guard imageView.image != nil else { return }
        if isZoomed {
            setZoomScale(minimumZoomScale, animated: true)
            return
        }
        let point = gesture.location(in: imageView)
        let zoomSize = CGSize(width: bounds.width / maximumZoomScale, height: bounds.height / maximumZoomScale)
        let zoomRect = CGRect(
            x: point.x - zoomSize.width / 2,
            y: point.y - zoomSize.height / 2,
            width: zoomSize.width,
            height: zoomSize.height
        )
        zoom(to: zoomRect, animated: true)
    }
}

extension ZoomableImageView: UIScrollViewDelegate {

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerImage()
        isZoomed = zoomScale != minimumZoomScale
    }
}
