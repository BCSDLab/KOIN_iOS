//
//  EventListViewController.swift
//  koin
//
//  Created by 김나훈 on 7/6/24.
//

import Combine
import UIKit

final class EventListViewController: UIViewController {
    
    // MARK: - Properties
    let viewControllerHeightPublisher = PassthroughSubject<CGFloat, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    private let eventListCollectionView = EventListCollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout().then {
            $0.minimumLineSpacing = 0
            $0.itemSize = CGSize(width: UIScreen.main.bounds.width - 48, height: 100)
            $0.scrollDirection = .vertical
        }
    ).then {
        $0.isScrollEnabled = false
    }
    
    private let ownerEventReadyImageView = UIImageView().then {
        $0.image = UIImage.appImage(asset: .ownerReadyEvent)
        $0.isHidden = true
    }
    
    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        bind()
    }
    
    func setEventList(_ list: [ShopEvent]) {
        eventListCollectionView.setEventList(list)
        eventListCollectionView.snp.updateConstraints { make in
            make.height.equalTo(eventListCollectionView.calculateDynamicHeight())
        }
        viewControllerHeightPublisher.send(list.isEmpty ? 500 : eventListCollectionView.calculateDynamicHeight())
        ownerEventReadyImageView.isHidden = !list.isEmpty
    }
    
    private func bind() {
        eventListCollectionView.heightChanged = { [weak self] in
            guard let strongSelf = self else { return }
            
            strongSelf.eventListCollectionView.snp.updateConstraints { make in
                make.height.equalTo(strongSelf.eventListCollectionView.calculateDynamicHeight())
            }
            strongSelf.viewControllerHeightPublisher.send(strongSelf.eventListCollectionView.calculateDynamicHeight())
        }
    
    }
}

extension EventListViewController {
    private func setUpLayOuts() {
        [eventListCollectionView, ownerEventReadyImageView].forEach {
            view.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        
        eventListCollectionView.snp.makeConstraints { make in
            make.top.equalTo(view.snp.top)
            make.leading.equalTo(view.snp.leading)
            make.trailing.equalTo(view.snp.trailing)
            make.height.equalTo(1)
        }
        
        ownerEventReadyImageView.snp.makeConstraints { make in
            make.top.equalTo(view.snp.top).offset(65)
            make.leading.equalTo(view.snp.leading).offset(66)
            make.trailing.equalTo(view.snp.trailing).offset(-66)
            make.height.equalTo(235)
        }
    }
    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
        self.view.backgroundColor = .systemBackground
    }
    
}
