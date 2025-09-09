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
    
    private let orderInfoChip: UIButton = {
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
        
        let b = UIButton(configuration: cf)
        b.imageView?.contentMode = .scaleAspectFit
        b.setContentHuggingPriority(.required, for: .horizontal)
        b.setContentCompressionResistancePriority(.required, for: .horizontal)
        return b
    }()
    
    private let estimatedTimeLabel: UILabel = {
        let l = UILabel()
        l.text = "오후 8:32 수령 가능"
        l.font = UIFont.appFont(.pretendardBold, size: 20)
        l.textColor = UIColor.appColor(.new700)
        return l
    }()
    
    private let explanationLabel: UILabel = {
        let l = UILabel()
        l.text = "가게에서 열심히 음식을 조리하고있어요!"
        l.font = UIFont.appFont(.pretendardRegular, size: 12)
        l.textColor = UIColor.appColor(.neutral500)
        return l
    }()
    
    private let menuImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.image = UIImage.appImage(asset: .defaultMenuImage)
        iv.layer.cornerRadius = 4
        return iv
    }()
    
    private let storeNameLabel: UILabel = {
        let l = UILabel()
        l.text = "default"
        l.textColor = .appColor(.neutral800)
        l.font = .appFont(.pretendardBold, size: 16)
        return l
    }()
    
    private let UnderView: UIView = {
        let v = UIView()
        v.backgroundColor = .appColor(.neutral200)
        return v
    }()
    
    private let menuNameLabel: UILabel = {
        let l = UILabel()
        l.text = "default"
        l.textColor = .appColor(.neutral800)
        l.font = .appFont(.pretendardMedium, size: 14)
        return l
    }()
    
    private let menuPriceLabel: UILabel = {
        let l = UILabel()
        l.text = "default"
        l.textColor = .appColor(.neutral800)
        l.font = .appFont(.pretendardBold, size: 14)
        return l
    }()
    
    private let detailOrderButton: UIButton = {
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

        let b = UIButton(configuration: cf)
        return b
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension OrderPrepareCollectionViewCell {
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
    }
    
    private func setUpLayouts() {
        [orderInfoChip, estimatedTimeLabel, explanationLabel, estimatedTimeLabel, explanationLabel, UnderView, menuImageView,storeNameLabel ,menuNameLabel, menuPriceLabel, detailOrderButton].forEach{
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
        
        UnderView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(1)
            $0.top.equalTo(explanationLabel.snp.bottom).offset(16)
        }
        
        menuImageView.snp.makeConstraints{
            $0.leading.equalToSuperview().offset(24)
            $0.height.width.equalTo(88)
            $0.top.equalTo(UnderView.snp.bottom).offset(16)
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

