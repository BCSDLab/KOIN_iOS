//
//  OrderHistoryColletionViewCell.swift
//  koin
//
//  Created by 김성민 on 9/8/25.
//

import UIKit
import SnapKit
import Kingfisher

final class OrderHistoryColletionViewCell: UICollectionViewCell {
    
    static let orderHistoryIdentifier = "OrderHistoryColletionViewCell"
    var onTapOrderInfoButton: (() -> Void)?
    
    private enum ReorderState {
        case available
        case beforeOpen
    }

    //MARK: - Properties
    private var reorderState: ReorderState = .available {
        didSet { reorderButton.setNeedsUpdateConfiguration() }
    }
    
    var onTapReorder: (() -> Void)?
    
    //MARK: - UI
    
    private let stateLabel = UILabel().then {
        $0.text = "default"
        $0.textColor = UIColor.appColor(.new500)
        $0.font = UIFont.appFont(.pretendardBold, size: 16)
        $0.numberOfLines = 1
        $0.lineBreakMode = .byTruncatingTail
    }

    private let dayLabel = UILabel().then {
        $0.text = "??월 ??일 (?)"
        $0.textColor = UIColor.appColor(.new500)
        $0.font = UIFont.appFont(.pretendardRegular, size: 12)
        $0.numberOfLines = 1
        $0.lineBreakMode = .byTruncatingTail
    }

    private let menuImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 4
        $0.image = UIImage.appImage(asset: .defaultMenuImage)
    }

    private let storeNameLabel = UILabel().then {
        $0.text = "default"
        $0.textColor = UIColor.appColor(.neutral800)
        $0.font = UIFont.appFont(.pretendardBold, size: 16)
    }

    private let stateLabelUnderView = UIView().then {
        $0.backgroundColor = UIColor.appColor(.neutral200)
    }

    private let menuNameLabel = UILabel().then {
        $0.text = "default"
        $0.textColor = UIColor.appColor(.neutral800)
        $0.font = UIFont.appFont(.pretendardMedium, size: 14)
        $0.numberOfLines = 1
        $0.lineBreakMode = .byTruncatingTail
    }

    private let menuPriceLabel = UILabel().then {
        $0.text = "default"
        $0.textColor = UIColor.appColor(.neutral800)
        $0.font = UIFont.appFont(.pretendardBold, size: 14)
        $0.setContentCompressionResistancePriority(.required, for: .horizontal)
    }

    private let orderInfoButton = UIButton(
        configuration: {
            var config = UIButton.Configuration.plain()
            config.attributedTitle = AttributedString("주문상세", attributes: .init([
                .font: UIFont.appFont(.pretendardMedium, size: 12)
            ]))
            config.baseForegroundColor = UIColor.appColor(.neutral500)
            config.imagePlacement = .trailing
            config.imagePadding = 4
            config.contentInsets = .init(top: 4, leading: 6, bottom: 4, trailing: 6)

            let base = UIImage.appImage(asset: .chevronRight)?.withRenderingMode(.alwaysTemplate)
            let small = base?.preparingThumbnail(of: CGSize(width: 12, height: 12)) ?? base
            config.image = small

            return config
        }()
    ).then {
        $0.imageView?.contentMode = .scaleAspectFit
        $0.setContentHuggingPriority(.required, for: .horizontal)
        $0.setContentCompressionResistancePriority(.required, for: .horizontal)
    }

    private let reviewButton = UIButton(
        configuration: {
            var config = UIButton.Configuration.plain()
            config.attributedTitle = AttributedString("리뷰쓰기", attributes: .init([
                .font: UIFont.appFont(.pretendardBold, size: 14)
            ]))
            config.baseForegroundColor = UIColor.appColor(.neutral600)

            var background = UIBackgroundConfiguration.clear()
            background.cornerRadius = 8
            background.backgroundColor = UIColor.appColor(.neutral0)
            background.strokeColor = UIColor.appColor(.neutral300)
            background.strokeWidth = 1
            config.background = background

            return config
        }()
    )

    private let reorderButton = UIButton(
        configuration: {
            var config = UIButton.Configuration.plain()
            config.attributedTitle = AttributedString("같은 메뉴 담기", attributes: .init([
                .font: UIFont.appFont(.pretendardBold, size: 14)
            ]))
            config.baseForegroundColor = UIColor.appColor(.neutral0)

            var background = UIBackgroundConfiguration.clear()
            background.cornerRadius = 8
            background.backgroundColor = UIColor.appColor(.new500)
            config.background = background

            return config
        }()
    )
    
    // MARK: - Initialize
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        setupReorderButtonState()
        setAddTarget()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        stateLabel.text = nil
        dayLabel.text = nil
        storeNameLabel.text = nil
        menuNameLabel.text = nil
        menuPriceLabel.text = nil

        menuImageView.kf.cancelDownloadTask()
        menuImageView.image = UIImage.appImage(asset: .defaultMenuImage)

        reorderState = .available
        reviewButton.isHidden = false
        reorderButton.isHidden = false

        onTapOrderInfoButton = nil
        onTapReorder = nil
    }
    
    private func setAddTarget() {
        orderInfoButton.addTarget(self, action: #selector(orderInfoButtonTapped), for: .touchUpInside)
    }
}

