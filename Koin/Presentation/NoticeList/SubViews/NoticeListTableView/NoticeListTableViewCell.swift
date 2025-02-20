//
//  NoticeListTableViewCell.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/13/24.
//

import SnapKit
import Then
import UIKit

final class NoticeListTableViewCell: UITableViewCell {
    //MARK: - UI Components
    private let boardTitleLabel = UILabel().then {
        $0.font = .appFont(.pretendardBold, size: 12)
        $0.textAlignment = .left
        $0.textColor = .appColor(.primary600)
    }
    
    private let noticeTitleLabel = UILabel().then {
        $0.font = .appFont(.pretendardMedium, size: 14)
        $0.textAlignment = .left
        $0.textColor = .appColor(.neutral800)
        $0.numberOfLines = 2
    }
    
    private let categoryLabel = UILabel().then {
        $0.textColor = UIColor.appColor(.neutral0)
        $0.backgroundColor = UIColor.appColor(.primary500)
        $0.layer.masksToBounds = true
        $0.textAlignment = .center
        $0.layer.cornerRadius = 10
        $0.font = UIFont.appFont(.pretendardMedium, size: 14)
    }
    
    private let nickNameLabel = UILabel()
    
    private let createdDateLabel = UILabel()
    
    private let separatorDotLabel = UILabel().then {
        $0.text = "·"
    }
    
    private let separatorDot2Label = UILabel().then {
        $0.text = "·"
    }
    
    private let eyeImageView = UIImageView().then {
        $0.image = .appImage(asset: .eye)
        $0.tintColor = .appColor(.neutral500)
    }
    
    private let hitLabel = UILabel()
    
    private let contentLabel = UILabel().then {
        $0.textColor = UIColor.appColor(.neutral800)
        $0.font = UIFont.appFont(.pretendardRegular, size: 12)
        $0.isHidden = true
    }
    
    private let reportedLabel = UILabel().then {
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = UIImage.appImage(asset: .blind)
        imageAttachment.bounds = CGRect(x: 0, y: -7, width: 24, height: 24)

        let attributedString = NSMutableAttributedString(attachment: imageAttachment)
        let text = NSAttributedString(string: " 신고에 의해 숨김 처리 되었습니다.", attributes: [.font: UIFont.appFont(.pretendardMedium, size: 15)])
        attributedString.append(text)
        $0.attributedText = attributedString
        $0.textColor = UIColor.appColor(.neutral500)
    }
    
    //MARK: -Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureView()
    }
    
    func configure(articleModel: NoticeArticleDTO) {
        if let type = articleModel.type {
            boardTitleLabel.text = "\(type.description)물"
        } else {
            boardTitleLabel.text = NoticeListType(rawValue: articleModel.boardId)?.displayName
        }
        
        noticeTitleLabel.lineBreakMode = .byTruncatingTail
        nickNameLabel.text = articleModel.author
        createdDateLabel.text = articleModel.registeredAt
        if articleModel.hit == 0 {
            [separatorDot2Label, eyeImageView, hitLabel].forEach {
                $0.isHidden = true
            }
        }
        else {
            [separatorDot2Label, eyeImageView, hitLabel].forEach {
                $0.isHidden = false
            }
            hitLabel.text = "\(articleModel.hit?.formattedWithComma ?? "")"
        }
        
        if articleModel.boardId == 14 {
            categoryLabel.isHidden = false
            [separatorDot2Label, eyeImageView, hitLabel].forEach {
                $0.isHidden = true
            }
            categoryLabel.text = articleModel.category
            noticeTitleLabel.setLineHeight(lineHeight: 1.3, text: "\(articleModel.foundPlace ?? "") | \(articleModel.foundDate ?? "")")
            categoryLabel.snp.remakeConstraints {
                $0.top.equalTo(boardTitleLabel.snp.bottom)
                $0.leading.equalTo(boardTitleLabel)
                $0.width.equalTo(categoryLabel.intrinsicContentSize.width + 20)
                $0.height.equalTo(22)
            }
            noticeTitleLabel.snp.remakeConstraints {
                $0.top.equalTo(boardTitleLabel.snp.bottom).offset(-2)
                $0.leading.equalTo(categoryLabel.snp.trailing).offset(8)
                $0.trailing.equalToSuperview().inset(24)
            }
            let isReported = articleModel.isReported ?? false
            reportedLabel.isHidden = !isReported
            contentLabel.isHidden = isReported
            categoryLabel.isHidden = isReported
            noticeTitleLabel.isHidden = isReported
        } else {
            reportedLabel.isHidden = true
            contentLabel.isHidden = false
            noticeTitleLabel.isHidden = false
            noticeTitleLabel.setLineHeight(lineHeight: 1.3, text: articleModel.title ?? "")
            categoryLabel.isHidden = true
            noticeTitleLabel.snp.remakeConstraints {
                $0.top.equalTo(boardTitleLabel.snp.bottom)
                $0.leading.equalTo(boardTitleLabel.snp.leading)
                $0.trailing.equalToSuperview().inset(24)
            }
            contentLabel.isHidden = true
        }
        contentLabel.text = articleModel.content
        nickNameLabel.snp.remakeConstraints {
            if articleModel.boardId == 14 { $0.top.equalTo(contentLabel.snp.bottom).offset(4) }
            else { $0.top.equalTo(noticeTitleLabel.snp.bottom).offset(4) }
            $0.leading.equalTo(boardTitleLabel)
        }
        
    }
    
}

