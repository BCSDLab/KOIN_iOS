//
//  MenuSectionHeaderView.swift
//  koin
//
//  Created by 김나훈 on 4/11/24.
//


import UIKit

class MenuSectionHeaderView: UICollectionReusableView {
    static let identifier = "MenuSectionHeaderView"
    
    private let titleLabel = UILabel().then {
        $0.font = UIFont.preferredFont(forTextStyle: .headline)
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setText(text: String) {
        let textImage: UIImage?
        switch text {
        case "추천 메뉴": textImage = UIImage.appImage(asset: .recommandMenu)
        case "메인 메뉴": textImage = UIImage.appImage(asset: .titleMenu)
        case "세트 메뉴": textImage = UIImage.appImage(asset: .setMenu)
        default: textImage = UIImage.appImage(asset: .sideMenu)
        }
        setTextWithImage(text: text, image: textImage)
    }
    
    private func setTextWithImage(text: String, image: UIImage?) {
        let attributeString = NSMutableAttributedString(string: "")
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.appFont(.pretendardMedium, size: 18),
            .foregroundColor: UIColor.appColor(.primary400),
            .baselineOffset: 0
        ]
        
        let imageAttachment = NSTextAttachment(image: image ?? UIImage())
        imageAttachment.bounds = CGRect(x: 0, y: -3, width: 21, height: 19.4)
        attributeString.append(NSAttributedString(attachment: imageAttachment))
        attributeString.append(NSAttributedString(string: "  "))
        attributeString.append(NSAttributedString(string: text))
        attributeString.addAttributes(attributes, range: NSRange(location: 0, length: attributeString.length))
        titleLabel.attributedText = attributeString
    }
    
    private func setupViews() {
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(self.snp.top).offset(16)
            make.leading.equalTo(self.snp.leading).offset(24)
            make.trailing.equalTo(self.snp.trailing).offset(-24)
            make.bottom.equalTo(self.snp.bottom)
        }
    }
}
