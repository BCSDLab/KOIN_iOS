//
//  EditLostItemCategoryView.swift
//  koin
//
//  Created by 홍기정 on 1/22/26.
//

import UIKit
import Combine

final class EditLostItemCategoryView: UIView {
    
    // MARK: - Properties
    @Published private(set) var selectedCategory: String = ""
    private var subscriptions: Set<AnyCancellable> = []
    let dismissDropDownPublisher = PassthroughSubject<Void, Never>()
    
    // MARK: - UI Components
    private let categoryLabel = UILabel().then {
        $0.font = .appFont(.pretendardMedium, size: 14)
        $0.textColor = .appColor(.neutral800)
        $0.text = "품목"
    }
    private let categoryMessageLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardRegular, size: 12)
        $0.textColor = UIColor.appColor(.gray)
        $0.text = "품목을 선택해주세요."
    }
    
    private let categoryStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .fill
        $0.distribution = .equalSpacing
        $0.spacing = 8
    }
    private lazy var cardButton = EditLostItemButton(title: "카드")
    private lazy var idButton = EditLostItemButton(title: "신분증")
    private lazy var walletButton = EditLostItemButton(title: "지갑")
    private lazy var electronicsButton = EditLostItemButton(title: "전자제품")
    private lazy var ectButton = EditLostItemButton(title: "그 외")
    
    // MARK: - Initializer
    init(selectedCategory: String) {
        super.init(frame: .zero)
        configureView()
        setAddTargets()
        bind()
        self.selectedCategory = selectedCategory
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension EditLostItemCategoryView {
    
    private func bind() {
        $selectedCategory.sink { [weak self] selectedCategory in
            guard let self else { return }
            cardButton.isSelected = selectedCategory == cardButton.title
            idButton.isSelected = selectedCategory == idButton.title
            walletButton.isSelected = selectedCategory == walletButton.title
            electronicsButton.isSelected = selectedCategory == electronicsButton.title
            ectButton.isSelected = selectedCategory == ectButton.title
        }.store(in: &subscriptions)
    }
    
    private func setAddTargets() {
        cardButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        idButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        walletButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        electronicsButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        ectButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
    }
    
    @objc private func buttonTapped(_ sender: EditLostItemButton) {
        selectedCategory = sender.title
        dismissDropDownPublisher.send()
        endEditing(true)
    }
}

extension EditLostItemCategoryView {
    
    private func setUpLayouts() {
        [cardButton, idButton, walletButton, electronicsButton, ectButton].forEach {
            categoryStackView.addArrangedSubview($0)
        }
        [categoryLabel, categoryMessageLabel, categoryStackView].forEach {
            addSubview($0)
        }
    }
    private func setUpConstraints() {
        categoryLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
            $0.height.equalTo(22)
        }
        categoryMessageLabel.snp.makeConstraints {
            $0.top.equalTo(categoryLabel.snp.bottom)
            $0.leading.equalToSuperview()
            $0.height.equalTo(19)
        }
        categoryStackView.snp.makeConstraints {
            $0.top.equalTo(categoryMessageLabel.snp.bottom).offset(12)
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(38)
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
    }
}
