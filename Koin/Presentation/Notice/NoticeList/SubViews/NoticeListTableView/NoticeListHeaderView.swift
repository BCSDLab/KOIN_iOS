//
//  NoticeListHeaderView.swift
//  koin
//
//  Created by 김나훈 on 2/18/25.
//

import Combine
import UIKit
import SwiftUI

final class NoticeListHeaderView: UITableViewHeaderFooterView {
    
    // MARK: - Properties
    let searchButtonTappedPublisher = PassthroughSubject<Void, Never>()
    let keywordAddBtnTapPublisher = PassthroughSubject<(), Never>()
    let keywordAllButtonTappedPublisher = PassthroughSubject<Void, Never>()
    let keywordTapPublisher = PassthroughSubject<NoticeKeywordDto, Never>()
    let manageKeyWordBtnTapPublisher = PassthroughSubject<(), Never>()
    
    let typeButtonPublisher = PassthroughSubject<Void, Never>()
    
    // MARK: - UI Components
    private(set) lazy var noticeKeywordScrollView = NoticeKeywordScrollViewHostingController(
        searchButtonTapped: { [weak self] in
            self?.searchButtonTappedPublisher.send()
        },
        manageButtonTapped: { [weak self] in
            self?.manageKeyWordBtnTapPublisher.send()
        },
        keywordAllButtonTapped: { [weak self] in
            self?.keywordAllButtonTappedPublisher.send()
        },
        keywordButtonTapped: { [weak self] keyword in
            self?.keywordTapPublisher.send(keyword)
        },
        addButtonTapped: { [weak self] in
            self?.keywordAddBtnTapPublisher.send()
        }
    )
    
    private let typeButton = UIButton().then {
        $0.isHidden = true
        var configuration = UIButton.Configuration.plain()
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 10, weight: .medium)
        let image = UIImage(systemName: "chevron.down", withConfiguration: symbolConfig)
        configuration.image = image
        var text = AttributedString("물품 전체")
        text.font = UIFont.appFont(.pretendardMedium, size: 14)
        configuration.attributedTitle = text
        configuration.imagePadding = 4
        configuration.baseForegroundColor = UIColor.appColor(.primary600)
        configuration.imagePlacement = .trailing
        $0.backgroundColor = UIColor.appColor(.info200)
        $0.configuration = configuration
        $0.layer.cornerRadius = 12
        $0.layer.masksToBounds = true
    }
    
    // MARK: - Initialization
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        configureView()
        typeButton.addTarget(self, action: #selector(typeButtonTapped), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureView()
    }
}
    
extension NoticeListHeaderView {
    @objc private func typeButtonTapped() {
        typeButtonPublisher.send()
    }

    func setText(type: LostItemType?) {
        let buttonText: String
        switch type {
        case .lost, .found: buttonText = "\(type?.description ?? "")물"
        case nil: buttonText = "물품 전체"
        }
        var configuration = UIButton.Configuration.plain()
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 10, weight: .medium)
        let image = UIImage(systemName: "chevron.down", withConfiguration: symbolConfig)
        configuration.image = image
        var text = AttributedString(buttonText)
        text.font = UIFont.appFont(.pretendardMedium, size: 14)
        configuration.attributedTitle = text
        configuration.imagePadding = 4
        configuration.baseForegroundColor = UIColor.appColor(.primary600)
        configuration.imagePlacement = .trailing
        typeButton.backgroundColor = UIColor.appColor(.info200)
        typeButton.configuration = configuration
        typeButton.layer.cornerRadius = 12
        typeButton.layer.masksToBounds = true
    }
    func toggleButton(isHidden: Bool) {
        typeButton.isHidden = isHidden
    }

    
    func updateKeyWordsList(keywordList: [NoticeKeywordDto], selectedKeyword: NoticeKeywordDto?) {
        noticeKeywordScrollView.updateKeyWordsList(keywordList: keywordList, selectedKeyword: selectedKeyword)
    }
}

extension NoticeListHeaderView {
    
    private func setUpLayouts() {
        contentView.addSubview(noticeKeywordScrollView.view)
        contentView.addSubview(typeButton)
    }
    
    private func setUpConstraints() {
        noticeKeywordScrollView.view.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(34)
        }
        typeButton.snp.makeConstraints {
            $0.top.equalTo(noticeKeywordScrollView.view.snp.bottom).offset(16)
            $0.trailing.equalToSuperview().offset(-24)
            $0.width.equalTo(96)
            $0.height.equalTo(32)
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
    }
}
