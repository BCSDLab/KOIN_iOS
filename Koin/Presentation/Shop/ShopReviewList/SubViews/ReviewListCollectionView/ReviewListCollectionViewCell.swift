//
//  ReviewListCollectionViewCell.swift
//  koin
//
//  Created by 김나훈 on 7/9/24.
//

import Combine
import UIKit
import SnapKit
import Then

final class ReviewListCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Publishers
    
    let modifyButtonPublisher = PassthroughSubject<Void, Never>()
    let deleteButtonPublisher = PassthroughSubject<Void, Never>()
    let reportButtonPublisher = PassthroughSubject<Void, Never>()
    let imageTapPublisher = PassthroughSubject<([String], IndexPath), Never>()
    
    // MARK: - Properties
    
    var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    
    private let myReviewImageView = UIImageView().then {
        $0.image = UIImage.appImage(asset: .myReview)
    }
    
    private let writerLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardMedium, size: 16)
        $0.textColor = UIColor.appColor(.neutral800)
    }
    
    private let modifyButton = UIButton().then {
        var config = UIButton.Configuration.filled()
        config.baseForegroundColor = UIColor.appColor(.neutral500)
        config.baseBackgroundColor = UIColor.appColor(.neutral200)
        config.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12)
        config.cornerStyle = .capsule
        
        var titleAttributed = AttributedString("수정")
        titleAttributed.font = UIFont.appFont(.pretendardSemiBold, size: 12)
        config.attributedTitle = titleAttributed
        
        $0.configuration = config
        $0.isHidden = true
    }

    private let deleteButton = UIButton().then {
        var config = UIButton.Configuration.filled()
        config.baseForegroundColor = UIColor.appColor(.neutral500)
        config.baseBackgroundColor = UIColor.appColor(.neutral200)
        config.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12)
        config.cornerStyle = .capsule
        
        var titleAttributed = AttributedString("삭제")
        titleAttributed.font = UIFont.appFont(.pretendardSemiBold, size: 12)
        config.attributedTitle = titleAttributed
        
        $0.configuration = config
        $0.isHidden = true
    }
    
    private let reportButton = UIButton().then {
        $0.setTitle("신고하기", for: .normal)
        $0.setTitleColor(UIColor.appColor(.neutral500), for: .normal)
        $0.titleLabel?.font = UIFont.appFont(.pretendardRegular, size: 14)
        $0.isHidden = true
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
    
    private let reportedReviewLabel = UILabel().then {
        $0.setImageText(image: UIImage.appImage(asset: .blind)?.withTintColor(UIColor.appColor(.neutral500)), text: "신고에 의해 숨김 처리 되었습니다.", font: UIFont.appFont(.pretendardMedium, size: 14), textColor: UIColor.appColor(.neutral500), imageSize: CGSize(width: 24, height: 24))
    }
    
    private let reviewImageCollectionView: ReviewImageCollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 8
        flowLayout.scrollDirection = .horizontal
        flowLayout.itemSize = .init(width: 148, height: 148)
        return ReviewImageCollectionView(frame: .zero, collectionViewLayout: flowLayout)
    }()
    
    private let orderedMenuNameContainerView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 10
        $0.alignment = .leading
    }
    
    private let firstRowOrderedMenuNameStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 10
        $0.alignment = .leading
    }
    
    private let secondRowOrderedMenuNameStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 10
        $0.alignment = .leading
    }
    
    // MARK: - Initialize
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        setAddTarget()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        resetCancellables()
        resetConstraints()
        resetStackView()
        resetVisibility()
    }
        
    func configure(review: Review) {
        bind()
        configureContent(review: review)
        configureAppearance(review: review)
        updateLayout(review: review)
    }
}

extension ReviewListCollectionViewCell {
    
