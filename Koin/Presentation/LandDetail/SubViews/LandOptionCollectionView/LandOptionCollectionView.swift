//
//  LandOptionCollectionView.swift
//  koin
//
//  Created by 김나훈 on 3/17/24.
//


import UIKit

final class LandOptionCollectionView: UICollectionView, UICollectionViewDataSource {
    
    // ???: 두개를 같이 가지고있는 타입을 만들어야할까? 투머치인것 같아서 그냥 따로 가지고 있다..
    private let optionImages: [ImageAsset] = [.option1, .option2, .option3, .option4, .option5, .option6, .option7, .option8, .option9, .option10, .option11, .option12, .option13, .option14, .option15, .option16]
    private let descriptiontext: [String] = ["에어컨", "냉장고", "옷장", "TV", "전자렌지", "가스렌지", "인덕션", "정수기", "세탁기", "침대", "책상", "신발장", "도어락", "비데", "베란다", "엘리베이터"]
    private var isOptionExists: [Bool] = [false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        register(LandOptionCollectionViewCell.self, forCellWithReuseIdentifier: LandOptionCollectionViewCell.identifier)
        dataSource = self
    }
    
    func setOptionExists(_ exists: [Bool]) {
        isOptionExists = exists
        reloadData()
    }
    
}

extension LandOptionCollectionView {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return optionImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LandOptionCollectionViewCell.identifier, for: indexPath) as? LandOptionCollectionViewCell else {
            return UICollectionViewCell()
        }
        let imageItem = optionImages[indexPath.row]
        let description = descriptiontext[indexPath.row]
        let exist = isOptionExists[indexPath.row]
        cell.configure(image: imageItem, text: description, exist: exist)
        return cell
    }
}
