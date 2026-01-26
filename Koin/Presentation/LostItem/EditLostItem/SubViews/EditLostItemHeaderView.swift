//
//  EditLostItemHeaderView.swift
//  koin
//
//  Created by 홍기정 on 1/22/26.
//

import UIKit

final class EditLostItemHeaderView: UIView {
    
    // MARK: - Properties
    private var type: LostItemType
    
    // MARK: - UI Components
    private lazy var mainMessageLabel = UILabel().then {
        $0.font = .appFont(.pretendardMedium, size: 18)
        $0.textColor = .appColor(.neutral800)
        $0.text = (type == .lost ? "물건을 찾아요" : "주인을 찾아요" )
    }
    private lazy var messageImageView = UIImageView().then {
        $0.image = (type == .lost ? .appImage(asset: .findPerson) : .appImage(asset: .lostItem))
    }
    private lazy var subMessageLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardMedium, size: 12)
        $0.textColor = UIColor.appColor(.neutral500)
        $0.text = (type == .lost ? "분실한 물건을 자세히 설명해주세요!" : "습득한 물건을 자세히 설명해주세요!" )
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
    init(type: LostItemType) {
        self.type = type
        super.init(frame: .zero)
        configureView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension EditLostItemHeaderView {
    
    private func setUpLayouts() {
        [mainMessageLabel, messageImageView, subMessageLabel, essentialLabel, essentialDescriptionLabel].forEach {
            addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        mainMessageLabel.snp.makeConstraints {
            $0.height.equalTo(29)
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalToSuperview().offset(24)
        }
        messageImageView.snp.makeConstraints {
            $0.top.equalTo(mainMessageLabel.snp.top)
            $0.leading.equalTo(mainMessageLabel.snp.trailing).offset(8)
            $0.width.height.equalTo(24)
        }
        subMessageLabel.snp.makeConstraints {
            $0.height.equalTo(19)
            $0.top.equalTo(mainMessageLabel.snp.bottom)
            $0.leading.equalToSuperview().offset(24)
            $0.bottom.equalToSuperview().offset(-12)
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
