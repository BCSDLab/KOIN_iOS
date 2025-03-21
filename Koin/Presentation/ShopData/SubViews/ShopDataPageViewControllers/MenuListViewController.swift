//
//  MenuListViewControllers.swift
//  koin
//
//  Created by 김나훈 on 7/6/24.
//

import Combine
import UIKit

final class MenuListViewController: UIViewController {
    
    // MARK: - Properties
    let viewControllerHeightPublisher = PassthroughSubject<CGFloat, Never>()
    
    // MARK: - UI Components
    let menuListCollectionView = MenuListCollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout().then {
        $0.minimumLineSpacing = 0
        $0.itemSize = CGSize(width: UIScreen.main.bounds.width - 48, height: 88)
        $0.scrollDirection = .vertical
    }).then {
        $0.isScrollEnabled = false
    }
    
    let buttonStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .equalSpacing
        $0.alignment = .fill
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    func setMenuCategories(shopMenuList: [MenuCategory]) {
        menuListCollectionView.setMenuCategories(shopMenuList)
        menuListCollectionView.snp.updateConstraints { make in
            make.height.equalTo(menuListCollectionView.calculateDynamicHeight())
        }
        
        viewControllerHeightPublisher.send(buttonStackView.frame.height + 9 + menuListCollectionView.calculateDynamicHeight())
    }
}

extension MenuListViewController {
    private func setUpLayOuts() {
        [buttonStackView, menuListCollectionView].forEach {
            view.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        
        buttonStackView.snp.makeConstraints { make in
            make.top.equalTo(view.snp.top).offset(9)
            make.leading.equalTo(view.snp.leading).offset(16)
            make.trailing.equalTo(view.snp.trailing).offset(-16)
            make.height.equalTo(32)
        }
        
        menuListCollectionView.snp.makeConstraints { make in
            make.top.equalTo(buttonStackView.snp.bottom)
            make.leading.equalTo(view.snp.leading)
            make.trailing.equalTo(view.snp.trailing)
            make.height.equalTo(1)
        }
        
    }
    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
        self.view.backgroundColor = .systemBackground
    }
    
}
