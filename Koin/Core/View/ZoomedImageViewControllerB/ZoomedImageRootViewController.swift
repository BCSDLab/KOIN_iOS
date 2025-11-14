//
//  ZoomedImageViewControllerB.swift
//  koin
//
//  Created by 홍기정 on 11/14/25.
//

import UIKit
import Combine

final class ZoomedImageRootViewController: UIViewController {
    
    // MARK: - Properties
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    private let zommedImageCollectionView = ZoomedImageCollectionView()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureLeftBarButton()
        bind()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar(style: .fill)
    }
    
    // MARK: - Configure
    func configure(urls: [String], initialIndexPath: IndexPath) {
        zommedImageCollectionView.configure(urls: urls, initialIndexPath: initialIndexPath)
        title = "\(initialIndexPath.row+1)/\(urls.count)"
    }
    
    // MARK: - Bind
    private func bind() {
        zommedImageCollectionView.updateTitlePublisher.sink { [weak self] title in
            self?.title = title
        }.store(in: &subscriptions)
        
        zommedImageCollectionView.hideNavigationBarPublisher.sink { [weak self] isHidden in
            self?.navigationController?.navigationBar.isHidden = isHidden
        }.store(in: &subscriptions)
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
        view.addSubview(zommedImageCollectionView)
        zommedImageCollectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve
    }
}
