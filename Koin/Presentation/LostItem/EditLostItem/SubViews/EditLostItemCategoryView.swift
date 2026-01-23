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
    @Published private(set) var selectedCategory: String?
    private var subscriptions: Set<AnyCancellable> = []
    let dismissDropDownPublisher = PassthroughSubject<Void, Never>()
    
    var isValid: Bool {
        categoryWarningLabel.isHidden
    }
    
    // MARK: - UI Components
    private let categoryLabel = UILabel().then {
        $0.font = .appFont(.pretendardMedium, size: 14)
        $0.textColor = .appColor(.neutral800)
        $0.text = "품목"
    }
    private let categoryWarningLabel = UILabel().then {
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = UIImage.appImage(asset: .warningOrange)
        imageAttachment.bounds = CGRect(x: 0, y: -4, width: 16, height: 16)
        let spacingAttachment = NSTextAttachment()
        spacingAttachment.bounds = CGRect(x: 0, y: 0, width: 6, height: 1)
        let attributedString = NSMutableAttributedString()
        attributedString.append(NSAttributedString(attachment: imageAttachment))
        attributedString.append(NSAttributedString(attachment: spacingAttachment))
        let text = "품목이 선택되지 않았습니다."
        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.appFont(.pretendardRegular, size: 12),
            .foregroundColor: UIColor.appColor(.sub500)
        ]
        attributedString.append(NSAttributedString(string: text, attributes: textAttributes))
        $0.attributedText = attributedString
        $0.isHidden = true
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
        
        self.selectedCategory = selectedCategory
        
        cardButton.isSelected = selectedCategory == "카드"
        idButton.isSelected = selectedCategory == "신분증"
        walletButton.isSelected = selectedCategory == "지갑"
        electronicsButton.isSelected = selectedCategory == "전자제품"
        ectButton.isSelected = selectedCategory == "그 외"
        
        configureView()
        setAddTargets()
        bind()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension EditLostItemCategoryView {
    
    private func bind() {
        $selectedCategory.sink { [weak self] selectedCategory in
            guard let self else { return }
            cardButton.isSelected = selectedCategory == "카드"
            idButton.isSelected = selectedCategory == "신분증"
            walletButton.isSelected = selectedCategory == "지갑"
            electronicsButton.isSelected = selectedCategory == "전자제품"
            ectButton.isSelected = selectedCategory == "그 외"
            
            if selectedCategory == nil {
                categoryWarningLabel.isHidden = false
            } else {
                categoryWarningLabel.isHidden = true
            }
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
        if selectedCategory == sender.title {
            selectedCategory = nil
        } else {
            selectedCategory = sender.title
        }
        dismissDropDownPublisher.send()
        endEditing(true)
    }
}

extension EditLostItemCategoryView {
    
    private func setUpLayouts() {
        [cardButton, idButton, walletButton, electronicsButton, ectButton].forEach {
            categoryStackView.addArrangedSubview($0)
        }
        [categoryLabel, categoryWarningLabel, categoryMessageLabel, categoryStackView].forEach {
            addSubview($0)
        }
    }
    private func setUpConstraints() {
        categoryLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
            $0.height.equalTo(22)
        }
        categoryWarningLabel.snp.makeConstraints {
            $0.top.trailing.equalToSuperview()
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
