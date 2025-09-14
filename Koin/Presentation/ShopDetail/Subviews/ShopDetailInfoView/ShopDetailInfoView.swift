//
//  ShopDetailInfoView.swift
//  koin
//
//  Created by 홍기정 on 9/7/25.
//

import UIKit

final class ShopDetailInfoView: UIView {
    
    // MARK: - Components
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
    private let reviewLabel = UILabel().then {
        $0.text = "리뷰"
        $0.font = UIFont.appFont(.pretendardSemiBold, size: 12)
        $0.textColor = UIColor.appColor(.neutral800)
    }
    private let reviewButton = UIButton()
    private let moreInfoButton = UIButton()
    
    let isAvailableStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 8
        $0.alignment = .fill
    }
    private let isDeliveryAvailableView = UILabel()
    private let isTakeoutAvailableView = UILabel()
    private let isPayCardAvailableView = UILabel()
    private let isPayBankAvailableView = UILabel()
    
    private let orderAmountDelieveryTipView = ShopDetailCustomButton()
    private let introductionView = ShopDetailCustomButton()
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - configure
    
    func configure(orderShopSummary: OrderShopSummary, inorderable: Bool) {
        shopTitleLabel.text = orderShopSummary.name
        ratingLabel.text = String(orderShopSummary.ratingAverage)
        setUpReviewButton(reviewCount: orderShopSummary.reviewCount)
        orderAmountDelieveryTipView.configure(
            minOrderAmount: orderShopSummary.minimumOrderAmount,
            minDeliveryTip: orderShopSummary.minimumDeliveryTip,
            maxDelieveryTip: orderShopSummary.maximumDeliveryTip,
            introduction: nil,
            inorderable: inorderable)
        introductionView.configure(
            minOrderAmount: nil,
            minDeliveryTip: nil,
            maxDelieveryTip: nil,
            introduction: orderShopSummary.introduction,
            inorderable: false)
    }
    func configure(isDelieveryAvailable: Bool, isTakeoutAvailable: Bool?, payCard: Bool, payBank: Bool) {
        setUpIsAvailableView(isDelieveryAvailable: isDelieveryAvailable,
                             isTakeoutAvailable: isTakeoutAvailable,
                             payCard: payCard,
                             payBank: payBank)
    }
}
extension ShopDetailInfoView {
    
    private func setUpIsAvailableView(isDelieveryAvailable: Bool, isTakeoutAvailable: Bool?, payCard: Bool, payBank: Bool) {
        isDeliveryAvailableView.text = isDelieveryAvailable ? "배달 가능" : "배달 불가"
        isDeliveryAvailableView.textColor = isDelieveryAvailable ? .appColor(.new300) : .appColor(.neutral400)
        isTakeoutAvailableView.text = isTakeoutAvailable ?? true ? "포장 가능" : "포장 불가"
        isTakeoutAvailableView.textColor = isTakeoutAvailable ?? true ? .appColor(.new300) : .appColor(.neutral400)
        isPayCardAvailableView.text = payCard ? "카드가능" : "카드불가"
        isPayCardAvailableView.textColor = payCard ? .appColor(.new300) : .appColor(.neutral400)
        isPayBankAvailableView.text = payBank ? "계좌이체가능" : "계좌이체불가"
        isPayBankAvailableView.textColor = payBank ? .appColor(.new300) : .appColor(.neutral400)
        
        if isTakeoutAvailable == nil {
            isTakeoutAvailableView.isHidden = true
        }
    }
    private func setUpReviewButton(reviewCount: Int) {
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage.appImage(asset: .newChevronRight)
        configuration.imagePadding = 0
        configuration.imagePlacement = .trailing
        configuration.contentInsets = .zero
        reviewButton.configuration = configuration
        
        reviewButton.setAttributedTitle(NSAttributedString(
            string: "\(reviewCount)개",
            attributes: [
                .font : UIFont.appFont(.pretendardSemiBold, size: 13),
                .foregroundColor : UIColor.appColor(.neutral800)
            ]), for: .normal)
    }
    private func setUpMoreInfoButton() {
        var configuration = UIButton.Configuration.plain()
        configuration.imagePadding = 4
        configuration.imagePlacement = .trailing
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 12, bottom: 2, trailing: 8)
        moreInfoButton.configuration = configuration
        
