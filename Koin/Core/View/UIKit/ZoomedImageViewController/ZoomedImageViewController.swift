//
//  ZoomedImageViewController.swift
//  koin
//
//  Created by 김나훈 on 4/8/24.
//

import SnapKit
import UIKit

final class ZoomedImageViewController: UIViewController {

    // MARK: - Properties

    private var imageRatioConstraint: Constraint?

    // MARK: - UI Components

    private let scrollView = UIScrollView().then {
        $0.minimumZoomScale = 1.0
        $0.maximumZoomScale = 6.0
        $0.clipsToBounds = false
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
    }

    private let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }

    private let closeButton = UIButton().then {
        $0.setImage(UIImage.appImage(asset: .cancel), for: .normal)
    }

    // MARK: - Initialize

    init() {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
        modalTransitionStyle = .coverVertical
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        updateImageRatio()
        scrollView.delegate = self
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard scrollView.zoomScale == scrollView.minimumZoomScale else { return }
        imageView.frame = CGRect(origin: .zero, size: scrollView.bounds.size)
        scrollView.contentSize = scrollView.bounds.size
    }

    func setImage(_ image: UIImage?) {
        imageView.image = image
        updateImageRatio()
    }
}

extension ZoomedImageViewController {

    private func configureView() {
        view.backgroundColor = .black
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        view.addSubview(closeButton)

        scrollView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
            make.top.greaterThanOrEqualTo(view.safeAreaLayoutGuide.snp.top).offset(24)
            make.bottom.lessThanOrEqualTo(view.safeAreaLayoutGuide.snp.bottom)
        }

        closeButton.snp.makeConstraints { make in
            make.width.height.equalTo(24)
            make.bottom.equalTo(scrollView.snp.top).offset(-8)
            make.trailing.equalTo(scrollView)
        }
    }

    private func updateImageRatio() {
        let size = imageView.image?.size ?? .zero
        let ratio = size.width > 0 ? size.height / size.width : 1
        imageRatioConstraint?.deactivate()
        scrollView.snp.makeConstraints { make in
            imageRatioConstraint = make.height.equalTo(scrollView.snp.width).multipliedBy(ratio).priority(.high).constraint
        }
    }

    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
}

extension ZoomedImageViewController: UIScrollViewDelegate {

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }

    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
    }
}
