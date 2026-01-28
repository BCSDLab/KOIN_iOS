//
//  AddLostItemHeaderView.swift
//  koin
//
//  Created by 홍기정 on 1/24/26.
//

import UIKit

final class AddLostItemHeaderView: UICollectionReusableView {
    
    static let identifier = "AddLostItemHeaderView"
    
    // MARK: - UI Components
    private let mainMessageLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardMedium, size: 18)
    }
    
    private let messageImageView = UIImageView().then { _ in
    }
    
    private let subMessageLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardMedium, size: 12)
        $0.textColor = UIColor.appColor(.neutral500)
    }
    
    private let essentialLabel = UILabel().then {
        $0.attributedText = NSAttributedString(
            string: "*",
            attributes: [
                .font: UIFont.appFont(.pretendardRegular, size: 11),
                .foregroundColor : UIColor(hexCode: "C82A2A")
            ]
        )
    }
    private let essentialDescriptionLabel = UILabel().then {
        $0.attributedText = NSAttributedString(
            string: " 표시는 필수 입력항목입니다.",
            attributes: [
                .font: UIFont.appFont(.pretendardRegular, size: 11),
                .foregroundColor : UIColor.appColor(.neutral800)
            ]
        )
    }
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(type: LostItemType) {
        switch type {
        case .found:
            mainMessageLabel.text = "주인을 찾아요"
            messageImageView.image = UIImage.appImage(asset: .findPerson)
            subMessageLabel.text = "습득한 물건을 자세히 설명해주세요!"
        case .lost:
            mainMessageLabel.text = "잃어버렸어요"
            messageImageView.image = UIImage.appImage(asset: .lostItem)
            subMessageLabel.text = "분실한 물건을 자세히 설명해주세요!"
        }
    }
}

extension AddLostItemHeaderView {
    
    
    private func setUpLayouts() {
        [mainMessageLabel, messageImageView, subMessageLabel, essentialDescriptionLabel, essentialLabel].forEach {
            addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        mainMessageLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalToSuperview().offset(24)
            $0.height.equalTo(29)
        }
        messageImageView.snp.makeConstraints {
            $0.top.equalTo(mainMessageLabel.snp.top)
            $0.leading.equalTo(mainMessageLabel.snp.trailing).offset(8)
            $0.width.height.equalTo(24)
        }
        subMessageLabel.snp.makeConstraints {
            $0.top.equalTo(mainMessageLabel.snp.bottom)
            $0.leading.equalTo(mainMessageLabel.snp.leading)
            $0.height.equalTo(19)
        }
        
        essentialDescriptionLabel.snp.makeConstraints {
            $0.height.equalTo(19)
            $0.top.equalTo(mainMessageLabel.snp.bottom)
            $0.trailing.equalToSuperview().offset(-24)
            $0.bottom.equalToSuperview().offset(-12)
        }
        essentialLabel.snp.makeConstraints {
            $0.height.equalTo(19)
            $0.top.equalTo(mainMessageLabel.snp.bottom)
            $0.trailing.equalTo(essentialDescriptionLabel.snp.leading)
            $0.bottom.equalToSuperview().offset(-12)
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
    }
}
