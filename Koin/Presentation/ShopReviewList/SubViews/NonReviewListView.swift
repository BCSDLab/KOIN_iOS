//
//  NonReviewListView.swift
//  koin
//
//  Created by 이은지 on 10/24/25.
//

import UIKit
import SnapKit

final class NonReviewListView: UIView {
    
    // MARK: - UI Components
    
    private let nonReviewListImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = UIImage.appImage(asset: .nonReview)
    }
    
    private let titleNonReviewListLabel = UILabel().then {
        $0.text = "작성된 리뷰가 없어요"
        $0.font = UIFont.appFont(.pretendardSemiBold, size: 18)
        $0.textColor = UIColor.appColor(.new500)
        $0.textAlignment = .center
    }
    
    private let descriptionNonReviewListLabel = UILabel().then {
        $0.text = "첫 번째 리뷰를 작성해보세요"
        $0.font = UIFont.appFont(.pretendardMedium, size: 14)
        $0.textColor = UIColor.appColor(.neutral600)
        $0.textAlignment = .center
    }
    
    // MARK: - Initialize
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UI Function
extension NonReviewListView {
    private func setUpLayout() {
        [nonReviewListImageView, titleNonReviewListLabel, descriptionNonReviewListLabel].forEach {
            addSubview($0)
        }
    }
    
    private func setupConstraints() {
        nonReviewListImageView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.height.equalTo(83)
        }
        
        titleNonReviewListLabel.snp.makeConstraints {
            $0.top.equalTo(nonReviewListImageView.snp.bottom).offset(12)
            $0.centerX.equalToSuperview()
        }
        
        descriptionNonReviewListLabel.snp.makeConstraints {
            $0.top.equalTo(titleNonReviewListLabel.snp.bottom)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
    
    private func configureView() {
        setUpLayout()
        setupConstraints()
        backgroundColor = .clear
    }
}