        moreInfoButton.setAttributedTitle(NSAttributedString(string: "가게정보·원산지", attributes: [
            .font : UIFont.appFont(.pretendardRegular, size: 10),
            .foregroundColor : UIColor.appColor(.neutral500)
        ]), for: .normal)
        moreInfoButton.setImage(UIImage.appImage(asset: .newChevronRight)?.withRenderingMode(.alwaysTemplate), for: .normal)
        moreInfoButton.backgroundColor = UIColor.appColor(.neutral0)
        moreInfoButton.layer.cornerRadius = 12
        
        moreInfoButton.layer.borderWidth = 0.5
        moreInfoButton.layer.borderColor = UIColor.appColor(.neutral400).cgColor
        
        moreInfoButton.tintColor = .appColor(.neutral400)
    }
    private func setUpShadows(){
        [moreInfoButton, isDeliveryAvailableView, isTakeoutAvailableView, isPayCardAvailableView, isPayBankAvailableView, orderAmountDelieveryTipView, introductionView].forEach {
            $0.layer.applySketchShadow(color: UIColor.appColor(.neutral800), alpha: 0.04, x: 0, y: 2, blur: 4, spread: 0)
        }
    }
    private func setUpIsAvailableView() {
        [isDeliveryAvailableView, isTakeoutAvailableView, isPayCardAvailableView, isPayBankAvailableView].forEach {
            $0.font = UIFont.appFont(.pretendardSemiBold, size: 12)
            $0.backgroundColor = UIColor.appColor(.neutral0)
            $0.layer.cornerRadius = 11.5
            $0.textAlignment = .center
            $0.clipsToBounds = true
        }
    }
}

extension ShopDetailInfoView {
    
    private func setUpLayouts() {
        [starImageView, ratingLabel, separatorLabel, reviewLabel, reviewButton].forEach {
            rateReviewStackView.addArrangedSubview($0)
        }
        [isDeliveryAvailableView, isTakeoutAvailableView, isPayCardAvailableView, isPayBankAvailableView].forEach {
            isAvailableStackView.addArrangedSubview($0)
        }
        [shopTitleLabel, rateReviewStackView, moreInfoButton, orderAmountDelieveryTipView, introductionView, isAvailableStackView].forEach {
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
        orderAmountDelieveryTipView.snp.makeConstraints {
            $0.leading.equalTo(shopTitleLabel)
            $0.top.equalTo(rateReviewStackView.snp.bottom).offset(55)
            $0.height.equalTo(56)
            $0.width.equalTo((UIScreen.main.bounds.width - 60)/2)
        }
        introductionView.snp.makeConstraints {
            $0.trailing.equalTo(moreInfoButton)
            $0.top.equalTo(orderAmountDelieveryTipView)
            $0.height.equalTo(orderAmountDelieveryTipView)
            $0.width.equalTo(orderAmountDelieveryTipView)
            $0.bottom.equalToSuperview().offset(-18)
        }
        isAvailableStackView.snp.makeConstraints {
            $0.height.equalTo(23)
            $0.leading.equalToSuperview().offset(24)
            $0.top.equalTo(rateReviewStackView.snp.bottom).offset(16)
        }
        [isDeliveryAvailableView, isTakeoutAvailableView, isPayCardAvailableView].forEach {
            $0.snp.makeConstraints {
                $0.height.equalTo(23)
                $0.width.equalTo(61)
            }
        }
        isPayBankAvailableView.snp.makeConstraints {
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
