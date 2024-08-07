//
//  ReviewListCollectionViewCell.swift
//  koin
//
//  Created by 김나훈 on 7/9/24.
//

import Then
import UIKit

final class ReviewListCollectionViewCell: UICollectionViewCell {
    
    // MARK: - UI Components
    
    private let writerLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardMedium, size: 16)
        $0.textColor = UIColor.appColor(.neutral800)
    }
    
    private let optionButton = UIButton().then {
        $0.imageView?.image = UIImage.appImage(asset: .arrow)
    }
    
    private let scoreView = ScoreView().then {
        $0.settings.starSize = 16
        $0.settings.starMargin = 2
        $0.settings.fillMode = .precise
        $0.settings.updateOnTouch = false
    }
    
    private let writtenDayLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardRegular, size: 12)
        $0.textColor = UIColor.appColor(.neutral500)
    }
    
    private let reviewTextLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardRegular, size: 14)
        $0.textColor = UIColor.appColor(.neutral800)
        $0.numberOfLines = 0
    }
    
    private let reviewImageCollectionView: ReviewImageCollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 8
        flowLayout.scrollDirection = .horizontal
        flowLayout.itemSize = .init(width: 148, height: 148)
        let collectionView = ReviewImageCollectionView(frame: .zero, collectionViewLayout: flowLayout)
        return collectionView
    }()
    
    private let orderedMenuNameStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 10
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(review: Review) {
        writerLabel.text = review.nickName
        writtenDayLabel.text = review.createdAt
        reviewTextLabel.text = review.content
        scoreView.rating = Double(review.rating)
        reviewImageCollectionView.setReviewImageList(review.imageUrls)
        setUpOrderedMenuNames(list: review.menuNames)
    }
    
    private func setUpOrderedMenuNames(list: [String]) {
        for menuName in list {
            let label = UILabel()
            label.text = " \(menuName) "
            label.font = UIFont.appFont(.pretendardRegular, size: 12)
            label.textColor = UIColor.appColor(.primary300)
            label.layer.cornerRadius = 5
            label.layer.borderWidth = 1.0
            label.layer.borderColor = UIColor.appColor(.primary300).cgColor
            label.layer.masksToBounds = true
            label.textAlignment = .center
            label.sizeToFit()
            orderedMenuNameStackView.addArrangedSubview(label)
        }
    }
}

extension ReviewListCollectionViewCell {
    private func setUpLayouts() {
        [writerLabel, optionButton, scoreView, writtenDayLabel, reviewTextLabel, reviewImageCollectionView, orderedMenuNameStackView].forEach {
            self.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        writerLabel.snp.makeConstraints {
            $0.top.equalTo(self.snp.top)
            $0.leading.equalTo(self.snp.leading)
        }
        optionButton.snp.makeConstraints {
            $0.top.equalTo(self.snp.top)
            $0.trailing.equalTo(self.snp.trailing).offset(-24)
            $0.width.equalTo(24)
            $0.height.equalTo(24)
        }
        scoreView.snp.makeConstraints {
            $0.top.equalTo(writerLabel.snp.bottom).offset(5.5)
            $0.leading.equalTo(self.snp.leading)
            $0.width.equalTo(88)
            $0.height.equalTo(16)
        }
        writtenDayLabel.snp.makeConstraints {
            $0.top.equalTo(scoreView.snp.top)
            $0.leading.equalTo(scoreView.snp.trailing).offset(12)
        }
        reviewTextLabel.snp.makeConstraints {
            $0.top.equalTo(scoreView.snp.bottom).offset(10)
            $0.leading.equalTo(self.snp.leading)
            $0.trailing.equalTo(self.snp.trailing).offset(-24)
        }
        reviewImageCollectionView.snp.makeConstraints {
            $0.top.equalTo(reviewTextLabel.snp.bottom).offset(10)
            $0.leading.equalTo(self.snp.leading)
            $0.trailing.equalTo(self.snp.trailing)
            $0.height.equalTo(148)
        }
        orderedMenuNameStackView.snp.makeConstraints {
            $0.top.equalTo(reviewImageCollectionView.snp.bottom).offset(10)
            $0.leading.equalTo(self.snp.leading)
           // $0.trailing.equalTo(self.snp.trailing)
            $0.height.equalTo(25)
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
    }
    
}
