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
        let displayName = NoticeListType(rawValue: articleModel.boardId)?.displayName ?? ""
        boardTitleLabel.text = displayName == "분실물" ? displayName : "\(displayName)공지"
        
        
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
            hitLabel.text = "\(articleModel.hit.formattedWithComma)"
        }
        
        if articleModel.boardId == 14 {
            categoryLabel.isHidden = false
            [separatorDot2Label, eyeImageView, hitLabel].forEach {
                $0.isHidden = true
            }
            let components = articleModel.title.components(separatedBy: " | ")
            if components.count == 3 {
                let category = components[0].trimmingCharacters(in: .whitespacesAndNewlines)
                let title = "\(components[1]) | \(components[2])".trimmingCharacters(in: .whitespacesAndNewlines)
                categoryLabel.text = category
                noticeTitleLabel.setLineHeight(lineHeight: 1.3, text: title)
            }
            categoryLabel.snp.remakeConstraints {
                $0.top.equalTo(boardTitleLabel.snp.bottom)
                $0.leading.equalTo(boardTitleLabel)
                $0.width.equalTo(65)
                $0.height.equalTo(22)
            }
            noticeTitleLabel.snp.remakeConstraints {
                $0.top.equalTo(boardTitleLabel.snp.bottom).offset(-2)
                $0.leading.equalTo(categoryLabel.snp.trailing).offset(8)
                $0.trailing.equalToSuperview().inset(24)
            }
        } else {
            noticeTitleLabel.setLineHeight(lineHeight: 1.3, text: articleModel.title)
            categoryLabel.isHidden = true
            noticeTitleLabel.snp.remakeConstraints {
                $0.top.equalTo(boardTitleLabel.snp.bottom)
                $0.leading.equalTo(boardTitleLabel.snp.leading)
                $0.trailing.equalToSuperview().inset(24)
            }
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
        [boardTitleLabel, noticeTitleLabel, nickNameLabel, separatorDotLabel, createdDateLabel, separatorDot2Label, eyeImageView, hitLabel, categoryLabel].forEach {
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
    }
    
    private func configureView() {
        setUpLabels()
        setUpLayouts()
        setUpConstraints()
    }
}
