//
//  OrderHistoryColletionViewCell.swift
//  koin
//
//  Created by 김성민 on 9/8/25.
//

import UIKit
import SnapKit



final class OrderHistoryColletionViewCell: UICollectionViewCell {
    
    static let orderHistoryIdentifier = "OrderHistoryColletionViewCell"
    
    
    private enum ReorderState {
        case available
        case beforeOpen
    }

    private var reorderState: ReorderState = .available {
        didSet { reorderButton.setNeedsUpdateConfiguration() }
    }
    
    var onTapReorder: (() -> Void)?
    
    //MARK: - UI
    
    private let stateLabel: UILabel = {
        let l = UILabel()
        l.text = "default"
        l.textColor = .appColor(.new500)
        l.font = .appFont(.pretendardBold, size: 16)
        return l
    }()
    
    private let dayLabel: UILabel = {
        let l = UILabel()
        l.text = "??월 ??일 (?)"
        l.textColor = .appColor(.new500)
        l.font = .appFont(.pretendardRegular, size: 12)
        return l
    }()
    
    private let menuImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.image = UIImage.appImage(asset: .defaultMenuImage)
        return iv
    }()
    
    private let storeNameLabel: UILabel = {
        let l = UILabel()
        l.text = "default"
        l.textColor = .appColor(.neutral800)
        l.font = .appFont(.pretendardBold, size: 16)
        return l
    }()
    
    private let stateLabelUnderView: UIView = {
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
    
    private let orderInfoButton: UIButton = {
        var cf = UIButton.Configuration.plain()
        cf.attributedTitle = AttributedString("주문상세", attributes: .init([
            .font: UIFont.appFont(.pretendardMedium, size: 12)
        ]))
        cf.baseForegroundColor = UIColor.appColor(.neutral500)
        cf.imagePlacement = .trailing
        cf.imagePadding = 4
        cf.contentInsets = .init(top: 4, leading: 6, bottom: 4, trailing: 6)

        let base = UIImage.appImage(asset: .chevronRight)?.withRenderingMode(.alwaysTemplate)
        let small = base?.preparingThumbnail(of: CGSize(width: 12, height: 12)) ?? base
        cf.image = small

        let b = UIButton(configuration: cf)
        b.imageView?.contentMode = .scaleAspectFit
        b.setContentHuggingPriority(.required, for: .horizontal)
        b.setContentCompressionResistancePriority(.required, for: .horizontal)
        return b
    }()

    
    
    private let reviewButton: UIButton = {
        var cf = UIButton.Configuration.plain()
        cf.attributedTitle = AttributedString("리뷰쓰기", attributes: .init([
            .font: UIFont.appFont(.pretendardBold, size: 14)
        ]))
        cf.baseForegroundColor = UIColor.appColor(.neutral600)
        var bg = UIBackgroundConfiguration.clear()
        bg.cornerRadius = 8
        bg.backgroundColor = UIColor.appColor(.neutral0)
        bg.strokeColor = UIColor.appColor(.neutral300)
        bg.strokeWidth = 1
        cf.background = bg
        
//        cf.contentInsets = NSDirectionalEdgeInsets(top: 11, leading: 121, bottom: 11, trailing: 121)

        let b = UIButton(configuration: cf)
        return b
    }()
    
    private let reorderButton: UIButton = {
        var cf = UIButton.Configuration.plain()
        cf.attributedTitle = AttributedString("같은 메뉴 담기", attributes: .init([
            .font: UIFont.appFont(.pretendardBold, size: 14)
        ]))
        cf.baseForegroundColor = UIColor.appColor(.neutral0)
        var bg = UIBackgroundConfiguration.clear()
        bg.cornerRadius = 8
        bg.backgroundColor = UIColor.appColor(.new500)
        cf.background = bg
//        cf.contentInsets = NSDirectionalEdgeInsets(top: 11, leading: 121, bottom: 11, trailing: 121)

        let b = UIButton(configuration: cf)
        return b
        
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        setupReorderButtonStateHandler()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}



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
            $0.width.equalTo(56)
        }
        
        dayLabel.snp.makeConstraints {
            $0.leading.equalTo(stateLabel.snp.trailing)
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
    
    
    
    private func setupReorderButtonStateHandler() {
        reorderButton.configurationUpdateHandler = { [weak self] btn in
            guard let self else { return }
            var cfg = btn.configuration ?? .plain()
            var bg  = UIBackgroundConfiguration.clear()
            bg.cornerRadius = 8
            
            switch self.reorderState {
            case .available:
                cfg.attributedTitle = .init("같은 메뉴 담기", attributes: .init([
                    .font: UIFont.appFont(.pretendardBold, size: 14)
                ]))
                cfg.baseForegroundColor = .white
                bg.backgroundColor = .appColor(.new500)
                btn.isEnabled = true
                btn.isHidden  = false
                
            case .beforeOpen:
                cfg.attributedTitle = .init("같은 메뉴 담기 (오픈 전)", attributes: .init([
                    .font: UIFont.appFont(.pretendardBold, size: 14)
                ]))
                cfg.baseForegroundColor = .appColor(.neutral400)
                bg.backgroundColor = .appColor(.neutral100)
                btn.isEnabled = false
                btn.isHidden  = false
            }
            
            cfg.background = bg
            btn.configuration = cfg
        }
        reorderButton.setNeedsUpdateConfiguration()
    }
    
    func configure(
         stateText: String,
         dateText: String,
         image: UIImage?,
         storeName: String,
         menuName: String,
         priceText: String,
         canReorder: Bool
     ) {
         stateLabel.text = stateText
         dayLabel.text = dateText
         menuImageView.image = image
         storeNameLabel.text = storeName
         menuNameLabel.text = menuName
         menuPriceLabel.text = priceText
         reorderState = canReorder ? .available : .beforeOpen
         
     }
}