extension OrderHistoryColletionViewCell {
    @objc private func orderInfoButtonTapped() {
        onTapOrderInfoButton?()
    }
}

// MARK: - Set UI Function
extension OrderHistoryColletionViewCell {
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
    }
    
    private func setUpLayouts() {
        [stateLabel, dayLabel, orderInfoButton,stateLabelUnderView, menuImageView, storeNameLabel, menuNameLabel, menuPriceLabel, reviewButton, reorderButton].forEach {
            self.contentView.addSubview($0)
        }
        self.contentView.backgroundColor = .appColor(.neutral0)
        
        contentView.layer.cornerRadius = 12
        contentView.layer.borderWidth = 0.5
        contentView.layer.borderColor = UIColor.appColor(.neutral200).cgColor
        
    }
    
    private func setUpConstraints() {
        
        stateLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(24)
        }
        
        dayLabel.snp.makeConstraints {
            $0.leading.equalTo(stateLabel.snp.trailing).offset(5)
            $0.centerY.equalTo(stateLabel)
            $0.width.equalTo(66)
        }
        
        orderInfoButton.snp.makeConstraints{
            $0.trailing.equalToSuperview().offset(-24)
            $0.centerY.equalTo(stateLabel)
            $0.width.equalTo(70)
            $0.height.equalTo(20)
        }
        
        stateLabelUnderView.snp.makeConstraints {
            $0.top.equalTo(stateLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(1)
        }
        
        menuImageView.snp.makeConstraints {
            $0.top.equalTo(stateLabelUnderView.snp.bottom).offset(12)
            $0.height.width.equalTo(88)
            $0.leading.equalToSuperview().inset(24)
        }
        
        storeNameLabel.snp.makeConstraints{
            $0.leading.equalTo(menuNameLabel)
            $0.bottom.equalTo(menuNameLabel.snp.top).offset(-6)
            $0.top.equalTo(menuImageView.snp.top).offset(3)
        }
        
        menuNameLabel.snp.makeConstraints{
            $0.centerY.equalTo(menuImageView)
            $0.leading.equalTo(menuImageView.snp.trailing).offset(12)
        }
        
        menuPriceLabel.snp.makeConstraints {
            $0.top.equalTo(menuNameLabel.snp.bottom).offset(6)
            $0.leading.equalTo(menuNameLabel)
            $0.bottom.equalTo(menuImageView.snp.bottom).inset(3)
        }
        
        reviewButton.snp.makeConstraints{
            $0.top.equalTo(menuImageView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(44)
        }
        
        reorderButton.snp.makeConstraints {
            $0.top.equalTo(reviewButton.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(44)
            $0.bottom.equalToSuperview().inset(16)
        }
    }
    
    // MARK: - UI Function
    
    private func setupReorderButtonState() {
         reorderButton.configurationUpdateHandler = { [weak self] button in
             guard let self else { return }
             var config = button.configuration ?? .plain()
             var background = UIBackgroundConfiguration.clear()
             background.cornerRadius = 8

             switch self.reorderState {
             case .available:
                 config.attributedTitle = .init("같은 메뉴 담기", attributes: .init([
                     .font: UIFont.appFont(.pretendardBold, size: 14)
                 ]))
                 config.baseForegroundColor = UIColor.appColor(.neutral0)
                 background.backgroundColor = UIColor.appColor(.new500)
                 button.isEnabled = true
                 button.isHidden  = false

             case .beforeOpen:
                 config.attributedTitle = .init("같은 메뉴 담기 (오픈 전)", attributes: .init([
                     .font: UIFont.appFont(.pretendardBold, size: 14)
                 ]))
                 config.baseForegroundColor = UIColor.appColor(.neutral400)
                 background.backgroundColor = UIColor.appColor(.neutral100)
                 button.isEnabled = false
                 button.isHidden  = false
             }

             config.background = background
             button.configuration = config
         }
         reorderButton.setNeedsUpdateConfiguration()
     }
    
    private func stateText(_ s: OrderStatus) -> String {
        switch s {
        case .delivered: return "배달완료"
        case .pickedUp:  return "포장완료"
        case .canceled:  return "취소완료"
        }
    }
    
    func configure(with order: OrderHistory) {
        stateLabel.text = stateText(order.status)
        dayLabel.text = order.orderDate.formatDateToMDEEE()
        
        storeNameLabel.text = order.shopName
        menuNameLabel.text  = order.orderTitle
        menuPriceLabel.text = "\(order.totalAmount.formattedWithComma)원"

        menuImageView.kf.setImage(
            with: order.shopThumbnail,
            placeholder: UIImage.appImage(asset: .defaultMenuImage),
            options: [
                .transition(.fade(0.2)),
                .cacheOriginalImage,
                .backgroundDecode
            ]
        )
        
        reorderState = order.isReorderable ? .available : .beforeOpen
    }
    
}


