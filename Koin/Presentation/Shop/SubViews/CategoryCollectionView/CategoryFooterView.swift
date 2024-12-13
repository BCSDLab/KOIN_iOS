//
//  CategoryFooterView.swift
//  koin
//
//  Created by 김나훈 on 12/12/24.
//

import Combine
import UIKit

final class CategoryFooterView: UICollectionReusableView {
    
    static let identifier = "CategoryFooterView"

    let publisher = PassthroughSubject<Void, Never>()
    private var subscriptions = Set<AnyCancellable>() // 구독
    private let button: UIButton = {
        let button = UIButton()
        button.setTitle("혜택이 있는 상점 모아보기", for: .normal)
        button.titleLabel?.font = UIFont.appFont(.pretendardMedium, size: 12)
        button.setTitleColor(UIColor.appColor(.neutral500), for: .normal)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    override func prepareForReuse() {
           super.prepareForReuse()
           subscriptions.removeAll() // 재사용 시 기존 구독 취소
       }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    @objc private func buttonTapped() {
        publisher.send()
    }
    
    private func setupViews() {
        
        [button].forEach { component in
            addSubview(component)
        }
        button.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.width.equalTo(123)
            make.height.equalTo(20)
        }
    }

}
