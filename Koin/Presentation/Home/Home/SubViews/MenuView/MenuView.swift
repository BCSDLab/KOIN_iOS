//
//  MenuView.swift
//  Koin
//
//  Created by 김나훈 on 2/2/24.
//

import Combine
import UIKit

final class MenuView: UIView {

    private let timeLabel = UILabel().then {
        $0.tintColor = UIColor.black
        $0.font = UIFont.appFont(.pretendardMedium, size: 16)
    }
    
    private let soldOutLabel = UILabel().then {
        $0.textAlignment = .center
        $0.layer.cornerRadius = 4
        $0.clipsToBounds = true
        $0.isHidden = true
        $0.text = "품절"
        $0.font = UIFont.appFont(.pretendardMedium, size: 12)
        $0.backgroundColor = UIColor.appColor(.warning200)
        $0.textColor = UIColor.appColor(.warning600)
    }
    
    private let substitutionLabel = UILabel().then {
        $0.textAlignment = .center
        $0.layer.cornerRadius = 4
        $0.clipsToBounds = true
        $0.isHidden = true
        $0.text = "변경됨"
        $0.font = UIFont.appFont(.pretendardMedium, size: 12)
        $0.backgroundColor = UIColor.appColor(.neutral200)
        $0.textColor = UIColor.appColor(.neutral600)
    }
    
    private let separateView = UIView().then {
        $0.backgroundColor = UIColor.appColor(.neutral200)
    }
    
    private let menuCollectionView: MenuCollectionView = {
        let menuCollectionViewFlowLayout = UICollectionViewFlowLayout()
        let screenWidth = (UIScreen.main.bounds.width - 100) / 2
        menuCollectionViewFlowLayout.itemSize = CGSize(width: screenWidth, height: 15.3)
        menuCollectionViewFlowLayout.minimumLineSpacing = 2.7
        let menuCollectionView = MenuCollectionView(frame: .zero, collectionViewLayout: menuCollectionViewFlowLayout)
        menuCollectionView.isScrollEnabled = false
        return menuCollectionView
    }()
    
    private let warningImageView = UIImageView().then {
        $0.image = UIImage.appImage(asset: .warning)
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private let warningLabel = UILabel().then {
        $0.text = "식단이 표시되지 않아\n표시할 수 없습니다."
        $0.font = UIFont.appFont(.pretendardRegular, size: 12)
        $0.textColor = UIColor.appColor(.neutral800)
        $0.numberOfLines = 0
        $0.textAlignment = .center
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureView()
    }
    
    func updateDining(_ item: DiningItem?, _ type: DiningType) {
      
        disappearView(hideCollectionView: item == nil)
        timeLabel.text = type.name
        menuCollectionView.updateDining(item?.menu ?? [])
        
        guard let item = item else { return }
        soldOutLabel.isHidden = item.soldoutAt == nil
        substitutionLabel.isHidden = item.changedAt == nil
        
        if item.soldoutAt != nil { substitutionLabel.isHidden = true }
    }
    
    private func disappearView(hideCollectionView: Bool) {
        menuCollectionView.isHidden = hideCollectionView
        warningImageView.isHidden = !hideCollectionView
        separateView.isHidden = hideCollectionView
        warningLabel.isHidden = !hideCollectionView
    }
    
}

extension MenuView {
    private func setUpLayOuts() {
        [timeLabel, substitutionLabel,soldOutLabel, menuCollectionView, warningImageView, warningLabel, separateView].forEach {
            self.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        timeLabel.snp.makeConstraints { make in
            make.top.equalTo(self.snp.top).offset(17.5)
            make.leading.equalTo(self.snp.leading).offset(16)
            make.height.equalTo(19)
        }
        separateView.snp.makeConstraints { make in
            make.top.equalTo(timeLabel.snp.bottom).offset(17.5)
            make.leading.equalTo(self.snp.leading)
            make.trailing.equalTo(self.snp.trailing)
            make.height.equalTo(1)
        }
        menuCollectionView.snp.makeConstraints { make in
            make.top.equalTo(separateView.snp.bottom).offset(16)
            make.leading.equalTo(self.snp.leading).offset(20)
            make.trailing.equalTo(self.snp.trailing).offset(-20)
            make.bottom.equalTo(self.snp.bottom)
        }
        
        soldOutLabel.snp.makeConstraints { make in
            make.top.equalTo(timeLabel.snp.top)
            make.trailing.equalTo(self.snp.trailing).offset(-16)
            make.width.equalTo(37)
            make.height.equalTo(22)
        }
        substitutionLabel.snp.makeConstraints { make in
            make.top.equalTo(soldOutLabel.snp.top)
            make.trailing.equalTo(soldOutLabel.snp.trailing)
            make.width.equalTo(48)
            make.height.equalTo(soldOutLabel.snp.height)
        }
            
        warningImageView.snp.makeConstraints { make in
            make.centerY.equalTo(self.snp.centerY)
            make.centerX.equalTo(self.snp.centerX)
            make.height.equalTo(52)
            make.width.equalTo(52)
        }
        warningLabel.snp.makeConstraints { make in
            make.top.equalTo(warningImageView.snp.bottom).offset(8.28)
            make.centerX.equalTo(self.snp.centerX)
        }
    }
    
    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
    }
}