extension NoticeListTableViewCell {
    private func setUpLabels() {
        [nickNameLabel, separatorDotLabel, createdDateLabel, separatorDot2Label, hitLabel].forEach {
            $0.font = .appFont(.pretendardRegular, size: 12)
            $0.textAlignment = .left
            $0.textColor = .appColor(.neutral500)
        }
    }
    
    private func setUpLayouts() {
        [boardTitleLabel, noticeTitleLabel, nickNameLabel, separatorDotLabel, createdDateLabel, separatorDot2Label, eyeImageView, hitLabel, categoryLabel, contentLabel, reportedLabel].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        boardTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalToSuperview().offset(24)
        }
        categoryLabel.snp.makeConstraints {
            $0.top.equalTo(boardTitleLabel.snp.bottom)
            $0.leading.equalTo(boardTitleLabel)
            $0.width.equalTo(65)
            $0.height.equalTo(22)
        }
        noticeTitleLabel.snp.makeConstraints {
            $0.top.equalTo(boardTitleLabel.snp.bottom).offset(-2)
            $0.leading.equalTo(categoryLabel.snp.trailing).offset(8)
            $0.trailing.equalToSuperview().inset(24)
        }
        nickNameLabel.snp.makeConstraints {
            $0.top.equalTo(noticeTitleLabel.snp.bottom).offset(4)
            $0.leading.equalTo(boardTitleLabel)
        }
        
        separatorDotLabel.snp.makeConstraints {
            $0.leading.equalTo(nickNameLabel.snp.trailing).offset(3)
            $0.top.equalTo(nickNameLabel)
            $0.width.equalTo(7)
        }
        
        createdDateLabel.snp.makeConstraints {
            $0.leading.equalTo(separatorDotLabel.snp.trailing).offset(3)
            $0.top.equalTo(nickNameLabel)
            $0.bottom.equalToSuperview().inset(12)
        }
        
        separatorDot2Label.snp.makeConstraints {
            $0.leading.equalTo(createdDateLabel.snp.trailing).offset(3)
            $0.top.equalTo(nickNameLabel)
            $0.width.equalTo(7)
        }
        
        eyeImageView.snp.makeConstraints {
            $0.leading.equalTo(separatorDot2Label.snp.trailing)
            $0.centerY.equalTo(nickNameLabel)
            $0.width.equalTo(16)
            $0.height.equalTo(13)
        }
        
        hitLabel.snp.makeConstraints {
            $0.leading.equalTo(eyeImageView.snp.trailing)
            $0.top.equalTo(nickNameLabel)
        }
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(noticeTitleLabel.snp.bottom).offset(4)
            make.leading.equalTo(categoryLabel)
            make.trailing.equalTo(self.snp.trailing).offset(-30)
        }
        reportedLabel.snp.makeConstraints { make in
            make.top.equalTo(boardTitleLabel.snp.bottom).offset(4)
            make.leading.equalTo(categoryLabel)
        }
    }
    
    private func configureView() {
        setUpLabels()
        setUpLayouts()
        setUpConstraints()
    }
}
