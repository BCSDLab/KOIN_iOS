//
//  AddLostArticleCollectionViewCell.swift
//  koin
//
//  Created by 김나훈 on 1/13/25.
//

import Combine
import UIKit

final class AddLostArticleCollectionViewCell: UICollectionViewCell {
    
    var cancellables = Set<AnyCancellable>()
    
    private let textViewPlaceHolder = "물품이나 습득 장소에 대한 추가 설명이 있다면 작성해주세요."
    
    private let separateView = UIView().then {
        $0.backgroundColor = UIColor.appColor(.neutral100)
    }
    
    private let itemCountLabel = UILabel().then {
        $0.textColor = UIColor.appColor(.primary600)
        $0.backgroundColor = UIColor.appColor(.info200)
        $0.textAlignment = .center
        $0.font = UIFont.appFont(.pretendardMedium, size: 14)
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 12
    }
    
    private let pictureLabel = UILabel().then {
        $0.text = "사진"
    }
    
    private let pictureMessageLabel = UILabel().then {
        $0.text = "습득물 사진을 업로드해주세요."
        $0.font = UIFont.appFont(.pretendardRegular, size: 12)
        $0.textColor = UIColor.appColor(.gray)
    }
    
    private let pictureCountLabel = UILabel().then {
        $0.text = "0/10"
        $0.font = UIFont.appFont(.pretendardRegular, size: 12)
        $0.textColor = UIColor.appColor(.gray)
    }
    
    private let addPictureButton = UIButton().then {
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage.appImage(asset: .picture)
        var text = AttributedString("사진 등록하기")
        text.font = UIFont.appFont(.pretendardMedium, size: 14)
        configuration.attributedTitle = text
        configuration.imagePadding = 4
        configuration.baseForegroundColor = UIColor.appColor(.primary600)
        $0.backgroundColor = UIColor.appColor(.info200)
        $0.configuration = configuration
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 8
    }
    
    private let categoryLabel = UILabel().then {
        $0.text = "품목"
    }
    
    private let categoryMessageLabel = UILabel().then {
        $0.text = "품목을 선택해주세요."
    }
    
    private let categoryStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .fill
        $0.distribution = .equalSpacing
    }
    
    private let dateLabel = UILabel().then {
        $0.text = "습득 일자"
    }
    
    private let dateButton = UIButton().then {
        $0.backgroundColor = UIColor.appColor(.neutral100)
        $0.layer.cornerRadius = 8
        $0.layer.masksToBounds = true
    }
    
    private let locationLabel = UILabel().then {
        $0.text = "습득 장소"
    }
    
    private let locationTextField = UITextField().then {
        $0.backgroundColor = UIColor.appColor(.neutral100)
        $0.font = UIFont.appFont(.pretendardRegular, size: 12)
        $0.attributedPlaceholder = NSAttributedString(
            string: "습득 장소를 입력해주세요.",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.appColor(.neutral500)]
        )
        $0.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: $0.frame.height))
        $0.leftViewMode = .always
        $0.layer.cornerRadius = 8
        $0.layer.masksToBounds = true
    }
    
    private let contentLabel = UILabel().then {
        $0.text = "내용"
    }
    
    private let contentTextCountLabel = UILabel().then {
        $0.text = "0/1000"
    }
    
    private lazy var contentTextView = UITextView().then {
        $0.backgroundColor = UIColor.appColor(.neutral100)
        $0.font = UIFont.appFont(.pretendardRegular, size: 12)
        $0.textContainerInset = UIEdgeInsets(top: 8, left: 10, bottom: 0, right: 0)
        $0.textColor = UIColor.appColor(.neutral500)
        $0.layer.cornerRadius = 8
        $0.layer.masksToBounds = true
        $0.text = textViewPlaceHolder
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        contentTextView.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(text: String) {
        
    }
}

extension AddLostArticleCollectionViewCell: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == textViewPlaceHolder && textView.textColor == UIColor.appColor(.neutral500) {
            textView.text = ""
            textView.textColor = UIColor.appColor(.neutral800)
        }
    }

       func textViewDidEndEditing(_ textView: UITextView) {
           if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
               textView.text = textViewPlaceHolder
               textView.textColor = UIColor.appColor(.neutral500)
           }
       }
    
}

