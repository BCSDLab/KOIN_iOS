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
    let keyWordAddBtnTapPublisher = PassthroughSubject<(), Never>()
    let keyWordTapPublisher = PassthroughSubject<NoticeKeyWordDTO, Never>()
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - UIComponents
    
    private let noticeKeyWordCollectionView = NoticeKeyWordCollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
        let flowLayout = $0.collectionViewLayout as? UICollectionViewFlowLayout
        flowLayout?.scrollDirection = .horizontal
    }
    
    // MARK: - Initialization
 
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureView()
        noticeKeyWordCollectionView.keyWordAddBtnTapPublisher.sink { [weak self] in
            self?.keyWordAddBtnTapPublisher.send()
        }.store(in: &subscriptions)
        noticeKeyWordCollectionView.keyWordTapPublisher.sink { [weak self] keyword in
            self?.keyWordTapPublisher.send(keyword)
        }.store(in: &subscriptions)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureView()
    }
    
    func updateKeyWordsList(keyWordList: [NoticeKeyWordDTO]) {
        noticeKeyWordCollectionView.updateUserKeyWordList(keyWordList: keyWordList)
    }
    
    func updateSelectedKeyWord(keyWord: String) {
        noticeKeyWordCollectionView.selectKeyWord(keyWord: keyWord)
    }
}

extension NoticeListTableViewKeyWordCell {
    private func setUpLayouts() {
        contentView.addSubview(noticeKeyWordCollectionView)
    }
    
    private func setUpConstraints() {
        noticeKeyWordCollectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
    }
}
