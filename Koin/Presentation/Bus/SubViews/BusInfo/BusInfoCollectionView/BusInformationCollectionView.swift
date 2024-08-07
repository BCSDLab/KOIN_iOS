//
//  BusInformationCollectionView.swift
//  koin
//
//  Created by JOOMINKYUNG on 7/24/24.
//

import UIKit

final class BusInformationCollectionView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegate {
    // MARK: - Properties
    private var busInformationList: [BusCardInformation] = []
    
    // MARK: - Initialization
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        register(BusInformationCollectionViewCell.self, forCellWithReuseIdentifier: BusInformationCollectionViewCell.identifier)
        dataSource = self
    }
    
    func setBusInformationList(_ busInformationList: [BusCardInformation]) {
        self.busInformationList = busInformationList
        self.reloadData()
    }
}

extension BusInformationCollectionView {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return busInformationList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BusInformationCollectionViewCell.identifier, for: indexPath) as? BusInformationCollectionViewCell
        else {
            return UICollectionViewCell()
        }
        let viewColors: [UIColor] = [UIColor.appColor(.bus1),UIColor.appColor(.bus2), UIColor.appColor(.bus3)]
        cell.setUpViewColor(viewColor: viewColors[indexPath.item])
        cell.configure(busInfoModel: busInformationList[indexPath.item])
        return cell
    }
    
}
