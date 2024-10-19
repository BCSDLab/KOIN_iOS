//
//  DiningCollectionViewCell.swift
//  Koin
//
//  Created by 김나훈 on 3/15/24.
//

import Combine
import SnapKit
import UIKit

final class DiningCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    let imageTapPublisher = PassthroughSubject<(UIImage, String), Never>()
    let shareButtonPublisher = PassthroughSubject<Void, Never>()
    let likeButtonPublisher = PassthroughSubject<Void, Never>()
    var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    private let wrappedView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    private let diningPlaceLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.appColor(.neutral800)
        label.font = UIFont.appFont(.pretendardBold, size: 18)
        return label
    }()
    
    private let diningInfoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appFont(.pretendardRegular, size: 12)
        label.textColor = UIColor.appColor(.neutral500)
        return label
    }()
    
    private let soldOutLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.layer.cornerRadius = 4
        label.clipsToBounds = true
        label.text = "품절"
        label.font = UIFont.appFont(.pretendardMedium, size: 12)
        label.backgroundColor = UIColor.appColor(.warning200)
        label.textColor = UIColor.appColor(.warning600)
        return label
    }()
    
    private let substitutionLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.layer.cornerRadius = 4
        label.clipsToBounds = true
        label.text = "변경됨"
        label.font = UIFont.appFont(.pretendardMedium, size: 12)
        label.backgroundColor = UIColor.appColor(.neutral200)
        label.textColor = UIColor.appColor(.neutral600)
        return label
    }()
    
    private let menuImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    private let menuImageBackground: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        return view
    }()
    
    private let leftMenuListLabel: UILabel = {
        let label = UILabel()
        label.textColor = .appColor(.neutral800)
        label.font = UIFont.appFont(.pretendardRegular, size: 14)
        label.numberOfLines = 0
        return label
    }()
    
    private let rightMenuListLabel: UILabel = {
        let label = UILabel()
        label.textColor = .appColor(.neutral800)
        label.font = UIFont.appFont(.pretendardRegular, size: 14)
        label.numberOfLines = 0
        return label
    }()
    
    private let separateView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.appColor(.neutral100)
        return view
    }()
    
    private let cellSpacingView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.appColor(.neutral100)
        return view
    }()
    
    private let nonMealImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.appImage(asset: .noMeal)
        return imageView
    }()
    
    private let nonMealText: UILabel = {
        let label = UILabel()
        label.text = "품절된 메뉴입니다."
        label.textColor = UIColor.appColor(.neutral0)
        label.font = UIFont.appFont(.pretendardRegular, size: 12)
        return label
    }()
    
    /*
    private let likeButton: UIButton = {
        let button = UIButton()
        return button
    }()
    
    private let buttonSpacingView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.appColor(.neutral400)
        return view
    }() */
    
    private let shareButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .appColor(.neutral50)
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage.appImage(asset: .share)
        var attributedTitle = AttributedString(stringLiteral: "카카오톡으로 식단 공유하기")
        attributedTitle.font = UIFont.appFont(.pretendardRegular, size: 14)
        configuration.attributedTitle = attributedTitle
        configuration.imagePadding = 4
        configuration.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
        button.configuration = configuration
        button.tintColor = UIColor.appColor(.neutral600)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        menuImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageTapped)))
        menuImageBackground.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageTapped)))
        /*
         likeButton.addTarget(self, action: #selector(likeButtonTapped), for: .touchUpInside) */
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
    
    @objc private func likeButtonTapped() {
        likeButtonPublisher.send(())
    }
    
    @objc private func shareButtonTapped() {
        shareButtonPublisher.send(())
    }
    
    func updateLikeButtonText(isLiked: Bool, likeCount: Int) {
        var configuration = UIButton.Configuration.plain()
        configuration.image = isLiked ? UIImage.appImage(asset: .heartFill) : UIImage.appImage(asset: .heart)
        var text = AttributedString(likeCount == 0 ? "좋아요" : "\(likeCount)")
        text.font = UIFont.appFont(.pretendardRegular, size: 12)
        configuration.attributedTitle = text
        configuration.imagePadding = 4
        configuration.baseBackgroundColor = .systemBackground
        configuration.baseForegroundColor = UIColor.appColor(.neutral600)
        //likeButton.contentHorizontalAlignment = .leading
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 0)
        //likeButton.configuration = configuration
    }
    
    func configure(info: DiningItem) {
        diningPlaceLabel.text = info.place.rawValue
        updateLikeButtonText(isLiked: info.isLiked, likeCount: info.likes)
        
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
        paragraphStyle.lineSpacing = 3.4

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

extension DiningCollectionViewCell {
    private func setUpLayouts() {
        contentView.addSubview(wrappedView)
        [diningPlaceLabel, diningInfoLabel, leftMenuListLabel, rightMenuListLabel, menuImageView, menuImageBackground, soldOutLabel, substitutionLabel, cellSpacingView, nonMealImageView, nonMealText, separateView, shareButton].forEach {
            wrappedView.addSubview($0)
        }
        
    }
    
    private func setUpConstraints() {
        wrappedView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        diningPlaceLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(24)
        }
        diningInfoLabel.snp.makeConstraints { make in
            make.top.equalTo(diningPlaceLabel.snp.top).offset(5)
            make.trailing.equalToSuperview().inset(20)
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
        /*
        likeButton.snp.makeConstraints { make in
            make.top.equalTo(separateView.snp.bottom).offset(8)
            make.trailing.equalTo(buttonSpacingView.snp.leading).offset(-6)
            make.width.equalTo(74)
            make.height.equalTo(28)
        }
        buttonSpacingView.snp.makeConstraints { make in
            make.centerY.equalTo(likeButton.snp.centerY)
            make.trailing.equalTo(shareButton.snp.leading).offset(-6)
            make.width.equalTo(0.5)
            make.height.equalTo(10)
        }*/
        soldOutLabel.snp.makeConstraints { make in
             make.width.equalTo(37)
             make.height.equalTo(22)
             make.top.equalTo(self.snp.top).offset(15)
             make.trailing.equalTo(self.snp.trailing).offset(-24)
         }
        shareButton.snp.makeConstraints { make in
            make.top.equalTo(separateView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(50)
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
        wrappedView.layer.cornerRadius = 16
        wrappedView.backgroundColor = .systemBackground
        wrappedView.clipsToBounds = true
        contentView.layer.applySketchShadow(color: .appColor(.neutral800), alpha: 0.04, x: 0, y: 1, blur: 1, spread: 0)
    }
}
