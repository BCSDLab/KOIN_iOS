//
//  DiningCollectionViewCell.swift
//  Koin
//
//  Created by 김나훈 on 3/15/24.
//

import Combine
import SnapKit
import UIKit

final class DiningCollectionViewCellA: UICollectionViewCell {
    
    // MARK: - Properties
    let imageTapPublisher = PassthroughSubject<(UIImage, String), Never>()
    let shareButtonPublisher = PassthroughSubject<Void, Never>()
    var cancellables = Set<AnyCancellable>()
    
    static let reuseIdentifier = "diningCollectionViewCellA"
    
    // MARK: - UI Components
    
    private let diningPlaceLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardMedium, size: 18)
    }
    
    private let diningInfoLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardMedium, size: 12)
        $0.textColor = UIColor.appColor(.neutral500)
    }
    
    private let soldOutLabel = UILabel().then {
        $0.textAlignment = .center
        $0.layer.cornerRadius = 4
        $0.clipsToBounds = true
        $0.text = "품절"
        $0.font = UIFont.appFont(.pretendardMedium, size: 12)
        $0.backgroundColor = UIColor.appColor(.warning200)
        $0.textColor = UIColor.appColor(.warning600)
    }
    
    private let substitutionLabel = UILabel().then {
        $0.textAlignment = .center
        $0.layer.cornerRadius = 4
        $0.clipsToBounds = true
        $0.text = "변경됨"
        $0.font = UIFont.appFont(.pretendardMedium, size: 12)
        $0.backgroundColor = UIColor.appColor(.neutral200)
        $0.textColor = UIColor.appColor(.neutral600)
    }
    
    private let menuImageView = UIImageView().then {_ in 
    }
    
    private let menuImageBackground = UIView().then {
        $0.layer.cornerRadius = 8
        $0.clipsToBounds = true
    }
    
    private let leftMenuListLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardRegular, size: 14)
        $0.numberOfLines = 0
    }
    
    private let rightMenuListLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardRegular, size: 14)
        $0.numberOfLines = 0
    }
    
    private let separateView = UIView().then {
        $0.backgroundColor = UIColor.appColor(.neutral100)
    }
    
    private let cellSpacingView = UIView().then {
        $0.backgroundColor = UIColor.appColor(.neutral100)
    }
    
    private let nonMealImageView = UIImageView().then {
        $0.image = UIImage.appImage(asset: .noMeal)
    }
    
    private let nonMealText = UILabel().then {
        $0.text = "품절된 메뉴입니다."
        $0.textColor = UIColor.appColor(.neutral0)
        $0.font = UIFont.appFont(.pretendardRegular, size: 12)
    }
    
    private let shareButton = UIButton().then {
        $0.backgroundColor = .systemBackground
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage.appImage(asset: .share)
        var attributedTitle = AttributedString(stringLiteral: "공유하기")
        attributedTitle.font = UIFont.appFont(.pretendardRegular, size: 14)
        configuration.attributedTitle = attributedTitle
        configuration.imagePadding = 4
        configuration.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
        $0.configuration = configuration
        $0.tintColor = UIColor.appColor(.neutral600)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        menuImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageTapped)))
        menuImageBackground.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageTapped)))
        shareButton.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        [diningInfoLabel, leftMenuListLabel].forEach {
            $0.text = ""
        }
        [soldOutLabel, nonMealImageView, nonMealText, menuImageBackground, substitutionLabel, menuImageView].forEach {
            $0.isHidden = false
        }
        menuImageBackground.backgroundColor = .clear
        menuImageView.image = nil
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }
    
    @objc private func shareButtonTapped() {
        shareButtonPublisher.send(())
    }
    
    func configure(info: DiningItem) {
        diningPlaceLabel.text = info.place.rawValue
    
        let kcalText = info.kcal != 0 ? "\(info.kcal)kcal" : ""
        let priceCashText = (info.priceCash != nil && info.priceCash != 0) ? "\(info.priceCash!)원" : ""
        let priceCardText = (info.priceCard != nil && info.priceCard != 0) ? "\(info.priceCard!)원" : ""

        var displayText = ""

        if !kcalText.isEmpty {
            displayText += kcalText
        }

        if !priceCashText.isEmpty && !priceCardText.isEmpty {
            displayText += " • \(priceCashText)/\(priceCardText)"
        } else if !priceCashText.isEmpty {
            displayText += " • \(priceCashText)"
        } else if !priceCardText.isEmpty {
            displayText += " • \(priceCardText)"
        }

        diningInfoLabel.text = displayText.isEmpty ? "" : displayText

        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 2

        let menu = info.menu

        let leftAttributedString = NSMutableAttributedString()
        let rightAttributedString = NSMutableAttributedString()

        for (index, item) in menu.enumerated() {
            let attributedItem = NSAttributedString(string: item + "\n", attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
            if index % 2 == 0 {
                leftAttributedString.append(attributedItem)
            } else {
                rightAttributedString.append(attributedItem)
            }
        }

        leftMenuListLabel.attributedText = leftAttributedString
        rightMenuListLabel.attributedText = rightAttributedString

        soldOutLabel.isHidden = info.soldoutAt == nil
        nonMealImageView.isHidden = info.soldoutAt == nil
        nonMealText.isHidden = info.soldoutAt == nil
        
        if info.soldoutAt != nil { substitutionLabel.isHidden = true }
            if info.soldoutAt == nil { menuImageBackground.isHidden = true }
            else { menuImageBackground.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5) }
        
        substitutionLabel.isHidden = info.changedAt == nil
        menuImageView.isUserInteractionEnabled = info.imageUrl != nil ? true: false
        menuImageView.layer.cornerRadius = info.imageUrl != nil ? 8 : 0
        menuImageView.clipsToBounds = info.imageUrl != nil ? true: false
        menuImageBackground.isUserInteractionEnabled = info.imageUrl != nil ? true: false
        if let imageUrl = info.imageUrl { menuImageView.loadImageFromBothDiskAndMemory(from: imageUrl, radius: 8, transitionTime: 0.8) }
        else {
            var image = UIImage()
            if let date = info.date.toDateFromYYYYMMDD() {
                if date.isWeekend() {
                    menuImageView.image = UIImage.appImage(asset: .nonMenuWeekendImage)
                }
                else {
                    menuImageView.image = UIImage.appImage(asset: .nonMenuImage)
                }
            }
            menuImageView.contentMode = .scaleToFill
        }
        
        if info.place == .special || info.place == .secondCampus || info.type == .breakfast && info.imageUrl == nil {
            hideImageView()
        } else {
            menuImageView.isHidden = false
            leftMenuListLabel.snp.remakeConstraints { make in
                make.top.equalTo(menuImageView.snp.bottom).offset(12)
                make.leading.equalTo(menuImageView.snp.leading)
                make.trailing.equalTo(self.snp.centerX)
            }
            rightMenuListLabel.snp.remakeConstraints { make in
                make.top.equalTo(menuImageView.snp.bottom).offset(12)
                make.leading.equalTo(self.snp.centerX).offset(12)
                make.trailing.equalTo(self.menuImageView.snp.trailing)
            }
        }
        
        if info.type == .breakfast && info.imageUrl != nil && info.soldoutAt != nil {
            menuImageView.isHidden = true
            menuImageBackground.isUserInteractionEnabled = false
        }
    }
    
    private func hideImageView() {
        [menuImageView, nonMealImageView, nonMealText, menuImageBackground].forEach {
            $0.isHidden = true
        }
        leftMenuListLabel.snp.remakeConstraints { make in
            make.top.equalTo(diningPlaceLabel.snp.bottom).offset(16)
            make.leading.equalTo(diningPlaceLabel.snp.leading)
            make.trailing.equalTo(self.snp.centerX)
        }
        rightMenuListLabel.snp.remakeConstraints { make in
            make.top.equalTo(diningPlaceLabel.snp.bottom).offset(16)
            make.leading.equalTo(self.snp.centerX).offset(12)
            make.trailing.equalTo(self.menuImageView.snp.trailing)
        }
    }
    
    @objc func imageTapped(_ sender: UITapGestureRecognizer) {
        let diningText = diningPlaceLabel.text ?? ""
        imageTapPublisher.send((menuImageView.image ?? UIImage(), diningText))
    }
}

