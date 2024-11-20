//
//  AddDirectFooterView.swift
//  koin
//
//  Created by 김나훈 on 11/20/24.
//

import Combine
import UIKit

final class AddDirectFooterView: UICollectionReusableView {
    
    static let identifier = "AddDirectFooterView"
    
    private let footerView = UIView().then {
        $0.layer.borderColor = UIColor.appColor(.neutral300).cgColor
        $0.layer.borderWidth = 1.0
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 5
    }
    
    private let addOptionLabel = UILabel().then {
        $0.text = "시간 및 장소 추가"
        $0.font = UIFont.appFont(.pretendardBold, size: 12)
        $0.textColor = UIColor.appColor(.primary500)
    }
    
    private let addImageView = UIImageView().then {
        $0.image = UIImage.appImage(asset: .add)
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
      
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension AddDirectFooterView {
   
}
extension AddDirectFooterView {
    private func setupViews() {
        self.backgroundColor = .systemBackground
     
        [addOptionLabel].forEach {
            self.addSubview($0)
        }
        addOptionLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(37)
        }
    }
}
