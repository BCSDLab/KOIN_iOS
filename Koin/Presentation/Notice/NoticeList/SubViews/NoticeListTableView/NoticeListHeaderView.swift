//
//  NoticeListHeaderView.swift
//  koin
//
//  Created by 김나훈 on 2/18/25.
//

import Combine
import UIKit

final class NoticeListHeaderView: UITableViewHeaderFooterView {
    
    // MARK: - Properties
    let searchButtonTappedPublisher = PassthroughSubject<Void, Never>()
    let keywordAddBtnTapPublisher = PassthroughSubject<(), Never>()
    let keywordAllButtonTappedPublisher = PassthroughSubject<Void, Never>()
    let keywordTapPublisher = PassthroughSubject<NoticeKeywordDto, Never>()
    let manageKeyWordBtnTapPublisher = PassthroughSubject<(), Never>()
    
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
    
    // MARK: - Initialization
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureView()
    }
}
    
extension NoticeListHeaderView {
    func updateKeyWordsList(keywordList: [NoticeKeywordDto], selectedKeyword: NoticeKeywordDto?) {
        noticeKeywordScrollView.updateKeyWordsList(keywordList: keywordList, selectedKeyword: selectedKeyword)
    }
}

extension NoticeListHeaderView {
    
    private func setUpLayouts() {
        contentView.addSubview(noticeKeywordScrollView.view)
    }
    
    private func setUpConstraints() {
        noticeKeywordScrollView.view.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(34)
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
    }
}
