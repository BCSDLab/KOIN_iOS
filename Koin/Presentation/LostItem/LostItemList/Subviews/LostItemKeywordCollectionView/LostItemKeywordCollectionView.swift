//
//  LostItemKeywordCollectionView.swift
//  koin
//
//  Created by 홍기정 on 5/11/26.
//

import UIKit
import Combine

/// section 0 : 설정 버튼
/// section 1 : 모두보기 + 키워드
/// section 2 : 새 키워드 추가 (section1에 넣을 키워드가 없을 경우)
final class LostItemKeywordCollectionView: UICollectionView {
    
    // MARK: - Publisher
    let didTapSettingPublisher = PassthroughSubject<Void, Never>()
    let didTapAllPublisher = PassthroughSubject<Void, Never>()
    let didTapKeywordPublisher = PassthroughSubject<String, Never>()
    
    // MARK: - Properties
    private let all = "모두보기"
    private let add = "새 키워드 추가"
    private let allIndexPath = IndexPath(row: 0, section: 1)
    private var keywords: [String] = []

    // MARK: - Init
    init() {
        let layout = UICollectionViewFlowLayout().then {
            $0.minimumInteritemSpacing = 8
            $0.scrollDirection = .horizontal
            $0.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        }
        super.init(frame: .zero, collectionViewLayout: layout)
        showsHorizontalScrollIndicator = false
        commonInit()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    func configure(keywords: [String]) {
        self.keywords = [all] + keywords
        reloadData()
        selectItem(at: allIndexPath, animated: false, scrollPosition: .right)
    }
}

extension LostItemKeywordCollectionView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        switch indexPath.section {
        case 1:
            let keyword = keywords[indexPath.row]
            if keyword == all {
                didTapAllPublisher.send()
            } else {
                didTapKeywordPublisher.send(keyword)
            }
        default:
            break
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        shouldSelectItemAt indexPath: IndexPath
    ) -> Bool {
        switch indexPath.section {
        case 0, 2:
            didTapSettingPublisher.send()
            return false
        case 1:
            return true
        default:
            return false
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let height = 32
        
        switch indexPath.section {
        case 0:
            let width = 32
            return CGSize(width: width, height: height)
        case 1:
            let font = UIFont.appFont(.pretendardSemiBold, size: 14)
            let width = Int((keywords[indexPath.row] as NSString).size(withAttributes: [.font : font]).width + 32)
            return CGSize(width: width, height: height)
        case 2:
            let font = UIFont.appFont(.pretendardMedium, size: 14)
            let width = Int((add as NSString).size(withAttributes: [.font : font]).width + 32)
            return CGSize(width: width, height: height)
        default:
            return .zero
        }
    }
}

extension LostItemKeywordCollectionView: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return keywords.filter { $0 != all }.isEmpty ? 3 : 2
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return keywords.count
        case 2:
            return keywords.filter { $0 != all }.isEmpty ? 1 : 0
        default:
            return 0
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LostItemKeywordCollectionViewSettingCell.identifier, for: indexPath) as? LostItemKeywordCollectionViewSettingCell else {
                return UICollectionViewCell()
            }
            return cell
        case 1:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LostItemKeywordCollectionViewKeywordCell.identifier, for: indexPath) as? LostItemKeywordCollectionViewKeywordCell else {
                return UICollectionViewCell()
            }
            var keyword = keywords[indexPath.row]
            if keyword != all {
                keyword = "#\(keyword)"
            }
            cell.configure(keyword: keyword)
            return cell
        case 2:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LostItemKeywordCollectionViewAllCell.identifier, for: indexPath) as? LostItemKeywordCollectionViewAllCell else {
                return UICollectionViewCell()
            }
            return cell
        default:
            return UICollectionViewCell()
        }
    }
}

extension LostItemKeywordCollectionView {
    
    private func commonInit() {
        delegate = self
        dataSource = self
        register(LostItemKeywordCollectionViewSettingCell.self, forCellWithReuseIdentifier: LostItemKeywordCollectionViewSettingCell.identifier)
        register(LostItemKeywordCollectionViewKeywordCell.self, forCellWithReuseIdentifier: LostItemKeywordCollectionViewKeywordCell.identifier)
        register(LostItemKeywordCollectionViewAllCell.self, forCellWithReuseIdentifier: LostItemKeywordCollectionViewAllCell.identifier)
    }
}
