//
//  ZoomedImageViewController.swift
//  koin
//
//  Created by 김나훈 on 4/8/24.
//

import Combine
import SnapKit
import UIKit

final class ZoomedImageViewController: UIViewController {

    // MARK: - Properties

    private var subscriptions: Set<AnyCancellable> = []
    private var initialTouchPoint = CGPoint.zero
    private let closeButtonSize: CGFloat = 24
    private let closeButtonSpacing: CGFloat = 8

    // MARK: - UI Components

    private let zoomableImageView = ZoomableImageView().then {
        $0.clipsToBounds = false
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

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        additionalSafeAreaInsets.top = closeButtonSize + closeButtonSpacing
        configureView()
        bind()
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(panGestureDismiss)))
    }

    func setImage(_ image: UIImage?) {
        zoomableImageView.setImage(image)
    }

    func setImage(url: String) {
        zoomableImageView.setImage(url: url)
    }
}

extension ZoomedImageViewController {

    private func configureView() {
        view.backgroundColor = .appColor(.neutral800)
        view.addSubview(zoomableImageView)
        view.addSubview(closeButton)

        zoomableImageView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }

        closeButton.snp.makeConstraints { make in
            make.width.height.equalTo(closeButtonSize)
            make.trailing.equalTo(zoomableImageView.snp.leading)
            make.bottom.equalTo(zoomableImageView.snp.top).offset(-closeButtonSpacing)
        }
    }

    private func bind() {
        zoomableImageView.$fittedImageFrame
            .sink { [weak self] fittedImageFrame in
                self?.updateCloseButtonPosition(fittedImageFrame)
            }
            .store(in: &subscriptions)

        zoomableImageView.$isZoomed
            .removeDuplicates()
            .sink { [weak self] isZoomed in
                UIView.animate(
                    withDuration: isZoomed ? 0.1 : 0.2,
                    delay: 0,
                    options: [.overrideInheritedDuration, .overrideInheritedCurve]
                ) {
                    self?.closeButton.alpha = isZoomed ? 0 : 1
                }
            }
            .store(in: &subscriptions)
    }

    private func updateCloseButtonPosition(_ fittedImageFrame: CGRect) {
        closeButton.snp.updateConstraints { make in
            make.trailing.equalTo(zoomableImageView.snp.leading).offset(fittedImageFrame.maxX)
            make.bottom.equalTo(zoomableImageView.snp.top).offset(fittedImageFrame.minY - closeButtonSpacing)
        }
    }

    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }

    @objc private func panGestureDismiss(_ sender: UIPanGestureRecognizer) {
        let touchPoint = sender.location(in: view.window)
        switch sender.state {
        case .began:
            initialTouchPoint = touchPoint
        case .changed, .ended, .cancelled:
            guard !zoomableImageView.isZoomed,
                  50 < touchPoint.y - initialTouchPoint.y else { return }
            dismiss(animated: true)
        default:
            return
        }
    }
}
