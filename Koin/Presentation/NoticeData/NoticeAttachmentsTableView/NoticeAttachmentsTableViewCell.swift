//
//  NoticeAttachmentsTableViewCell.swift
//  koin
//
//  Created by JOOMINKYUNG on 9/15/24.
//

import Combine
import SnapKit
import Then
import UIKit

final class NoticeAttachmentsTableViewCell: UITableViewCell {
    //MARK: - Properties
    
    let tapDownloadButtonPublisher = PassthroughSubject<Void, Never>()
    
    //MARK: - UI Components
    private let attachmentTitleLabel = UILabel().then {
        $0.font = .appFont(.pretendardMedium, size: 14)
        $0.textAlignment = .left
        $0.numberOfLines = 1
        $0.lineBreakMode = .byTruncatingTail
        $0.textColor = .appColor(.neutral600)
    }
    
    private let attachmentSizeLabel = UILabel().then {
        $0.font = .appFont(.pretendardRegular, size: 12)
        $0.textAlignment = .left
        $0.textColor = .appColor(.neutral500)
    }
    
    private let downloadButton = UIButton().then {
        $0.setImage(.appImage(asset: .download), for: .normal)
    }
    
    private let wrappedView = UIView().then {
        $0.backgroundColor = .appColor(.neutral200)
        $0.layer.cornerRadius = 8
    }
    
    //MARK: -Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        downloadButton.addTarget(self, action: #selector(downloadButtonTapped), for: .touchUpInside)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureView()
    }
    
    func configure(attachmentTitle: String, fileSize: String) {
        attachmentTitleLabel.text = attachmentTitle
        attachmentSizeLabel.text = fileSize
    }
    
    @objc private func downloadButtonTapped() {
        tapDownloadButtonPublisher.send()
    }
}

extension NoticeAttachmentsTableViewCell {
    private func setUpLayouts() {
        contentView.addSubview(wrappedView)
        [attachmentSizeLabel, attachmentTitleLabel, downloadButton].forEach {
            wrappedView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        wrappedView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview().inset(8)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().inset(24)
        }
        attachmentTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(9)
            $0.leading.equalTo(24)
            $0.trailing.equalToSuperview().inset(55)
        }
        downloadButton.snp.makeConstraints {
            $0.width.equalTo(15)
            $0.height.equalTo(15)
            $0.trailing.equalToSuperview().inset(21)
            $0.centerY.equalToSuperview()
        }
        attachmentSizeLabel.snp.makeConstraints {
            $0.leading.equalTo(attachmentTitleLabel)
            $0.height.equalTo(19)
            $0.bottom.equalToSuperview().inset(8)
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
    }
}
