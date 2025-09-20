//
//  OrderPrepareCollectionViewCell.swift
//  koin
//
//  Created by 김성민 on 9/9/25.
//

import UIKit
import SnapKit
import Kingfisher

final class OrderPrepareCollectionViewCell: UICollectionViewCell {
    
    var onTapOrderDetailButton: (() -> Void)?
    
    static let OrderPrepareIdentifier = "OrderPrepareCollectionViewCell"
    
    private var estimatedHeightConstraint: Constraint!
    
    private enum stateCase {
        case delivery
        case packaging
    }
    
    // MARK: - UI Components
    
    private let orderInfoChip = UIButton(
        configuration: {
        var cf = UIButton.Configuration.plain()
        cf.attributedTitle = AttributedString("배달", attributes: .init([
            .font: UIFont.appFont(.pretendardMedium, size: 12)
            ]))
        cf.baseForegroundColor = UIColor.appColor(.new500)
        cf.imagePlacement = .leading
        cf.imagePadding = 5.5
        cf.contentInsets = .init(top: 2, leading: 6, bottom: 2, trailing: 6)
        cf.background.backgroundColor = UIColor.appColor(.new100)
        cf.background.cornerRadius = 4
            
        let base = UIImage.appImage(asset: .delivery2)?.withRenderingMode(.alwaysTemplate)
        let small = base?.preparingThumbnail(of: CGSize(width: 16, height: 16)) ?? base
        cf.image = small
                
        return cf
        }()
    ).then {
        $0.imageView?.contentMode = .scaleAspectFill
        $0.setContentHuggingPriority(.required, for: .horizontal)
        $0.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    
    private let stateLabel = UILabel().then{
        $0.text = "주문 확인 중"
        $0.font = UIFont.appFont(.pretendardBold, size: 20)
        $0.textColor = UIColor.appColor(.new500)
        $0.textAlignment = .left
    }

    private let estimatedTimeLabel = UILabel().then {
        $0.text = "오후 8:32 수령 가능"
        $0.font = UIFont.appFont(.pretendardBold, size: 20)
        $0.textColor = UIColor.appColor(.new700)
    }

    private let explanationLabel = UILabel().then {
        $0.text = "가게에서 열심히 음식을 조리하고있어요!"
        $0.font = UIFont.appFont(.pretendardRegular, size: 12)
        $0.textColor = UIColor.appColor(.neutral500)
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

    private let underView = UIView().then {
        $0.backgroundColor = UIColor.appColor(.neutral200)
    }

    private let menuNameLabel = UILabel().then {
        $0.text = "default"
        $0.textColor = UIColor.appColor(.neutral800)
        $0.font = UIFont.appFont(.pretendardMedium, size: 14)
    }

    private let menuPriceLabel = UILabel().then {
        $0.text = "default"
        $0.textColor = UIColor.appColor(.neutral800)
        $0.font = UIFont.appFont(.pretendardBold, size: 14)
    }

    private let detailOrderButton = UIButton(
        configuration: {
            var cf = UIButton.Configuration.plain()
            cf.attributedTitle = AttributedString("주문 상세 보기", attributes: .init([
                .font: UIFont.appFont(.pretendardBold, size: 14)
            ]))
            cf.baseForegroundColor = UIColor.appColor(.new500)
            
            var bg = UIBackgroundConfiguration.clear()
            bg.cornerRadius = 8
            bg.backgroundColor = UIColor.appColor(.neutral0)
            bg.strokeColor = UIColor.appColor(.new500)
            bg.strokeWidth = 1
            cf.background = bg
            
            return cf
        }()
    )

    // MARK: - Initialize

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        setAddtarget()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        onTapOrderDetailButton = nil

        menuImageView.kf.cancelDownloadTask()
        menuImageView.image = UIImage.appImage(asset: .defaultMenuImage)
    }
    
    private func setAddtarget() {
        detailOrderButton.addTarget(self, action: #selector(detailOrderButtonTapped), for: .touchUpInside)
    }
}

extension OrderPrepareCollectionViewCell {
    @objc private func detailOrderButtonTapped() {
        onTapOrderDetailButton?()
    }
}

extension OrderPrepareCollectionViewCell {
    
    // MARK: - UI Set Function

    private func configureView() {
        setUpLayouts()
        setUpConstraints()
    }
    
    private func setUpLayouts() {
        [orderInfoChip,stateLabel, estimatedTimeLabel, explanationLabel, underView, menuImageView, storeNameLabel, menuNameLabel, menuPriceLabel, detailOrderButton].forEach{
            contentView.addSubview($0)
        }
        self.contentView.backgroundColor = .appColor(.neutral0)
        contentView.layer.cornerRadius = 12
        contentView.layer.borderWidth = 0.5
        contentView.layer.borderColor = UIColor.appColor(.neutral200).cgColor
    }
    
    private func setUpConstraints() {
        orderInfoChip.snp.makeConstraints{
            $0.leading.equalToSuperview().offset(24)
            $0.top.equalToSuperview().offset(16)
            $0.height.equalTo(24)
        }
        
        stateLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.top.equalTo(orderInfoChip.snp.bottom).offset(12)
            $0.height.equalTo(32)
        }
        
        estimatedTimeLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.top.equalTo(stateLabel.snp.bottom)
            
            estimatedHeightConstraint = $0.height.equalTo(32).constraint
        }
        
        explanationLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.height.equalTo(19)
            $0.top.equalTo(estimatedTimeLabel.snp.bottom)

        }
        
