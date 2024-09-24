//
//  HotNoticeArticlesTableViewCell.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/19/24.
//

import SnapKit
import Then
import UIKit

final class HotNoticeArticlesTableViewCell: UITableViewCell {
    //MARK: - UI Components
    private let boardTitleLabel = UILabel().then {
        $0.font = .appFont(.pretendardBold, size: 12)
        $0.textAlignment = .left
        $0.textColor = .appColor(.primary600)
    }
    
    private let noticeTitleLabel = UILabel().then {
        $0.font = .appFont(.pretendardMedium, size: 14)
        $0.textAlignment = .left
        $0.numberOfLines = 1
        $0.lineBreakMode = .byTruncatingTail
        $0.textColor = .appColor(.neutral800)
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
        boardTitleLabel.text = NoticeListType(rawValue: articleModel.boardId)?.displayName
        noticeTitleLabel.text = articleModel.title
    }
}

extension HotNoticeArticlesTableViewCell {
    private func setUpLayouts() {
        [boardTitleLabel, noticeTitleLabel].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        boardTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(13.5)
            $0.leading.equalToSuperview().offset(24)
            $0.width.equalTo(25)
        }
        noticeTitleLabel.snp.makeConstraints {
            $0.top.equalTo(boardTitleLabel)
            $0.leading.equalTo(boardTitleLabel.snp.trailing).offset(8)
            $0.trailing.equalToSuperview().inset(24)
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
    }
}
