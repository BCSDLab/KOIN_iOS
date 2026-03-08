//
//  CallVanPostParticipantsView.swift
//  koin
//
//  Created by 홍기정 on 3/5/26.
//

import UIKit
import Combine
import SnapKit
import Then

final class CallVanPostParticipantsView: UIView {
    
    // MARK: - Properties
    let participantsChangedPublisher = PassthroughSubject<Int, Never>()
    
    // MARK: - UI Components
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let wrapperView = UIView()
    private let participantsLabel = UILabel()
    private let minusButton = UIButton()
    private let numberOfParticipantsLabel = UILabel()
    private let separatorView = UIView()
    private let plusButton = UIButton()
    
    // MARK: - Initializer
    init() {
        super.init(frame: .zero)
        configureView()
        setAddTargets()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    func update(numberOfParticipants: Int) {
        participantsLabel.text = "\(numberOfParticipants) 명"
        numberOfParticipantsLabel.text = "\(numberOfParticipants)"
        participantsChangedPublisher.send(numberOfParticipants)
    }
}

extension CallVanPostParticipantsView {
    
    private func setAddTargets() {
        plusButton.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
        minusButton.addTarget(self, action: #selector(minusButtonTapped), for: .touchUpInside)
    }
    
    @objc private func plusButtonTapped() {
        if let numberOfParticipantsString = numberOfParticipantsLabel.text,
           let numberOfParticipantsInt = Int(numberOfParticipantsString) {
            update(numberOfParticipants: min(numberOfParticipantsInt + 1, 8))
        }
    }
    
    @objc private func minusButtonTapped() {
        if let numberOfParticipantsString = numberOfParticipantsLabel.text,
           let numberOfParticipantsInt = Int(numberOfParticipantsString) {
            update(numberOfParticipants: max(numberOfParticipantsInt - 1, 1))
        }
    }
}

extension CallVanPostParticipantsView {
    
    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }
    
    private func setUpStyles() {
        titleLabel.do {
            $0.text = "참여 인원"
            $0.font = UIFont.appFont(.pretendardMedium, size: 16)
            $0.textColor = UIColor.appColor(.new500)
        }
        descriptionLabel.do {
            let semiBoldText = "본인을 포함한 "
            let regularText = "참여 인원 수를 선택해주세요."
            let fullText = semiBoldText + regularText
            let attributedText = NSMutableAttributedString(string: fullText, attributes: [
                .foregroundColor : UIColor.appColor(.neutral500)
            ])
            let semiBoldRange = (fullText as NSString).range(of: semiBoldText)
            attributedText.addAttributes([
                .font : UIFont.appFont(.pretendardSemiBold, size: 12)
            ], range: semiBoldRange)
            let regularTextRange = (fullText as NSString).range(of: regularText)
            attributedText.addAttributes([
                .font : UIFont.appFont(.pretendardRegular, size: 12)
            ], range: regularTextRange)
            $0.attributedText = attributedText
        }
        wrapperView.do {
            $0.layer.cornerRadius = 4
            $0.layer.borderColor = UIColor.appColor(.neutral400).cgColor
            $0.layer.borderWidth = 1
        }
        participantsLabel.do {
            $0.font = UIFont.appFont(.pretendardRegular, size: 14)
            $0.textColor = UIColor.appColor(.neutral800)
        }
        minusButton.do {
            $0.setImage(UIImage.appImage(asset: .callVanMinus)?.withRenderingMode(.alwaysTemplate), for: .normal)
            $0.tintColor = UIColor.appColor(.new500)
            $0.layer.borderColor = UIColor.appColor(.neutral400).cgColor
            $0.layer.borderWidth = 1
        }
        numberOfParticipantsLabel.do {
            $0.font = UIFont.appFont(.pretendardRegular, size: 14)
            $0.textColor = UIColor.appColor(.neutral800)
            $0.textAlignment = .center
        }
        separatorView.do {
            $0.backgroundColor = UIColor.appColor(.neutral400)
        }
        plusButton.do {
            $0.setImage(UIImage.appImage(asset: .callVanPlus)?.withRenderingMode(.alwaysTemplate), for: .normal)
            $0.tintColor = UIColor.appColor(.new500)
        }
    }
    
    private func setUpLayouts() {
        [titleLabel, descriptionLabel, wrapperView, participantsLabel, plusButton, numberOfParticipantsLabel, separatorView, minusButton].forEach {
            addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        titleLabel.snp.makeConstraints {
            $0.height.equalTo(26)
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalToSuperview().offset(24)
        }
        descriptionLabel.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.leading.equalTo(titleLabel.snp.trailing).offset(8)
        }
        
        wrapperView.snp.makeConstraints {
            $0.height.equalTo(38)
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.bottom.equalToSuperview().offset(-12)
        }
        participantsLabel.snp.makeConstraints {
            $0.centerY.equalTo(wrapperView)
            $0.leading.equalTo(wrapperView).offset(16)
        }
        plusButton.snp.makeConstraints {
            $0.width.equalTo(40)
            $0.top.bottom.trailing.equalTo(wrapperView)
        }
        separatorView.snp.makeConstraints {
            $0.top.bottom.equalTo(wrapperView)
            $0.width.equalTo(1)
            $0.trailing.equalTo(plusButton.snp.leading)
        }
        numberOfParticipantsLabel.snp.makeConstraints {
            $0.width.equalTo(55)
            $0.top.bottom.equalTo(wrapperView)
            $0.trailing.equalTo(separatorView.snp.leading)
        }
        minusButton.snp.makeConstraints {
            $0.width.equalTo(40)
            $0.top.bottom.equalTo(wrapperView)
            $0.trailing.equalTo(numberOfParticipantsLabel.snp.leading)
        }
    }
}
