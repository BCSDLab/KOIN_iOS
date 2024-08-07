//
//  LandOptionView.swift
//  koin
//
//  Created by 김나훈 on 3/17/24.
//

import UIKit


final class LandOptionView: UIView {
    
    // MARK: - UI Components
    
    private let optionGuideLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "원룸옵션"
        label.font = UIFont.appFont(.pretendardMedium, size: 14)
        return label
    }()
   
    private let optionCollectionView: LandOptionCollectionView = {

        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        
        flowLayout.itemSize = CGSize(width: 50, height: 50)
      //  flowLayout.minimumLineSpacing = ( UIScreen.main.bounds.width - (240)) / 4
        flowLayout.minimumInteritemSpacing = ( UIScreen.main.bounds.width - (240)) / 6
  
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20) // 섹션 패딩 설정

        let collectionView = LandOptionCollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.isScrollEnabled = false
        return collectionView
    }()


    // MARK: Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    convenience init(frame: CGRect, text: String) {
        self.init(frame: frame)
    }
    
    func configure(_ list: [Bool]) {
        optionCollectionView.setOptionExists(list)
    }
}

// MARK: UI Settings

extension LandOptionView {
    private func setUpLayOuts() {
        [optionGuideLabel, optionCollectionView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        optionGuideLabel.snp.makeConstraints { make in
            make.top.equalTo(self.snp.top).offset(15)
            make.width.equalTo(self.snp.width)
        }
        optionCollectionView.snp.makeConstraints { make in
            make.top.equalTo(optionGuideLabel.snp.bottom).offset(15)
            make.leading.equalTo(self.snp.leading)
            make.trailing.equalTo(self.snp.trailing)
            make.bottom.equalTo(self.snp.bottom)
        }
    }
    
    private func setUpBorder() {
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.appColor(.neutral500).cgColor
    }
    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
        setUpBorder()
    }
}
