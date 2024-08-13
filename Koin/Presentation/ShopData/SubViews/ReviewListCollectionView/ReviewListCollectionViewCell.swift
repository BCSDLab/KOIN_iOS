//
//  ReviewListCollectionViewCell.swift
//  koin
//
//  Created by 김나훈 on 7/9/24.
//

import Combine
import DropDown
import Then
import UIKit

final class ReviewListCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    let modifyButtonPublisher = PassthroughSubject<Void, Never>()
    let deleteButtonPublisher = PassthroughSubject<Void, Never>()
    let reportButtonPublisher = PassthroughSubject<Void, Never>()
    private let dropDown = DropDown()
    var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    
    private let myReviewImageView = UIImageView().then {
        $0.image = UIImage.appImage(asset: .myReview)
    }
    
    private let writerLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardMedium, size: 16)
        $0.textColor = UIColor.appColor(.neutral800)
    }
    
    private let optionButton = UIButton().then {
        $0.setImage(UIImage.appImage(asset: .option), for: .normal)
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
        myReviewImageView.snp.removeConstraints()
        writerLabel.snp.removeConstraints()
        //          reviewImageCollectionView.snp.removeConstraints()
        orderedMenuNameStackView.snp.removeConstraints()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        configureDropDown()
        optionButton.addTarget(self, action: #selector(optionButtonTapped), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func configure(review: Review, backgroundColor: UIColor) {
        writerLabel.text = review.nickName
        writtenDayLabel.text = review.createdAt
        reviewTextLabel.text = review.content
        scoreView.rating = Double(review.rating)
        reviewImageCollectionView.setReviewImageList(review.imageUrls)
        setUpOrderedMenuNames(list: review.menuNames)
        myReviewImageView.isHidden = !review.isMine
        reviewImageCollectionView.isHidden = review.imageUrls.isEmpty
        reviewImageCollectionView.backgroundColor = backgroundColor
        self.contentView.backgroundColor = backgroundColor
        self.backgroundColor = backgroundColor
        optionButton.isSelected = review.isMine
        self.backgroundColor = backgroundColor
        showMyReviewImageView(review.isMine)
        disappearImageCollectionView(review.imageUrls.isEmpty)
    }
    
    private func showMyReviewImageView(_ isMine: Bool) {
        if isMine {
            myReviewImageView.snp.remakeConstraints { make in
                make.top.equalTo(self.snp.top).offset(12)
                make.leading.equalTo(self.snp.leading).offset(24)
                make.width.equalTo(97)
                make.height.equalTo(25)
            }
            writerLabel.snp.remakeConstraints { make in
                make.top.equalTo(myReviewImageView.snp.bottom).offset(5)
                make.leading.equalTo(self.snp.leading).offset(24)
            }
        } else {
            myReviewImageView.snp.removeConstraints()
            writerLabel.snp.makeConstraints {
                $0.top.equalTo(self.snp.top).offset(12)
                $0.leading.equalTo(self.snp.leading).offset(24)
            }
        }
    }
    
    // TODO: 텍스트가 비었따면ㅇ ㅓ떻게되는거지 ?
    private func disappearImageCollectionView(_ isEmpty: Bool) {
        orderedMenuNameStackView.snp.remakeConstraints { make in
            make.top.equalTo(isEmpty ? reviewTextLabel.snp.bottom : reviewImageCollectionView.snp.bottom).offset(10)
            make.leading.equalTo(self.snp.leading).offset(24)
            make.height.equalTo(25)
            make.bottom.equalTo(self.snp.bottom)
        }
    }

    @objc private func optionButtonTapped() {
        
        let items: [(text: String, image: UIImage?)]
        
        if optionButton.isSelected {
            items = [("수정하기", UIImage.appImage(asset: .heartFill)),
                     ("삭제하기", UIImage.appImage(asset: .heart))]
        } else {
            items = [("신고하기", UIImage.appImage(asset: .koinLogo))]
        }
        
        dropDown.dataSource = items.map { $0.text }
        
        dropDown.customCellConfiguration = { (index: Int, item: String, cell: DropDownCell) in
            if let customCell = cell as? ImageDropDownCell {
                let itemData = items[index]
                customCell.configure(text: itemData.text, image: itemData.image)
            }
        }
        
        dropDown.show()
    }
    
    
    private func configureDropDown() {
        dropDown.anchorView = optionButton
        dropDown.direction = .any
        dropDown.width = 109
        
        dropDown.selectionAction = { [weak self] (index: Int, _) in
            
            self?.handleDropDownSelection(at: index)
        }
    }
    private func handleDropDownSelection(at index: Int) {
        
        if optionButton.isSelected {
            switch index {
            case 0: modifyButtonPublisher.send(())
            default: deleteButtonPublisher.send(())
            }
        } else {
            reportButtonPublisher.send(())
        }
    }
    
    private func setUpOrderedMenuNames(list: [String]) {
        for menuName in list {
            let label = InsetLabel(top: 0, left: 10, bottom: 0, right: 10)
               label.text = menuName
               label.font = UIFont.appFont(.pretendardRegular, size: 12)
               label.textColor = UIColor.appColor(.primary300)
               label.layer.cornerRadius = 5
               label.layer.borderWidth = 1.0
               label.layer.borderColor = UIColor.appColor(.primary300).cgColor
               label.layer.masksToBounds = true
               label.textAlignment = .center
               orderedMenuNameStackView.addArrangedSubview(label)
           }
    }
}

extension ReviewListCollectionViewCell {
    private func setUpLayouts() {
        [myReviewImageView, writerLabel, optionButton, scoreView, writtenDayLabel, reviewTextLabel, reviewImageCollectionView, orderedMenuNameStackView].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        writerLabel.snp.makeConstraints {
            $0.top.equalTo(self.snp.top).offset(12)
            $0.leading.equalTo(self.snp.leading).offset(24)
        }
        optionButton.snp.makeConstraints {
            $0.centerY.equalTo(writerLabel.snp.centerY)
            $0.trailing.equalTo(self.snp.trailing).offset(-24)
            $0.width.equalTo(24)
            $0.height.equalTo(24)
        }
        scoreView.snp.makeConstraints {
            $0.top.equalTo(writerLabel.snp.bottom).offset(5.5)
            $0.leading.equalTo(self.snp.leading).offset(24)
            $0.width.equalTo(88)
            $0.height.equalTo(16)
        }
        writtenDayLabel.snp.makeConstraints {
            $0.top.equalTo(scoreView.snp.top)
            $0.leading.equalTo(scoreView.snp.trailing).offset(12)
        }
        reviewTextLabel.snp.makeConstraints {
            $0.top.equalTo(scoreView.snp.bottom).offset(10)
            $0.leading.equalTo(self.snp.leading).offset(24)
            $0.trailing.equalTo(self.snp.trailing).offset(-24)
        }
        reviewImageCollectionView.snp.makeConstraints {
            $0.top.equalTo(reviewTextLabel.snp.bottom).offset(10)
            $0.leading.equalTo(self.snp.leading).offset(24)
            $0.trailing.equalTo(self.snp.trailing)
            $0.height.equalTo(148)
        }
        orderedMenuNameStackView.snp.makeConstraints {
            $0.top.equalTo(reviewImageCollectionView.snp.bottom).offset(10)
            $0.leading.equalTo(self.snp.leading).offset(24)
            // $0.trailing.equalTo(self.snp.trailing)
            $0.height.equalTo(25)
            $0.bottom.equalTo(self.snp.bottom)
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
    }
    
}
