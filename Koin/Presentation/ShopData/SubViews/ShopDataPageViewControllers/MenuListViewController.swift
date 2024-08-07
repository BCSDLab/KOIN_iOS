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
    
    private let menuListCollectionView: MenuListCollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 0
        flowLayout.itemSize = CGSize(width: UIScreen.main.bounds.width - 48, height: 88)
        flowLayout.scrollDirection = .vertical
        let collectionView = MenuListCollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    private let buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.alignment = .fill
        return stackView
    }()
    
    private let stickyButtonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.backgroundColor = UIColor.appColor(.neutral0)
        stackView.axis = .horizontal
        stackView.isHidden = true
        stackView.distribution = .equalSpacing
        stackView.alignment = .fill
        return stackView
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        addButtonItems()
    }
    
    func setMenuCategories(shopMenuList: [MenuCategory]) {
        menuListCollectionView.setMenuCategories(shopMenuList)
        menuListCollectionView.snp.updateConstraints { make in
            make.height.equalTo(menuListCollectionView.calculateDynamicHeight())
        }
        
        viewControllerHeightPublisher.send(buttonStackView.frame.height + 9 + menuListCollectionView.calculateDynamicHeight())
    }
    
//    private func scrollToMenuSection(at section: Int) {
//        let indexPath = IndexPath(row: 0, section: section)
//        guard let attributes = menuListCollectionView.layoutAttributesForItem(at: indexPath) else { return }
//        
//        let scrollViewSpacing: CGFloat = stickyButtonStackView.isHidden ? 150 : 140
//        
//        let itemOffset = attributes.frame.origin.y + menuListCollectionView.frame.origin.y - scrollView.contentInset.top - buttonStackView.frame.height - scrollViewSpacing
//        if #available(iOS 17.0, *) {
//            UIView.animate {
//                scrollView.setContentOffset(CGPoint(x: 0, y: itemOffset), animated: false)
//            }
//        } else {
//            scrollView.setContentOffset(CGPoint(x: 0, y: itemOffset), animated: false)
//        }
//        
//    }
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

extension MenuListViewController {
    private func addButtonItems() {
        let categories = ["추천 메뉴", "메인 메뉴", "세트 메뉴", "사이드 메뉴"]
        let widthSize: [CGFloat] = [73, 73, 73, 84]
        
        for (index, categoryTitle) in categories.enumerated() {
            let button1 = UIButton(type: .system)
            configureButton(button: button1, title: categoryTitle, width: widthSize[index])
            stickyButtonStackView.addArrangedSubview(button1)
            
            let button2 = UIButton(type: .system)
            configureButton(button: button2, title: categoryTitle, width: widthSize[index])
            buttonStackView.addArrangedSubview(button2)
        }
    }
    
    private func configureButton(button: UIButton, title: String, width: CGFloat) {
        button.setTitle(title, for: .normal)
        button.layer.borderWidth = 1.0
        button.clipsToBounds = true
        button.isEnabled = false
        button.layer.cornerRadius = 4
        button.tintColor = .clear
        button.tag = -1
        button.layer.borderColor = UIColor.appColor(.neutral100).cgColor
        button.setTitleColor(UIColor.appColor(.neutral400), for: .normal)
        button.titleLabel?.font = UIFont.appFont(.pretendardMedium, size: 13)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: width).isActive = true
        button.heightAnchor.constraint(equalToConstant: 32).isActive = true
        button.addTarget(self, action: #selector(categoryButtonTapped(_:)), for: .touchUpInside)
    }
    
    @objc func categoryButtonTapped(_ sender: UIButton) {
      //  scrollToMenuSection(at: sender.tag)
        changeCategoryButtonColor(sender)
    }
    
    private func changeCategoryButtonColor(_ sender: UIButton) {
        if !sender.isSelected {
            sender.backgroundColor = UIColor.appColor(.primary500)
            sender.setTitleColor(UIColor.appColor(.neutral0), for: .normal)
            sender.layer.borderWidth = 0
            sender.isSelected = true
        }
        
        [stickyButtonStackView, buttonStackView].forEach { stackView in
            stackView.arrangedSubviews.compactMap { $0 as? UIButton }.forEach { button in
                if button.titleLabel?.text == sender.titleLabel?.text && button != sender {
                    button.backgroundColor = UIColor.appColor(.primary500)
                    button.setTitleColor(UIColor.appColor(.neutral0), for: .normal)
                    button.layer.borderWidth = 0
                    button.isSelected = true
                } else if button != sender {
                    button.backgroundColor = .systemBackground
                    button.setTitleColor(button.tag == -1 ? UIColor.appColor(.neutral400) : UIColor.appColor(.neutral500), for: .normal)
                    button.layer.borderWidth = 1.0
                    button.isSelected = false
                }
            }
        }
    }
}

