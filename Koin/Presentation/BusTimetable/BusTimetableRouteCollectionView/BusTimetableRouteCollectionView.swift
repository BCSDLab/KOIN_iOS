//
//  BusTimetableRouteCollectionView.swift
//  koin
//
//  Created by JOOMINKYUNG on 11/9/24.
//

import Combine
import UIKit

final class BusTimetableRouteCollectionView: UICollectionView {
    //MARK: - Properties
    private var routeList: [String] = []
    
    //MARK: - Initialization
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        register(BusTimetableRouteCollectionViewCell.self, forCellWithReuseIdentifier: NoticeKeywordCollectionViewCell.identifier)
        showsHorizontalScrollIndicator = false
        contentInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
    }
}

