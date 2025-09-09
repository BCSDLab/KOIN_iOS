//
//  OrderPrepareCollectionViewCell.swift
//  koin
//
//  Created by 김성민 on 9/9/25.
//

import UIKit
import SnapKit

final class OrderPrepareCollectionViewCell: UICollectionViewCell {
    
    static let OrderPrepareIdentifier = "OrderPrepareCollectionViewCell"
    
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
            cf.background.backgroundColor = .appColor(.new100)
            cf.background.cornerRadius = 4
            
            let base = UIImage.appImage(asset: .delivery2)?.withRenderingMode(.alwaysTemplate)
            let small = base?.preparingThumbnail(of: CGSize(width: 16, height: 16)) ?? base
            cf.image = small
            
            return cf
        }()
    ).then {
        $0.imageView?.contentMode = .scaleAspectFit
        $0.setContentHuggingPriority(.required, for: .horizontal)
        $0.setContentCompressionResistancePriority(.required, for: .horizontal)
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
        $0.contentMode = .scaleAspectFit
        $0.image = UIImage.appImage(asset: .defaultMenuImage)
        $0.layer.cornerRadius = 4
    }
    
    private let storeNameLabel = UILabel().then {
        $0.text = "default"
        $0.textColor = .appColor(.neutral800)
        $0.font = .appFont(.pretendardBold, size: 16)
    }
    
    private let underView = UIView().then {
        $0.backgroundColor = .appColor(.neutral200)
    }
    
    private let menuNameLabel = UILabel().then {
        $0.text = "default"
        $0.textColor = .appColor(.neutral800)
        $0.font = .appFont(.pretendardMedium, size: 14)
    }
    
    private let menuPriceLabel = UILabel().then {
        $0.text = "default"
        $0.textColor = .appColor(.neutral800)
        $0.font = .appFont(.pretendardBold, size: 14)
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
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension OrderPrepareCollectionViewCell {
    
    // MARK: - UI Set Function

    private func configureView() {
        setUpLayouts()
        setUpConstraints()
    }
    
    private func setUpLayouts() {
        [orderInfoChip, estimatedTimeLabel, explanationLabel, estimatedTimeLabel, explanationLabel, underView, menuImageView,storeNameLabel ,menuNameLabel, menuPriceLabel, detailOrderButton].forEach{
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
        
        estimatedTimeLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.height.equalTo(32)
            $0.top.equalTo(orderInfoChip.snp.bottom).offset(12)
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

    func configure(
        methodText: String,
        estimatedTimeText: String,
        explanationText: String,
        image: UIImage?,
        storeName: String,
        menuName: String,
        priceText: String
    ) {
        updateChip(methodText: methodText)
        estimatedTimeLabel.text = estimatedTimeText
        explanationLabel.text = explanationText
        storeNameLabel.text = storeName
        menuNameLabel.text = menuName
        menuPriceLabel.text = priceText
        menuImageView.image = image ?? UIImage.appImage(asset: .defaultMenuImage)
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
            chip.baseForegroundColor = .appColor(.neutral700)
            chip.background.backgroundColor = .appColor(.neutral100)
        }
        
        orderInfoChip.configuration = chip
    }
}