    private func setAddTarget() {
        modifyButton.addTarget(self, action: #selector(modifyButtonTapped), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        reportButton.addTarget(self, action: #selector(reportButtonTapped), for: .touchUpInside)
    }
    
    private func bind() {
        reviewImageCollectionView.imageTapPublisher
            .sink { [weak self] (imageUrls, indexPath) in
                self?.imageTapPublisher.send((imageUrls, indexPath))
            }
            .store(in: &cancellables)
    }
    
    private func resetCancellables() {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }
    
    private func resetConstraints() {
        myReviewImageView.snp.removeConstraints()
        writerLabel.snp.removeConstraints()
        reportedReviewLabel.snp.removeConstraints()
        orderedMenuNameContainerView.snp.removeConstraints()
    }
    
    private func resetStackView() {
        firstRowOrderedMenuNameStackView.arrangedSubviews.forEach { view in
            firstRowOrderedMenuNameStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        secondRowOrderedMenuNameStackView.arrangedSubviews.forEach { view in
            secondRowOrderedMenuNameStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
    }
    
    private func resetVisibility() {
        myReviewImageView.isHidden = false
        writerLabel.isHidden = false
        scoreView.isHidden = false
        writtenDayLabel.isHidden = false
        reviewTextLabel.isHidden = false
        reportedReviewLabel.isHidden = true
        orderedMenuNameContainerView.isHidden = false
        reviewImageCollectionView.isHidden = false
        
        modifyButton.isHidden = true
        deleteButton.isHidden = true
        reportButton.isHidden = true
    }
}

// MARK: - Configuration
extension ReviewListCollectionViewCell {
    
    private func configureContent(review: Review) {
        writerLabel.text = review.nickName
        writtenDayLabel.text = formatWrittenDay(createdAt: review.createdAt, isModified: review.isModified)
        reviewTextLabel.text = review.content
        scoreView.rating = Double(review.rating)
        reviewImageCollectionView.setReviewImageList(review.imageUrls)
        setupOrderedMenuNames(list: review.menuNames)
    }
    
    private func configureAppearance(review: Review) {
        myReviewImageView.isHidden = !review.isMine
        
        if review.isMine {
            modifyButton.isHidden = false
            deleteButton.isHidden = false
            reportButton.isHidden = true
        } else {
            modifyButton.isHidden = true
            deleteButton.isHidden = true
            reportButton.isHidden = false
        }
        
        if review.isReported {
            myReviewImageView.isHidden = true
            writerLabel.isHidden = true
            modifyButton.isHidden = true
            deleteButton.isHidden = true
            reportButton.isHidden = true
            scoreView.isHidden = true
            writtenDayLabel.isHidden = true
            reviewTextLabel.isHidden = true
            reviewImageCollectionView.isHidden = true
            orderedMenuNameContainerView.isHidden = true
            reportedReviewLabel.isHidden = false
        } else {
            writerLabel.isHidden = false
            scoreView.isHidden = false
            writtenDayLabel.isHidden = false
            reviewTextLabel.isHidden = false
            reportedReviewLabel.isHidden = true
            
            let shouldHideImages = review.imageUrls.isEmpty
            reviewImageCollectionView.isHidden = shouldHideImages
        }
    }
    
    private func updateLayout(review: Review) {
        if review.isReported {
            updateReportedReviewLayout()
        } else {
            updateMyReviewImageViewLayout(isMine: review.isMine)
            updateOrderedMenuNameContainerLayout(
                shouldHideImages: review.imageUrls.isEmpty
            )
        }
    }
    
    private func formatWrittenDay(createdAt: String, isModified: Bool) -> String {
        let formattedDate = createdAt.replacingOccurrences(of: "-", with: ".")
        return isModified ? "\(formattedDate) (수정됨)" : formattedDate
    }
    
    private func setupOrderedMenuNames(list: [String]) {
        let firstRowCount = min(4, list.count)
        
        for i in 0..<firstRowCount {
            let label = createMenuNameLabel(text: list[i])
            firstRowOrderedMenuNameStackView.addArrangedSubview(label)
        }
        
        if list.count > 4 {
            for i in 4..<min(5, list.count) {
                let label = createMenuNameLabel(text: list[i])
                secondRowOrderedMenuNameStackView.addArrangedSubview(label)
            }
            secondRowOrderedMenuNameStackView.isHidden = false
        } else {
            secondRowOrderedMenuNameStackView.isHidden = true
        }
    }
    
    private func createMenuNameLabel(text: String) -> UILabel {
        let label = InsetLabel(top: 3, left: 10, bottom: 3, right: 10)
        label.text = text
        label.font = UIFont.appFont(.pretendardRegular, size: 12)
        label.textColor = UIColor.appColor(.new300)
        label.layer.cornerRadius = 5
        label.layer.borderWidth = 1.0
        label.layer.borderColor = UIColor.appColor(.new300).cgColor
        label.layer.masksToBounds = true
        label.textAlignment = .center
        return label
    }
}

// MARK: - Layout Updates
extension ReviewListCollectionViewCell {
    
    private func updateReportedReviewLayout() {
        reportedReviewLabel.snp.remakeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(24)
        }
    }
    
    private func updateMyReviewImageViewLayout(isMine: Bool) {
        if isMine {
            myReviewImageView.snp.remakeConstraints {
                $0.top.equalToSuperview()
                $0.leading.equalToSuperview().offset(24)
                $0.width.equalTo(97)
                $0.height.equalTo(25)
            }
            
            writerLabel.snp.remakeConstraints {
                $0.top.equalTo(myReviewImageView.snp.bottom).offset(6.5)
                $0.leading.equalToSuperview().offset(24)
            }
        } else {
            myReviewImageView.snp.removeConstraints()
            
            writerLabel.snp.remakeConstraints {
                $0.top.equalToSuperview()
                $0.leading.equalToSuperview().offset(24)
            }
        }
    }
    
    private func updateOrderedMenuNameContainerLayout(shouldHideImages: Bool) {
        let topAnchor = shouldHideImages
            ? reviewTextLabel.snp.bottom
            : reviewImageCollectionView.snp.bottom
        
        orderedMenuNameContainerView.snp.remakeConstraints {
            $0.top.equalTo(topAnchor).offset(10)
            $0.horizontalEdges.equalToSuperview().inset(24)
            $0.bottom.equalToSuperview()
        }
    }
}

// MARK: - @objc
extension ReviewListCollectionViewCell {
    
    @objc private func modifyButtonTapped() {
        modifyButtonPublisher.send(())
    }
    
    @objc private func deleteButtonTapped() {
        deleteButtonPublisher.send(())
    }
    
    @objc private func reportButtonTapped() {
        reportButtonPublisher.send(())
    }
}

// MARK: - UI Function
extension ReviewListCollectionViewCell {
    
    private func setupLayout() {
        [myReviewImageView, writerLabel, modifyButton, deleteButton, reportButton, scoreView, writtenDayLabel, reviewTextLabel, reportedReviewLabel, reviewImageCollectionView, orderedMenuNameContainerView].forEach {
            contentView.addSubview($0)
        }
        
        [firstRowOrderedMenuNameStackView, secondRowOrderedMenuNameStackView].forEach {
            orderedMenuNameContainerView.addArrangedSubview($0)
        }
    }
    
    private func setupConstraints() {
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }
        
        writerLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(24)
        }
        
        reportButton.snp.makeConstraints {
            $0.centerY.equalTo(writerLabel)
            $0.trailing.equalToSuperview().offset(-24)
        }
        
        deleteButton.snp.makeConstraints {
            $0.centerY.equalTo(writerLabel)
            $0.height.equalTo(31)
            $0.trailing.equalToSuperview().offset(-24)
        }
        
        modifyButton.snp.makeConstraints {
            $0.centerY.equalTo(writerLabel)
            $0.height.equalTo(31)
            $0.trailing.equalTo(deleteButton.snp.leading).offset(-8)
        }
        
        scoreView.snp.makeConstraints {
            $0.top.equalTo(writerLabel.snp.bottom).offset(6.5)
            $0.leading.equalToSuperview().offset(24)
            $0.width.equalTo(88)
            $0.height.equalTo(16)
        }
        
        writtenDayLabel.snp.makeConstraints {
            $0.centerY.equalTo(scoreView)
            $0.leading.equalTo(scoreView.snp.trailing).offset(12)
        }
        
        reportedReviewLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(24)
        }
        
        reviewTextLabel.snp.makeConstraints {
            $0.top.equalTo(scoreView.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
        }
        
        reviewImageCollectionView.snp.makeConstraints {
            $0.top.equalTo(reviewTextLabel.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview()
            $0.height.equalTo(148)
        }
        
        orderedMenuNameContainerView.snp.makeConstraints {
            $0.top.equalTo(reviewImageCollectionView.snp.bottom).offset(10)
            $0.horizontalEdges.equalToSuperview().inset(24)
            $0.bottom.equalToSuperview()
        }
    }
    
    private func configureView() {
        setupLayout()
        setupConstraints()
        backgroundColor = UIColor.appColor(.newBackground)
    }
}
