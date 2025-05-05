//
//  DiningCollecitonFooterView.swift
//  koin
//
//  Created by 김나훈 on 5/12/24.
//

import UIKit

final class DiningCollectionFooterView: UICollectionReusableView {
    static let identifier = "DiningCollectionFooterView"

    private let noticeLabel = UILabel().then {
        $0.text = "식단 정보는 운영 상황 따라 변동될 수 있습니다."
        $0.numberOfLines = 2
        $0.textColor = UIColor.appColor(.neutral400)
        $0.font = UIFont.appFont(.pretendardMedium, size: 13)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(noticeLabel)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        self.backgroundColor = UIColor.clear
        noticeLabel.snp.makeConstraints { make in
            make.top.equalTo(self.snp.top).offset(16)
            make.leading.equalTo(self.snp.leading).offset(24)
            make.trailing.equalTo(self.snp.trailing).offset(-24)
        }
    }

}