        underView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(1)
            $0.top.equalTo(explanationLabel.snp.bottom).offset(16)
        }
        
        menuImageView.snp.makeConstraints{
            $0.leading.equalToSuperview().offset(24)
            $0.height.width.equalTo(88)
            $0.top.equalTo(underView.snp.bottom).offset(16)
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
        
        detailOrderButton.snp.makeConstraints {
            $0.top.equalTo(menuImageView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.bottom.equalToSuperview().inset(16)
        }
        
    }
    
    // MARK: - Function

    func configure(with order: OrderInProgress) {
        updateChip(methodText: order.methodText)
        stateLabel.text = order.stateText
        estimatedTimeLabel.text = order.estimatedTimeText
        explanationLabel.text = order.explanationText
        storeNameLabel.text = order.orderableShopName
        menuNameLabel.text = order.orderTitle
        menuPriceLabel.text = "\(NumberFormatter.krCurrencyNoFraction.string(from: NSNumber(value: order.totalAmount)) ?? "\(order.totalAmount)")원"
        setEstimatedLabel(order.status.showEstimatedTime)

        if let url = URL(string: order.orderableShopThumbnail) {
            menuImageView.kf.setImage(
                with: url,
                placeholder: UIImage.appImage(asset: .defaultMenuImage),
                options: [
                    .transition(.fade(0.2)),
                    .cacheOriginalImage,
                    .backgroundDecode
                ]
            )
        } else {
            menuImageView.image = UIImage.appImage(asset: .defaultMenuImage)
        }
    }

    
    private func setEstimatedLabel(_ visible: Bool){
        estimatedTimeLabel.isHidden = !visible
        estimatedHeightConstraint.update(offset: visible ? 32 : 0)

        setNeedsLayout()
        layoutIfNeeded()
        
    }
    
    private func updateChip(methodText: String) {
        var chip = orderInfoChip.configuration ?? .plain()
        
        chip.attributedTitle = AttributedString(methodText, attributes: .init([
            .font: UIFont.appFont(.pretendardMedium, size: 12)
        ]))
        chip.imagePlacement = .leading
        chip.imagePadding = 5.5
        chip.contentInsets = .init(top: 2, leading: 6, bottom: 2, trailing: 6)
        chip.background.cornerRadius = 4
        
        if methodText == "배달" {
            chip.image = UIImage.appImage(asset: .delivery2)?
                .withRenderingMode(.alwaysTemplate)
                .preparingThumbnail(of: CGSize(width: 16, height: 16))
            chip.baseForegroundColor = .appColor(.new500)
            chip.background.backgroundColor = .appColor(.new100)
        } else if methodText == "포장" {
            chip.image = UIImage.appImage(asset: .packaging)?
                .withRenderingMode(.alwaysTemplate)
                .preparingThumbnail(of: CGSize(width: 16, height: 16))
            chip.baseForegroundColor = .appColor(.new500)
            chip.background.backgroundColor = .appColor(.new100)
        }
        
        orderInfoChip.configuration = chip
    }
}


