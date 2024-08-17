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
    }
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(color: UIColor) {
        self.backgroundColor = color
    }
}

extension PageCollectionViewCell {
    private func setUpLayouts() {
        [noticeKeyWordCollectionView, noticeTableView].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        noticeKeyWordCollectionView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(66)
        }
        
        noticeTableView.snp.makeConstraints {
            $0.top.equalTo(noticeKeyWordCollectionView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
    }
}