extension AddLostArticleCollectionViewCell {
    private func setUpLayouts() {
        [separateView, itemCountLabel, pictureLabel, pictureMessageLabel, pictureCountLabel, addPictureButton, categoryLabel, categoryMessageLabel, categoryStackView, dateLabel, dateButton, locationLabel, locationTextField, contentLabel, contentTextCountLabel, contentTextView].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        separateView.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top)
            make.leading.trailing.equalToSuperview()
            make.width.equalTo(contentView.snp.width)
            make.height.equalTo(6)
        }
        itemCountLabel.snp.makeConstraints { make in
            make.top.equalTo(separateView.snp.bottom).offset(16)
            make.leading.equalTo(contentView.snp.leading).offset(24)
            make.width.equalTo(70)
            make.height.equalTo(30)
        }
        pictureLabel.snp.makeConstraints { make in
            make.top.equalTo(itemCountLabel.snp.bottom).offset(16)
            make.leading.equalTo(itemCountLabel.snp.leading)
            make.height.equalTo(22)
        }
        pictureMessageLabel.snp.makeConstraints { make in
            make.top.equalTo(pictureLabel.snp.bottom)
            make.leading.equalTo(itemCountLabel.snp.leading)
            make.height.equalTo(19)
        }
        pictureCountLabel.snp.makeConstraints { make in
            make.top.equalTo(pictureLabel.snp.bottom)
            make.trailing.equalTo(addPictureButton.snp.trailing)
            make.height.equalTo(19)
        }
        addPictureButton.snp.makeConstraints { make in
            make.top.equalTo(pictureMessageLabel.snp.bottom).offset(16)
            make.leading.equalTo(itemCountLabel.snp.leading)
            make.trailing.equalTo(contentView.snp.trailing).offset(-24)
            make.height.equalTo(38)
        }
        categoryLabel.snp.makeConstraints { make in
            make.top.equalTo(addPictureButton.snp.bottom).offset(24)
            make.leading.equalTo(itemCountLabel.snp.leading)
            make.height.equalTo(22)
        }
        categoryMessageLabel.snp.makeConstraints { make in
            make.top.equalTo(categoryLabel.snp.bottom)
            make.leading.equalTo(itemCountLabel.snp.leading)
            make.height.equalTo(19)
        }
        categoryStackView.snp.makeConstraints { make in
            make.top.equalTo(categoryMessageLabel.snp.bottom).offset(12)
            make.leading.equalTo(contentView.snp.leading).offset(29.5)
            make.trailing.equalTo(contentView.snp.trailing).offset(-29.5)
            make.height.equalTo(38)
        }
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(categoryStackView.snp.bottom).offset(16)
            make.leading.equalTo(itemCountLabel.snp.leading)
            make.height.equalTo(22)
        }
        dateButton.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.bottom).offset(8)
            make.leading.equalTo(itemCountLabel.snp.leading)
            make.height.equalTo(40)
            make.trailing.equalTo(contentView.snp.trailing).offset(-24)
        }
        locationLabel.snp.makeConstraints { make in
            make.top.equalTo(dateButton.snp.bottom).offset(16)
            make.leading.equalTo(itemCountLabel.snp.leading)
            make.height.equalTo(22)
        }
        locationTextField.snp.makeConstraints { make in
            make.top.equalTo(locationLabel.snp.bottom).offset(8)
            make.leading.equalTo(itemCountLabel.snp.leading)
            make.trailing.equalTo(dateButton.snp.trailing)
            make.height.equalTo(35)
        }
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(locationTextField.snp.bottom).offset(16)
            make.leading.equalTo(itemCountLabel.snp.leading)
            make.height.equalTo(22)
        }
        contentTextCountLabel.snp.makeConstraints { make in
            make.top.equalTo(contentLabel.snp.top)
            make.trailing.equalTo(dateButton.snp.trailing)
            make.height.equalTo(19)
        }
        contentTextView.snp.makeConstraints { make in
            make.top.equalTo(contentLabel.snp.bottom).offset(8)
            make.leading.equalTo(itemCountLabel.snp.leading)
            make.trailing.equalTo(dateButton.snp.trailing)
            make.height.greaterThanOrEqualTo(59)
            make.bottom.equalTo(contentView.snp.bottom).offset(-10)
        }
    }
    
    private func setUpAttributes() {
        [pictureMessageLabel, pictureCountLabel, categoryMessageLabel, contentTextCountLabel].forEach {
            $0.font = UIFont.appFont(.pretendardMedium, size: 12)
            $0.textColor = UIColor.appColor(.neutral500)
        }
        [pictureLabel, categoryLabel, dateLabel, locationLabel, contentLabel].forEach {
            $0.textColor = UIColor.appColor(.neutral800)
            $0.font = UIFont.appFont(.pretendardMedium, size: 15)
        }
    }
    
    private func setUpStackView() {
        let items = ["카드", "신분증", "지갑", "전자제품", "그 외"]
        let widths = [49, 61, 49, 73, 52]
        
        let buttons: [UIButton] = zip(items, widths).enumerated().map { index, element in
            let (title, width) = element
            let button = UIButton(type: .system)
            var configuration = UIButton.Configuration.filled()
            configuration.title = title
            configuration.baseForegroundColor = UIColor.appColor(.primary500)
            configuration.baseBackgroundColor = UIColor.appColor(.neutral0)
            configuration.cornerStyle = .medium
            button.configuration = configuration
            
            let attributedTitle = AttributedString(title, attributes: AttributeContainer([
                .font: UIFont.appFont(.pretendardMedium, size: 14)
            ]))
            button.configuration?.attributedTitle = attributedTitle
            
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.appColor(.primary500).cgColor
            button.layer.cornerRadius = 14
            button.clipsToBounds = true
            button.titleLabel?.numberOfLines = 1
            button.titleLabel?.textAlignment = .center
            button.tag = index
            button.widthAnchor.constraint(equalToConstant: CGFloat(width)).isActive = true
            return button
        }
        
        buttons.forEach { button in
            categoryStackView.addArrangedSubview(button)
        }
        
        categoryStackView.axis = .horizontal
        categoryStackView.alignment = .fill
        categoryStackView.distribution = .equalSpacing
        categoryStackView.spacing = 8
    }
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
        setUpAttributes()
        setUpStackView()
    }
}
