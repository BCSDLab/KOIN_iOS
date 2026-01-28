//
//  ZoomedImageRootViewController.swift
//  koin
//
//  Created by 홍기정 on 11/14/25.
//

import UIKit
import Combine

final class ZoomedImageRootViewController: UIViewController {
    
    // MARK: - Properties
    private var subscriptions: Set<AnyCancellable> = []
    private var initialTouchPoint = CGPoint(x: 0, y: 0)
    
    // MARK: - UI Components
    private let zoomedImageCollectionView = ZoomedImageCollectionView()
    private let gradientView = UIView()
    private let gradientLayer = CAGradientLayer().then {
        $0.colors = [
            UIColor.black.withAlphaComponent(0.4).cgColor,
            UIColor.black.withAlphaComponent(0.03).cgColor,
            UIColor.black.withAlphaComponent(0.0).cgColor
        ]
        $0.locations = [0.0, 0.9, 1.0]
        $0.startPoint = CGPoint(x: 0.0, y: 0.0)
        $0.endPoint = CGPoint(x: 0.0, y: 1.0)
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setPanGestureRecognizer()
        configureView()
        configureLeftBarButton()
        bind()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar(style: .transparentWhite)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = gradientView.bounds
    }
    
    // MARK: - Configure
    func configure(urls: [String], initialIndexPath: IndexPath) {
        zoomedImageCollectionView.configure(urls: urls, initialIndexPath: initialIndexPath)
        title = "\(initialIndexPath.row+1)/\(urls.count)"
    }
    
    // MARK: - Bind
    private func bind() {
        zoomedImageCollectionView.updateTitlePublisher.sink { [weak self] title in
            self?.title = title
        }.store(in: &subscriptions)
        
        zoomedImageCollectionView.hideNavigationBarPublisher.sink { [weak self] isHidden in
            self?.navigationController?.setNavigationBarHidden(isHidden, animated: true)
        }.store(in: &subscriptions)
    }
}

extension ZoomedImageRootViewController {
    
    private func setPanGestureRecognizer() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureDismiss))
        view.addGestureRecognizer(panGesture)
    }
    
    @objc private func panGestureDismiss(_ sender: UIGestureRecognizer) {
        let touchPoint = sender.location(in: view.window)
        
        if sender.state == .began {
            initialTouchPoint = touchPoint
        }
        switch sender.state {
        case .began:
            initialTouchPoint = touchPoint
        case .changed, .ended, .cancelled:
            if 50 < touchPoint.y - initialTouchPoint.y {
                dismiss(animated: true)
            }
        default:
            return
        }
    }
}

extension ZoomedImageRootViewController {
    
    private func configureLeftBarButton() {
        let leftBarButton = UIBarButtonItem(image: .appImage(asset: .cancelNeutral500),
                                            style: .plain,
                                            target: self,
                                            action: #selector(leftBarButtonTapped))
        navigationItem.leftBarButtonItem = leftBarButton
    }
    
    @objc private func leftBarButtonTapped() {
        dismiss(animated: true)
    }
}

extension ZoomedImageRootViewController {
    
    private func configureView() {
        [zoomedImageCollectionView, gradientView].forEach {
            view.addSubview($0)
        }
        zoomedImageCollectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        gradientView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
        
        gradientView.layer.addSublayer(gradientLayer)
    }
}
