//
//  ShopSummaryInfoView.swift
//  koin
//
//  Created by 홍기정 on 9/7/25.
//

import UIKit
import Combine

final class ShopSummaryInfoView: UIView {
    
    // MARK: - Properties
    let navigateToShopInfoPublisher = PassthroughSubject<ShopDetailTableView.HighlightableCell, Never>()
    let reviewButtonTappedPublisher = PassthroughSubject<Void, Never>()
    let phoneButtonTappedPublisher = PassthroughSubject<Void, Never>()
    
    // MARK: - UI Components
    private let shopTitleLabel = UILabel().then {
        $0.textColor = UIColor.appColor(.neutral800)
        $0.font = UIFont.appFont(.pretendardBold, size: 20)
        $0.numberOfLines = 0
        $0.lineBreakMode = .byWordWrapping
    }
    
    private let rateReviewStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 4
        $0.alignment = .center
    }
    
    private let starImageView = UIImageView(image: UIImage.appImage(asset: .star)?.resize(to: CGSize(width: 25, height: 25)))
    
    private let ratingLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardSemiBold, size: 14)
        $0.textColor = UIColor.appColor(.neutral800)
    }
    
    private let separatorLabel = UILabel().then {
        $0.text = "·"
        $0.font = UIFont.appFont(.pretendardRegular, size: 13)
        $0.textColor = UIColor.appColor(.neutral800)
    }
    
    private let reviewButton = UIButton()
    
    private let moreInfoButton = UIButton()
    
    private let isAvailableStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 8
        $0.alignment = .fill
    }
    
    private let isDeliveryAvailableLabel = UILabel().then {
        $0.text = "배달 가능"
    }
    private let isTakeoutAvailableLabel = UILabel().then {
        $0.text = "포장 가능"
    }
    private let isPayCardAvailableLabel = UILabel().then {
        $0.text = "카드가능"
    }
    private let isPayBankAvailableLabel = UILabel().then {
        $0.text = "계좌이체 가능"
    }
    
    private let orderAmountDelieveryTipButton = ShopSummaryCustomButton()
    
    private let introductionButton = ShopSummaryCustomButton()
    
    private let phoneButton = ShopSummaryPhoneButton()
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        addTargets()
        setAddTarget()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - configure
    
    func configure(phonenumber: String) {
        phoneButton.configure(phonenumber: phonenumber)
    }
    
    func configure(minOrderAmount: Int, minDeliveryTip: Int, maxDelieveryTip: Int, isFromOrder: Bool) {
        orderAmountDelieveryTipButton.configure(minOrderAmount: minOrderAmount,
                                                minDeliveryTip: minDeliveryTip,
                                                maxDelieveryTip: maxDelieveryTip,
                                                isFromOrder: isFromOrder)
        
    }
    
    func configure(orderShopSummary: OrderShopSummary, isFromOrder: Bool) {
        shopTitleLabel.text = orderShopSummary.name
        ratingLabel.text = String(orderShopSummary.ratingAverage)
        setUpReviewButton(reviewCount: orderShopSummary.reviewCount)
        setUpMoreInfoButton(isFromOrder: isFromOrder)
        introductionButton.configure(introduction: orderShopSummary.introduction)
    }
    
    func configure(isDelieveryAvailable: Bool, isTakeoutAvailable: Bool = false, payCard: Bool, payBank: Bool) {
        isDeliveryAvailableLabel.isHidden = !isDelieveryAvailable ? true : false
        isTakeoutAvailableLabel.isHidden = !isTakeoutAvailable ? true : false
        isPayCardAvailableLabel.isHidden = !payCard ? true : false
        isPayBankAvailableLabel.isHidden = !payBank ? true : false
    }
    
    private func setAddTarget() {
        reviewButton.addAction(UIAction { [weak self] _ in
            self?.reviewButtonTappedPublisher.send()
        }, for: .touchUpInside)
    }
}

extension ShopSummaryInfoView {
    
    private func setUpMoreInfoButton(isFromOrder: Bool) {
        let text = isFromOrder ? "가게정보·원산지" : "가게정보"
        moreInfoButton.setAttributedTitle(NSAttributedString(string: text, attributes: [
            .font : UIFont.appFont(.pretendardRegular, size: 10),
            .foregroundColor : UIColor.appColor(.neutral500)
        ]), for: .normal)
    }
    
    private func setUpReviewButton(reviewCount: Int) {
        var configuration = UIButton.Configuration.plain()
        configuration.imagePadding = 4
        configuration.imagePlacement = .trailing
        configuration.contentInsets = .zero
        configuration.image = UIImage.appImage(asset: .newChevronRight)
        
        reviewButton.configuration = configuration
        
        let reviewText = NSMutableAttributedString(
            string: "리뷰 ",
            attributes: [
                .font: UIFont.appFont(.pretendardSemiBold, size: 12),
                .foregroundColor: UIColor.appColor(.neutral800)
            ]
        )
        
        let countText = NSAttributedString(
            string: "\(reviewCount)개",
            attributes: [
                .font: UIFont.appFont(.pretendardSemiBold, size: 13),
                .foregroundColor: UIColor.appColor(.neutral800)
            ]
        )
        
        reviewText.append(countText)
        reviewButton.setAttributedTitle(reviewText, for: .normal)
    }
    
    private func setUpMoreInfoButton() {
        var configuration = UIButton.Configuration.plain()
        configuration.imagePadding = 4
        configuration.imagePlacement = .trailing
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 12, bottom: 2, trailing: 8)
        moreInfoButton.configuration = configuration
        
