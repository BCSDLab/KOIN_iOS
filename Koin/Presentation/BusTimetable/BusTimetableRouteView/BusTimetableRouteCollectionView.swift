//
//  BusTimetableRouteCollectionView.swift
//  koin
//
//  Created by JOOMINKYUNG on 11/9/24.
//

import Combine
import UIKit

final class BusTimetableRouteCollectionView: UICollectionView, UICollectionViewDelegate, UICollectionViewDataSource {
    //MARK: - Properties
    private var routeList: [String] = []
    private var selectedList: [Bool] = []
    private var subscriptions: Set<AnyCancellable> = []
    let filterIdxPublisher = PassthroughSubject<(Int, String), Never>()
    
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
        register(BusTimetableRouteCollectionViewCell.self, forCellWithReuseIdentifier: BusTimetableRouteCollectionViewCell.identifier)
        showsHorizontalScrollIndicator = false
        contentInset = .zero
        delegate = self
        dataSource = self
        isScrollEnabled = false
        backgroundColor = .appColor(.neutral100)
    }
    
    func configure(routeList: [String]) {
        self.routeList = routeList
        selectedList.removeAll()
        for _ in routeList {
            selectedList.append(false)
        }
        if !selectedList.isEmpty {
            selectedList[0] = true
        }
        reloadData()
    }
}

extension BusTimetableRouteCollectionView {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return routeList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BusTimetableRouteCollectionViewCell.identifier, for: indexPath) as? BusTimetableRouteCollectionViewCell else { return UICollectionViewCell() }
        cell.configure(isSelected: selectedList[indexPath.row], route: routeList[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        for (index, _) in selectedList.enumerated() {
            if index == indexPath.row {
                selectedList[index] = true
            }
            else {
                selectedList[index] = false
            }
        }
        filterIdxPublisher.send((indexPath.row, routeList[indexPath.row]))
        reloadData()
    }
}

extension BusTimetableRouteCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let label = UILabel()
        label.text = routeList[indexPath.row]
        label.font = .appFont(.pretendardMedium, size: 14)
        let size = label.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: 34))
        return CGSize(width: size.width + 32, height: 34)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

