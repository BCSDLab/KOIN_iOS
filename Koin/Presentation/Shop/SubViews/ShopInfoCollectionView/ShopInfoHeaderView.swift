////
////  ShopInfoHeaderView.swift
////  koin
////
////  Created by 김나훈 on 8/14/24.
////
//
//import Combine
//import UIKit
//
//final class ShopInfoHeaderView: UICollectionReusableView {
//    
//    static let identifier = "ShopInfoHeaderView"
//    let shopSortStandardPublisher = PassthroughSubject<Any, Never>()
//    let shopFilterTogglePublisher = PassthroughSubject<Int, Never>()
//    private var toggleClickList = [false, false, false, false]
//    
//    private let buttonStackView: UIStackView = {
//        let stackView = UIStackView()
//        stackView.backgroundColor = UIColor.appColor(.neutral0)
//        stackView.axis = .horizontal
//        stackView.distribution = .equalSpacing
//        stackView.alignment = .fill
//        return stackView
//    }()
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupViews()
//        addButtonItems()
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    func updateButtonState(_ standard: FetchShopListRequest) {
//        
//        for case let button as UIButton in buttonStackView.arrangedSubviews {
//            let isSelected: Bool
//            switch button.tag {
//            case 0: isSelected = standard.sorter == .count
//            case 1: isSelected = standard.sorter == .rating
//            case 2: isSelected = standard.filter.contains(.open)
//            default: isSelected = standard.filter.contains(.delivery)
//            }
//            button.layer.borderColor = isSelected ? UIColor.appColor(.primary300).cgColor : UIColor.appColor(.neutral300).cgColor
//            button.setTitleColor(isSelected ? UIColor.appColor(.primary300) : UIColor.appColor(.neutral300), for: .normal)
//            
//        }
//        
//    }
//    
//    private func setupViews() {
//        
//        [buttonStackView].forEach { component in
//            addSubview(component)
//        }
//        buttonStackView.snp.makeConstraints { make in
//            make.edges.equalToSuperview()
//        }
//    }
//    private func addButtonItems() {
//        let categories = ["▼ 리뷰순", "▼ 별점순", "# 영업중", "# 배달 가능"]
//        let widthSize: CGFloat = 76.25
//        
//        for (index, categoryTitle) in categories.enumerated() {
//            let button = UIButton(type: .system)
//            configureButton(button: button, title: categoryTitle, width: widthSize, tag: index)
//            buttonStackView.addArrangedSubview(button)
//        }
//    }
//    private func configureButton(button: UIButton, title: String, width: CGFloat, tag: Int) {
//        button.layer.borderWidth = 1.0
//        button.clipsToBounds = true
//        button.layer.cornerRadius = 5
//   //     button.tintColor = .clear
//        button.tag = tag
//        button.titleLabel?.font = UIFont.appFont(.pretendardRegular, size: 12)
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.widthAnchor.constraint(equalToConstant: width).isActive = true
//        button.heightAnchor.constraint(equalToConstant: 25).isActive = true
//        button.addTarget(self, action: #selector(sortTypeButtonTapped(_:)), for: .touchUpInside)
//        button.layer.borderColor = UIColor.appColor(.neutral300).cgColor
//        button.layer.borderWidth = 1.0
//        button.setTitleColor(UIColor.appColor(.neutral300), for: .normal) 
//        button.setTitle(title, for: .normal)
//    }
//    
//    @objc private func sortTypeButtonTapped(_ sender: UIButton) {
//        let originalFilterList = toggleClickList
//        switch sender.tag {
//        case 0: 
//            shopSortStandardPublisher.send(FetchShopSortType.count)
//            toggleClickList[0].toggle()
//            if toggleClickList[0] == true && toggleClickList[1] == true {
//                toggleClickList[1] = false
//            }
//        case 1:
//            shopSortStandardPublisher.send(FetchShopSortType.rating)
//            toggleClickList[1].toggle()
//            if toggleClickList[0] == true && toggleClickList[1] == true {
//                toggleClickList[0] = false
//            }
//        case 2:
//            shopSortStandardPublisher.send(FetchShopFilterType.open)
//            toggleClickList[2].toggle()
//        default:
//            shopSortStandardPublisher.send(FetchShopFilterType.delivery)
//            toggleClickList[3].toggle()
//        }
//        for (index, value) in toggleClickList.enumerated() {
//            if originalFilterList[index] != value && value == true {
//                shopFilterTogglePublisher.send(index)
//            }
//        }
//    }
//}
