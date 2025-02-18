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
    
    let keywordAddBtnTapPublisher = PassthroughSubject<(), Never>()
    let keywordTapPublisher = PassthroughSubject<NoticeKeywordDTO, Never>()
    let manageKeyWordBtnTapPublisher = PassthroughSubject<(), Never>()
    var subscriptions = Set<AnyCancellable>()
    
    // MARK: - UI Components
    
    private let noticeKeywordCollectionView: NoticeKeywordCollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        return NoticeKeywordCollectionView(frame: .zero, collectionViewLayout: flowLayout)
    }()
    // MARK: - Initialization
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        configureView()
        noticeKeywordCollectionView.keywordAddBtnTapPublisher.sink { [weak self] in
            self?.keywordAddBtnTapPublisher.send()
        }.store(in: &noticeKeywordCollectionView.subscriptions)
        noticeKeywordCollectionView.keywordTapPublisher.sink { [weak self] keyword in
            self?.keywordTapPublisher.send(keyword)
        }.store(in: &noticeKeywordCollectionView.subscriptions)
        noticeKeywordCollectionView.manageKeyWordBtnTapPublisher.sink { [weak self] in
            self?.manageKeyWordBtnTapPublisher.send()
        }.store(in: &noticeKeywordCollectionView.subscriptions)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        subscriptions.removeAll()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureView()
    }
    
    
}

extension NoticeListHeaderView {
    func updateKeyWordsList(keywordList: [NoticeKeywordDTO], keywordIdx: Int) {
        noticeKeywordCollectionView.updateUserKeywordList(keywordList: keywordList, keywordIdx: keywordIdx)
    }
}

extension NoticeListHeaderView {
    
    private func setUpLayouts() {
        contentView.addSubview(noticeKeywordCollectionView)
    }
    
    private func setUpConstraints() {
        noticeKeywordCollectionView.snp.makeConstraints {
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
