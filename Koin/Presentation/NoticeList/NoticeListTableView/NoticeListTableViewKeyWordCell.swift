//
//  NoticeListTableViewKeyWordCell.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/18/24.
//

import Combine
import SnapKit
import Then
import UIKit

final class NoticeListTableViewKeyWordCell: UITableViewCell {
    // MARK: - Properties
    
    static let id = "NoticeListTableViewKeyWordCellIdentifier"
    let keywordAddBtnTapPublisher = PassthroughSubject<(), Never>()
    let keywordTapPublisher = PassthroughSubject<NoticeKeywordDTO, Never>()
    let manageKeyWordBtnTapPublisher = PassthroughSubject<(), Never>()
    var subscriptions = Set<AnyCancellable>()
    
    // MARK: - UIComponents
    
    private let noticeKeywordCollectionView = NoticeKeywordCollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
        let flowLayout = $0.collectionViewLayout as? UICollectionViewFlowLayout
        flowLayout?.scrollDirection = .horizontal
    }
   
    // MARK: - Initialization
 
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
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
    
    func updateKeyWordsList(keywordList: [NoticeKeywordDTO], keywordIdx: Int) {
        noticeKeywordCollectionView.updateUserKeywordList(keywordList: keywordList, keywordIdx: keywordIdx)
    }
}

extension NoticeListTableViewKeyWordCell {
    private func setUpLayouts() {
        contentView.addSubview(noticeKeywordCollectionView)
    }
    
    private func setUpConstraints() {
        noticeKeywordCollectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
    }
}
