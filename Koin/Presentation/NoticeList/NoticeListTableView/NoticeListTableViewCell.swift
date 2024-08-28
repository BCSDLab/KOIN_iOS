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
    private var boardTitle = UILabel().then {
        $0.font = .appFont(.pretendardBold, size: 12)
        $0.textAlignment = .left
        $0.textColor = .appColor(.primary600)
    }
    
    private let noticeTitle = UILabel().then {
        $0.font = .appFont(.pretendardMedium, size: 14)
        $0.textAlignment = .left
        $0.textColor = .appColor(.neutral800)
        $0.numberOfLines = 2
    }
    
    private let nickName = UILabel()
    
    private let createdDate = UILabel()
    
    private let separatorDot = UILabel().then {
        $0.text = "·"
    }
    
    private let separatorDot2 = UILabel().then {
        $0.text = "·"
    }
    
    private let eyeImage = UIImageView().then {
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
        boardTitle.text = "\(NoticeListType(rawValue: articleModel.boardId)?.displayName ?? "")공지"
        noticeTitle.setLineHeight(lineHeight: 1.3, text: articleModel.title)
        
        noticeTitle.lineBreakMode = .byTruncatingTail
        nickName.text = articleModel.nickname
        createdDate.text = articleModel.createdAt
        if articleModel.hit == 0 {
            [separatorDot2, eyeImage, hitLabel].forEach {
                $0.isHidden = true
            }
        }
        else {
            [separatorDot2, eyeImage, hitLabel].forEach {
                $0.isHidden = false
            }
            hitLabel.text = "\(articleModel.hit.formattedWithComma)"
        }
    }
    
}

extension NoticeListTableViewCell {
    private func setUpLabels() {
        [nickName, separatorDot, createdDate, separatorDot2, hitLabel].forEach {
            $0.font = .appFont(.pretendardRegular, size: 12)
            $0.textAlignment = .left
            $0.textColor = .appColor(.neutral500)
        }
    }
    
    private func setUpLayouts() {
        [boardTitle, noticeTitle, nickName, separatorDot, createdDate, separatorDot2, eyeImage, hitLabel].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        boardTitle.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalToSuperview().offset(24)
        }
        
        noticeTitle.snp.makeConstraints {
            $0.top.equalTo(boardTitle.snp.bottom)
            $0.leading.equalTo(boardTitle)
            $0.trailing.equalToSuperview().inset(24)
        }
        
        nickName.snp.makeConstraints {
            $0.top.equalTo(noticeTitle.snp.bottom).offset(4)
            $0.leading.equalTo(boardTitle)
            $0.height.equalTo(19)
        }
        
        separatorDot.snp.makeConstraints {
            $0.leading.equalTo(nickName.snp.trailing).offset(3)
            $0.top.equalTo(nickName)
            $0.width.equalTo(7)
            $0.height.equalTo(19)
        }
        
        createdDate.snp.makeConstraints {
            $0.leading.equalTo(separatorDot.snp.trailing).offset(3)
            $0.top.equalTo(nickName)
            $0.bottom.equalToSuperview().inset(12)
            $0.height.equalTo(19)
        }
        
        separatorDot2.snp.makeConstraints {
            $0.leading.equalTo(createdDate.snp.trailing).offset(3)
            $0.top.equalTo(nickName)
            $0.width.equalTo(7)
            $0.height.equalTo(19)
        }
        
        eyeImage.snp.makeConstraints {
            $0.leading.equalTo(separatorDot2.snp.trailing)
            $0.centerY.equalTo(nickName)
            $0.width.equalTo(16)
            $0.height.equalTo(13)
        }
        
        hitLabel.snp.makeConstraints {
            $0.leading.equalTo(eyeImage.snp.trailing)
            $0.top.equalTo(nickName)
            $0.height.equalTo(19)
        }
    }
    
    private func configureView() {
        setUpLabels()
        setUpLayouts()
        setUpConstraints()
    }
}
