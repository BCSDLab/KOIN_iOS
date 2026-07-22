//
//  CallVanView.swift
//  koin
//
//  Created by 홍기정 on 3/8/26.
//

import UIKit
import Combine
import SnapKit
import Then

final class CallVanView: UIView {
    //MARK: - Properties
    let findButtonTappedPublisher = PassthroughSubject<Void, Never>()
    let postButtonTappedPublisher = PassthroughSubject<Void, Never>()
    
    //MARK: - UI Components
    private let titleLabel = UILabel()
    private let findButton = UIButton()
    private let findTitleLabel = UILabel()
    private let findDescriptionLabel = UILabel()
    private let findRightArrowImageView = UIImageView()
    private let postButton = UIButton()
    private let postTitleLabel = UILabel()
    private let postDescriptionLabel = UILabel()
    private let postRightArrowImageView = UIImageView()
    
    private let buttonsLayoutGuide = UILayoutGuide()
    
    //MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: .zero)
        configureView()
        setAddTargets()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CallVanView {
    
    private func setAddTargets() {
        findButton.addTarget(self, action: #selector(findButtonTapped), for: .touchUpInside)
        postButton.addTarget(self, action: #selector(postButtonTapped), for: .touchUpInside)
    }
    
    @objc private func findButtonTapped() {
        findButtonTappedPublisher.send()
    }
    
    @objc private func postButtonTapped() {
        postButtonTappedPublisher.send()
    }
}

extension CallVanView {
    
    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }
    
    private func setUpStyles() {
        titleLabel.do {
            $0.textColor = UIColor.appColor(.primary500)
            $0.font = UIFont.appFont(.pretendardBold, size: 15)
            $0.text = "콜밴팟 모집"
        }
        [findButton, postButton].forEach {
            $0.backgroundColor = UIColor.appColor(.neutral50)
            $0.layer.cornerRadius = 8
        }
        [findTitleLabel, postTitleLabel].forEach {
            $0.textColor = .black
            $0.font = UIFont.appFont(.pretendardMedium, size: 14)
        }
        findTitleLabel.text = "콜밴팟 찾기"
        postTitleLabel.text = "콜밴팟 모집"
        
        [findDescriptionLabel, postDescriptionLabel].forEach {
            $0.textColor = .black
            $0.font = UIFont.appFont(.pretendardRegular, size: 12)
        }
        findDescriptionLabel.text = "바로가기"
        postDescriptionLabel.text = "글 작성하기"
        
        [findRightArrowImageView, postRightArrowImageView].forEach {
            $0.image = UIImage.appImage(asset: .chevronRightHome)?.withRenderingMode(.alwaysTemplate)
            $0.tintColor = UIColor.appColor(.neutral800)
        }
    }
    private func setUpLayouts() {
        [findTitleLabel, findDescriptionLabel, findRightArrowImageView].forEach {
            findButton.addSubview($0)
        }
        [postTitleLabel, postDescriptionLabel, postRightArrowImageView].forEach {
            postButton.addSubview($0)
        }
        [titleLabel, findButton, postButton].forEach {
            addSubview($0)
        }
        [buttonsLayoutGuide].forEach {
            addLayoutGuide($0)
        }
    }
    private func setUpConstraints() {
        titleLabel.snp.makeConstraints {
            $0.height.equalTo(29)
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(24)
        }
        buttonsLayoutGuide.snp.makeConstraints {
            $0.height.equalTo(65)
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.bottom.equalToSuperview()
        }
        findButton.snp.makeConstraints {
            $0.top.bottom.leading.equalTo(buttonsLayoutGuide)
            $0.trailing.equalTo(buttonsLayoutGuide.snp.centerX).offset(-8)
        }
        postButton.snp.makeConstraints {
            $0.top.bottom.trailing.equalTo(buttonsLayoutGuide)
            $0.leading.equalTo(buttonsLayoutGuide.snp.centerX).offset(8)
        }
        
        findTitleLabel.snp.makeConstraints {
            $0.height.equalTo(22)
            $0.top.equalTo(findButton).offset(12)
            $0.leading.equalTo(findButton).offset(16)
        }
        findDescriptionLabel.snp.makeConstraints {
            $0.height.equalTo(19)
            $0.top.equalTo(findTitleLabel.snp.bottom)
            $0.leading.equalTo(findTitleLabel)
        }
        findRightArrowImageView.snp.makeConstraints {
            $0.centerY.equalTo(findButton)
            $0.trailing.equalTo(findButton).offset(-16)
        }
        
        postTitleLabel.snp.makeConstraints {
            $0.height.equalTo(22)
            $0.top.equalTo(postButton).offset(12)
            $0.leading.equalTo(postButton).offset(16)
        }
        postDescriptionLabel.snp.makeConstraints {
            $0.height.equalTo(19)
            $0.top.equalTo(postTitleLabel.snp.bottom)
            $0.leading.equalTo(postTitleLabel)
        }
        postRightArrowImageView.snp.makeConstraints {
            $0.centerY.equalTo(postButton)
            $0.trailing.equalTo(postButton).offset(-16)
        }
    }
}


