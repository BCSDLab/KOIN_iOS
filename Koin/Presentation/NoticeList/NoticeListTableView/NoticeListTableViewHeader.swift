//
//  NoticeListTableViewHeader.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/18/24.
//

import SnapKit
import Then
import UIKit

final class NoticeListTableViewHeader: UITableViewHeaderFooterView {
    // MARK: - UIComponents
    private let noticeKeyWordCollectionView = NoticeKeyWordCollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
        let flowLayout = $0.collectionViewLayout as? UICollectionViewFlowLayout
        flowLayout?.scrollDirection = .horizontal
    }
    
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

extension NoticeListTableViewHeader {
    private func setUpLayouts() {
        addSubview(noticeKeyWordCollectionView)
    }
    
    private func setUpConstraints() {
        noticeKeyWordCollectionView.snp.makeConstraints {
            $0.leading.edges.equalToSuperview()
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
    }
}
