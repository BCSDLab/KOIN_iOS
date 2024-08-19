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
        $0.numberOfLines = 0
        $0.textColor = .appColor(.neutral800)
    }
    
    private let nickName = UILabel().then {
        $0.font = .appFont(.pretendardRegular, size: 12)
        $0.textAlignment = .left
        $0.textColor = .appColor(.neutral500)
    }
    
    private let createdDate = UILabel().then {
        $0.font = .appFont(.pretendardRegular, size: 12)
        $0.textAlignment = .left
        $0.textColor = .appColor(.neutral500)
    }
    
    private let separatorDot = UILabel().then {
        $0.text = "·"
        $0.font = .appFont(.pretendardRegular, size: 12)
        $0.textAlignment = .left
        $0.textColor = .appColor(.neutral500)
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
        boardTitle.text = NoticeListType(rawValue: articleModel.boardId)?.displayName
        noticeTitle.text = articleModel.title
        nickName.text = articleModel.nickname
        createdDate.text = articleModel.createdAt
    }
    
}

extension NoticeListTableViewCell {
    private func setUpLayouts() {
        [boardTitle, noticeTitle, nickName, separatorDot, createdDate].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        boardTitle.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalToSuperview().offset(24)
        }
        noticeTitle.snp.makeConstraints {
            $0.top.equalTo(boardTitle.snp.bottom).offset(4)
            $0.leading.equalTo(boardTitle)
            $0.trailing.equalToSuperview().inset(24)
        }
        nickName.snp.makeConstraints {
            $0.top.equalTo(noticeTitle.snp.bottom).offset(4)
            $0.leading.equalTo(boardTitle)
        }
        separatorDot.snp.makeConstraints {
            $0.leading.equalTo(nickName.snp.trailing).offset(2)
            $0.top.equalTo(nickName)
        }
        createdDate.snp.makeConstraints {
            $0.leading.equalTo(separatorDot.snp.trailing).offset(2)
            $0.top.equalTo(nickName)
            $0.bottom.equalToSuperview().inset(12)
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
    }
}
