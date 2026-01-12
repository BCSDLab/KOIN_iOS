////
////  CategoryFooterView.swift
////  koin
////
////  Created by 김나훈 on 12/12/24.
////
//
//import Combine
//import UIKit
//
//final class CategoryFooterView: UICollectionReusableView {
//    
//    static let identifier = "CategoryFooterView"
//
//    let buttonTapPublisher = PassthroughSubject<Void, Never>()
//    
//    private let benefitButton: UIButton = {
//        let button = UIButton()
//        button.setTitle("혜택이 있는 상점 모아보기", for: .normal)
//        button.titleLabel?.font = UIFont.appFont(.pretendardMedium, size: 12)
//        button.setTitleColor(UIColor.appColor(.neutral500), for: .normal)
//        return button
//    }()
//    
//    private let separateView1 = UIView().then {
//        $0.backgroundColor = UIColor.appColor(.neutral300)
//    }
//    
//    private let separateView2 = UIView().then {
//        $0.backgroundColor = UIColor.appColor(.neutral300)
//    }
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupViews()
//        benefitButton.addTarget(self, action: #selector(benefitButtonTapped), for: .touchUpInside)
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    @objc private func benefitButtonTapped() {
//        buttonTapPublisher.send()
//    }
//    
//    private func setupViews() {
//        
//        [benefitButton, separateView1, separateView2].forEach { component in
//            addSubview(component)
//        }
//        benefitButton.snp.makeConstraints { make in
//            make.edges.equalToSuperview()
//        }
//        separateView1.snp.makeConstraints { make in
//            make.top.leading.trailing.equalToSuperview()
//            make.height.equalTo(0.5)
//        }
//        separateView2.snp.makeConstraints { make in
//            make.bottom.leading.trailing.equalToSuperview()
//            make.height.equalTo(0.5)
//        }
//    }
//
//}