        moreInfoButton.setImage(UIImage.appImage(asset: .newChevronRight)?.withRenderingMode(.alwaysTemplate), for: .normal)
        moreInfoButton.backgroundColor = UIColor.appColor(.neutral0)
        moreInfoButton.layer.cornerRadius = 12
        
        moreInfoButton.layer.borderWidth = 0.5
        moreInfoButton.layer.borderColor = UIColor.appColor(.neutral400).cgColor
        
        moreInfoButton.tintColor = .appColor(.neutral400)
    }
    
    private func setUpShadows(){
        [moreInfoButton, isDeliveryAvailableLabel, isTakeoutAvailableLabel, isPayCardAvailableLabel, isPayBankAvailableLabel, orderAmountDelieveryTipButton, introductionButton, phoneButton].forEach {
            $0.layer.applySketchShadow(color: UIColor.appColor(.neutral800), alpha: 0.04, x: 0, y: 2, blur: 4, spread: 0)
        }
    }
    
    private func setUpIsAvailableView() {
        [isDeliveryAvailableLabel, isTakeoutAvailableLabel, isPayCardAvailableLabel, isPayBankAvailableLabel].forEach {
            $0.font = UIFont.appFont(.pretendardSemiBold, size: 12)
            $0.backgroundColor = UIColor.appColor(.neutral0)
            $0.layer.cornerRadius = 11.5
            $0.textAlignment = .center
            $0.clipsToBounds = true
            $0.textColor = .appColor(.new300)
        }
    }
}

extension ShopSummaryInfoView {
    
    private func addTargets() {
        moreInfoButton.addTarget(self, action: #selector(moreInfoButtonTapped), for: .touchUpInside)
        orderAmountDelieveryTipButton.addTarget(self, action: #selector(orderAmountDelieveryTipButtonTapped), for: .touchUpInside)
        introductionButton.addTarget(self, action: #selector(introductionButtonTapped), for: .touchUpInside)
        phoneButton.addTarget(self, action: #selector(phoneButtonTapped), for: .touchUpInside)
    }
    
    @objc private func moreInfoButtonTapped() {
        navigateToShopInfoPublisher.send(.name)
    }
    @objc private func orderAmountDelieveryTipButtonTapped() {
        navigateToShopInfoPublisher.send(.deliveryTips)
    }
    @objc private func introductionButtonTapped() {
        navigateToShopInfoPublisher.send(.notice)
    }
    @objc private func phoneButtonTapped() {
        phoneButtonTappedPublisher.send()
    }
}

extension ShopSummaryInfoView {
    
    private func setUpLayouts() {
        [starImageView, ratingLabel, separatorLabel, reviewButton].forEach {
            rateReviewStackView.addArrangedSubview($0)
        }
        
        [isDeliveryAvailableLabel, isTakeoutAvailableLabel, isPayCardAvailableLabel, isPayBankAvailableLabel].forEach {
            isAvailableStackView.addArrangedSubview($0)
        }
        
        [shopTitleLabel, rateReviewStackView, moreInfoButton, orderAmountDelieveryTipButton, introductionButton, isAvailableStackView, phoneButton].forEach {
            addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        shopTitleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.top.equalToSuperview().offset(18)
            $0.height.equalTo(32)
        }
        
        rateReviewStackView.snp.makeConstraints {
            $0.leading.equalTo(shopTitleLabel)
            $0.top.equalTo(shopTitleLabel.snp.bottom).offset(8)
            $0.height.equalTo(25)
        }
        
        moreInfoButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-24)
            $0.centerY.equalTo(rateReviewStackView.snp.centerY)
            $0.height.equalTo(24)
        }
        
        isAvailableStackView.snp.makeConstraints {
            $0.height.equalTo(23)
            $0.leading.equalToSuperview().offset(24)
            $0.top.equalTo(rateReviewStackView.snp.bottom).offset(16)
        }
        
        orderAmountDelieveryTipButton.snp.makeConstraints {
            $0.leading.equalTo(shopTitleLabel)
            $0.top.equalTo(isAvailableStackView.snp.bottom).offset(16)
            $0.height.equalTo(56)
            $0.width.equalTo((UIScreen.main.bounds.width - 60)/2)
        }
        
        introductionButton.snp.makeConstraints {
            $0.trailing.equalTo(moreInfoButton)
            $0.top.equalTo(orderAmountDelieveryTipButton)
            $0.height.equalTo(orderAmountDelieveryTipButton)
            $0.width.equalTo(orderAmountDelieveryTipButton)
        }
        
        phoneButton.snp.makeConstraints {
            $0.top.equalTo(orderAmountDelieveryTipButton.snp.bottom).offset(12)
            $0.leading.equalTo(shopTitleLabel)
            $0.trailing.equalTo(moreInfoButton)
            $0.height.equalTo(44)
            $0.bottom.equalToSuperview().offset(-18)
        }
        
        [isDeliveryAvailableLabel, isTakeoutAvailableLabel, isPayCardAvailableLabel].forEach {
            $0.snp.makeConstraints {
                $0.height.equalTo(23)
                $0.width.equalTo(61)
            }
        }
        
        isPayBankAvailableLabel.snp.makeConstraints {
            $0.height.equalTo(23)
            $0.width.equalTo(79)
        }
    }
    
    private func configureView() {
        setUpMoreInfoButton()
        setUpShadows()
        setUpIsAvailableView()
        
        setUpLayouts()
        setUpConstraints()
    }
}
