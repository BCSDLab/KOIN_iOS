//
//  LostItemKeywordLeftAlignedCollectionView.swift
//  koin
//
//  Created by 홍기정 on 5/12/26.
//

import UIKit
import Combine

final class LostItemKeywordLeftAlignedCollectionView: UICollectionView {
    
    enum Action {
        case delete
        case add
    }
    
    // MARK: - Properties
    let didLayoutSubviewsPublisher = PassthroughSubject<CGFloat, Never>()
    let didTapItemPublisher = PassthroughSubject<LostItemKeyword, Never>()
    private var keywords: [LostItemKeyword] = []
    private let action: Action
    private var height: CGFloat = 0
    
    // MARK: - Initializer
    init(action: Action) {
        self.action = action
        let layout = LeftAlignedFlowLayout().then {
            $0.minimumInteritemSpacing = 8
            $0.minimumLineSpacing = 8
            $0.scrollDirection = .vertical
        }
        super.init(frame: .zero, collectionViewLayout: layout)
        commonInit()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func layoutSubviews() {
        super.layoutSubviews()
        let height = contentSize.height
        if self.height != height {
            self.height = height
            didLayoutSubviewsPublisher.send(height)
        }
    }
    
    // MARK: - Public
    func configure(keywords: [String]) {
        self.keywords = keywords.map { LostItemKeyword(id: nil, keyword: $0) }
        reloadSections([0])
    }
    
    func configure(keywords: [LostItemKeyword]) {
        self.keywords = keywords
        reloadSections([0])
    }
    
    func append(keyword: LostItemKeyword) {
        keywords.append(keyword)
        reloadSections([0])
    }
    
    func remove(id: Int) {
        if let row = keywords.firstIndex(where: { $0.id == id }) {
            keywords.remove(at: row)
            reloadSections([0])
        }
    }
    
    func remove(keyword: String) {
        if let row = keywords.firstIndex(where: { $0.keyword == keyword }) {
            keywords.remove(at: row)
            reloadSections([0])
        }
    }
}

extension LostItemKeywordLeftAlignedCollectionView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        shouldSelectItemAt indexPath: IndexPath
    ) -> Bool {
        let keyword = keywords[indexPath.row]
        didTapItemPublisher.send(keyword)
        return false
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let font = UIFont.appFont(.pretendardMedium, size: 14)
        let inset = 16 * 2
        let padding = 2
        let imageWidth = 18
        let keyword = keywords[indexPath.row].keyword
        var width = Int((keyword as NSString).size(withAttributes: [.font : font]).width)
        width = width + inset + padding + imageWidth
        return CGSize(width: width, height: 34)
    }
}

extension LostItemKeywordLeftAlignedCollectionView: UICollectionViewDataSource {
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return keywords.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LostItemKeywordLeftAlignedCollectionViewCell.identifier, for: indexPath) as? LostItemKeywordLeftAlignedCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(keyword: keywords[indexPath.row].keyword, action: action)
        return cell
    }
}

extension LostItemKeywordLeftAlignedCollectionView {
    
    private func commonInit() {
        delegate = self
        dataSource = self
        register(LostItemKeywordLeftAlignedCollectionViewCell.self, forCellWithReuseIdentifier: LostItemKeywordLeftAlignedCollectionViewCell.identifier)
    }
}