extension DiningCollectionViewCellA {
    private func setUpLayouts() {
        [diningPlaceLabel, diningInfoLabel, leftMenuListLabel, rightMenuListLabel, menuImageView, menuImageBackground, soldOutLabel, substitutionLabel, cellSpacingView, nonMealImageView, nonMealText, separateView, shareButton].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        diningPlaceLabel.snp.makeConstraints { make in
            make.top.equalTo(self.snp.top).offset(16)
            make.leading.equalTo(self.snp.leading).offset(24)
        }
        diningInfoLabel.snp.makeConstraints { make in
            make.top.equalTo(diningPlaceLabel.snp.top).offset(5)
            make.leading.equalTo(diningPlaceLabel.snp.trailing).offset(8)
        }
        menuImageView.snp.makeConstraints { make in
            make.top.equalTo(diningPlaceLabel.snp.bottom).offset(16)
            make.leading.equalTo(self.snp.leading).offset(21)
            make.trailing.equalTo(self.snp.trailing).offset(-21)
            make.height.equalTo(222)
        }
        leftMenuListLabel.snp.makeConstraints { make in
            make.top.equalTo(menuImageView.snp.bottom).offset(12)
            make.leading.equalTo(menuImageView.snp.leading)
            make.trailing.equalTo(self.snp.centerX)
        }
        rightMenuListLabel.snp.makeConstraints { make in
            make.top.equalTo(menuImageView.snp.bottom).offset(12)
            make.leading.equalTo(self.snp.centerX).offset(12)
            make.trailing.equalTo(self.menuImageView.snp.trailing)
        }
        separateView.snp.makeConstraints { make in
            make.top.equalTo(leftMenuListLabel.snp.bottom).offset(16)
            make.leading.equalTo(self.snp.leading)
            make.trailing.equalTo(self.snp.trailing)
            make.height.equalTo(1)
        }
        shareButton.snp.makeConstraints { make in
            make.top.equalTo(separateView.snp.bottom).offset(8)
            make.trailing.equalTo(self.snp.trailing).offset(-24)
            make.width.equalTo(74)
            make.height.equalTo(28)
        }
        soldOutLabel.snp.makeConstraints { make in
            make.width.equalTo(37)
            make.height.equalTo(22)
            make.top.equalTo(self.snp.top).offset(15)
            make.trailing.equalTo(self.snp.trailing).offset(-24)
        }
        substitutionLabel.snp.makeConstraints { make in
            make.width.equalTo(48)
            make.height.equalTo(soldOutLabel.snp.height)
            make.top.equalTo(soldOutLabel.snp.top)
            make.trailing.equalTo(soldOutLabel.snp.trailing)
        }
        menuImageBackground.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalTo(menuImageView)
        }
        cellSpacingView.snp.makeConstraints { make in
            make.top.equalTo(shareButton.snp.bottom).offset(10)
            make.leading.equalTo(self.snp.leading)
            make.trailing.equalTo(self.snp.trailing)
            make.height.equalTo(0)
            make.bottom.equalTo(self.snp.bottom)
        }
        nonMealImageView.snp.makeConstraints { make in
            make.centerX.equalTo(menuImageView.snp.centerX)
            make.top.equalTo(menuImageView.snp.top).offset(62.79)
            make.width.equalTo(57.99)
            make.height.equalTo(58.09)
        }
        nonMealText.snp.makeConstraints { make in
            make.top.equalTo(nonMealImageView.snp.bottom).offset(17.44)
            make.centerX.equalTo(nonMealImageView.snp.centerX)
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
        self.backgroundColor = .systemBackground
    }
}
