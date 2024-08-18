//
//  PageCollectionViewCell.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/13/24.
//

import Combine
import SnapKit
import UIKit
import Then

final class PageCollectionViewCell: UICollectionViewCell {
    // MARK: - UI Components
    private let noticeKeyWordCollectionView = NoticeKeyWordCollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
        let flowLayout = $0.collectionViewLayout as? UICollectionViewFlowLayout
        flowLayout?.scrollDirection = .horizontal
    }
    
    private let noticeTableView = NoticeListTableView(frame: .zero, style: .plain).then {
        $0.backgroundColor = .white
        $0.separatorStyle = .singleLine
        $0.isScrollEnabled = false
    }
    
    private let scrollView = UIScrollView()

    private let contentViewInScrollView = UIView()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(noticeArticleList: [NoticeArticleDTO]) {
        noticeTableView.updateNoticeList(noticeArticleList: noticeArticleList)
    }
}

extension PageCollectionViewCell {
    private func setUpLayouts() {
        contentView.addSubview(scrollView)
        scrollView.addSubview(contentViewInScrollView)
        
        [noticeKeyWordCollectionView, noticeTableView].forEach {
            contentViewInScrollView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        contentViewInScrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(scrollView)
        }
        
        noticeKeyWordCollectionView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(66)
        }
        
        noticeTableView.snp.makeConstraints {
            $0.top.equalTo(noticeKeyWordCollectionView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(110 * 10)
            $0.bottom.equalToSuperview()
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
    }
}
