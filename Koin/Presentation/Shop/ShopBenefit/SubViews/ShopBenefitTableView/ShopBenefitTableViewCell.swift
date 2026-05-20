//
//  ShopBenefitTableViewCell.swift
//  koin
//
//  Created by 홍기정 on 5/19/26.
//

import UIKit
import Combine
import SnapKit
import Then

final class ShopBenefitTableViewCell: UITableViewCell {
    
    private var onCurrentPageChanged: ((Int)->Void)?
    private var onImageTapped: (([String], IndexPath)->Void)?
    
    // MARK: - Properties
    private var isExpanded: Bool = false
    
    private var numberOfImages = 0
    private var shouldShowEmptyView: Bool {
        return numberOfImages == 0
    }
    private var shouldShowPageControl: Bool {
        return 1 < numberOfImages
    }

    var cellSubscription: Set<AnyCancellable> = []
    private var subscription: Set<AnyCancellable> = []

    // MARK: - UI Components
    private let emptyThumbnailImageView = UIImageView(image: .appImage(asset: .bcsdSymbolLogo)) // TODO: Lottie로 바꿔야함
    private let thumbnailImageView = UIImageView()
    
    private let titleLabel = UILabel()
    private let openCloseView = ShopBenefitOpenCloseView()
    private let descriptionLabel = UILabel()
    private let dateLabel = UILabel()
    
    private let emptyThumbnailView = ShopBenefitEmptyThumbnailView()
    private let thumbnailImagesCollectionView = ThumbnailImagesCollectionView()
    private let thumbnailImagesPageControl = ShopBenefitPageControl()
    
    private let separatorView = UIView()
    
    // MARK: - Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureView()
        selectionStyle = .none
        bind()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    func configure(
        onCurrentPageChanged: @escaping (Int)->Void,
        onImageTapped: @escaping ([String], IndexPath)->Void
    ) {
        self.onCurrentPageChanged = onCurrentPageChanged
        self.onImageTapped = onImageTapped
    }
    
    func configure(event: ShopEvent, animated: Bool = false) {
        self.isExpanded = event.isExpanded
        
        // 썸네일
        if let thumbnailImages = event.thumbnailImages,
           let firstImageUrl = thumbnailImages.first {
            numberOfImages = thumbnailImages.count
            thumbnailImageView.loadImage(from: firstImageUrl)
            
            thumbnailImagesCollectionView.configure(thumbnailImages, currentPage: event.currentPage)
            thumbnailImagesPageControl.configure(numberOfPages: thumbnailImages.count)
            thumbnailImagesPageControl.configure(currentPage: event.currentPage ?? 0)
        } else {
            numberOfImages = 0
        }
           
        // title
        titleLabel.text = event.title
        
        // description
        let paragraphStyle = NSMutableParagraphStyle().then {
            $0.minimumLineHeight = 12 * 1.6
            $0.maximumLineHeight = 12 * 1.6
        }
        descriptionLabel.attributedText = NSAttributedString(
            string: event.content,
            attributes: [
                .font : UIFont.appFont(.pretendardMedium, size: 12),
                .foregroundColor : UIColor.appColor(.neutral800),
                .paragraphStyle: paragraphStyle
            ]
        )
        
        // date
        dateLabel.text = "\(event.startDate) - \(event.endDate)"
        
        let updateLayout = { [weak self] in
            guard let self else { return }
            setUpConstraints()
            
            openCloseView.configure(isExpanded: event.isExpanded)
            
            descriptionLabel.numberOfLines = isExpanded ? 0 : 2
            
            emptyThumbnailImageView.alpha = (!isExpanded && shouldShowEmptyView) ? 1 : 0
            thumbnailImageView.alpha = (!isExpanded && !shouldShowEmptyView) ? 1 : 0
            
            thumbnailImagesCollectionView.alpha = (isExpanded && !shouldShowEmptyView) ? 1 : 0
            thumbnailImagesPageControl.alpha = (isExpanded && shouldShowPageControl) ? 1 : 0
            emptyThumbnailView.alpha = (isExpanded && shouldShowEmptyView) ? 1 : 0
            
            contentView.setNeedsLayout()
            contentView.layoutIfNeeded()
        }
        if animated {
            UIView.animate(springDuration: 0.2, animations: updateLayout)
        } else {
            UIView.performWithoutAnimation(updateLayout)
        }
        
        thumbnailImagesCollectionView.scrollTo(currentPage: event.currentPage ?? 0)
    }
    
    // MARK: - PrepareForReuse
    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnailImageView.image = nil
    }
}

extension ShopBenefitTableViewCell {

    private func bind() {
        thumbnailImagesCollectionView.currentPagePublisher.sink { [weak self] currentPage in
            guard let self else { return }
            thumbnailImagesPageControl.configure(currentPage: currentPage)
            onCurrentPageChanged?(currentPage)
        }.store(in: &subscription)
        thumbnailImagesCollectionView.imageTapPublisher.sink { [weak self] (imageUrls, indexPath) in
            self?.onImageTapped?(imageUrls, indexPath)
        }.store(in: &subscription)
    }
}

extension ShopBenefitTableViewCell {
    
    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }
    
    private func setUpStyles() {
        thumbnailImageView.do {
            $0.contentMode = .scaleAspectFill
            $0.clipsToBounds = true
        }
        emptyThumbnailImageView.do {
            $0.contentMode = .scaleAspectFill
        }
        titleLabel.do {
            $0.font = .appFont(.pretendardSemiBold, size: 15)
            $0.textColor = .appColor(.neutral800)
            $0.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        }
        descriptionLabel.do {
            $0.numberOfLines = 2
        }
        dateLabel.do {
            $0.font = .appFont(.pretendardRegular, size: 12)
            $0.textColor = .appColor(.neutral500)
        }
        separatorView.do {
            $0.backgroundColor = .appColor(.neutral400)
        }
    }
    
    private func setUpLayouts() {
        [emptyThumbnailImageView, thumbnailImageView, titleLabel, openCloseView, descriptionLabel, dateLabel, emptyThumbnailView, thumbnailImagesCollectionView, thumbnailImagesPageControl, separatorView].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        [emptyThumbnailImageView, thumbnailImageView, titleLabel, openCloseView, descriptionLabel, dateLabel, emptyThumbnailView, thumbnailImagesCollectionView, thumbnailImagesPageControl].forEach {
            $0.snp.removeConstraints()
        }
        separatorView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(0.5)
        }
        
        switch isExpanded {
        case true:
            titleLabel.snp.makeConstraints {
                $0.height.equalTo(24)
                $0.top.equalToSuperview().offset(16)
                $0.leading.equalToSuperview().offset(24)
                $0.trailing.lessThanOrEqualTo(openCloseView.snp.leading).offset(-16)
            }
            openCloseView.snp.makeConstraints {
                $0.trailing.equalToSuperview().offset(-24)
                $0.centerY.equalTo(titleLabel)
                $0.width.greaterThanOrEqualTo(48)
            }
            dateLabel.snp.makeConstraints {
                $0.height.equalTo(19)
                $0.top.equalTo(titleLabel.snp.bottom)
                $0.leading.equalToSuperview().offset(24)
                $0.trailing.equalToSuperview().offset(-24)
            }
            [thumbnailImageView, emptyThumbnailImageView, thumbnailImagesCollectionView, emptyThumbnailView].forEach {
                $0.snp.makeConstraints {
                    $0.height.equalTo(220)
                    $0.top.equalTo(dateLabel.snp.bottom).offset(16)
                    $0.leading.trailing.equalToSuperview().inset(24)
                }
            }
            thumbnailImagesPageControl.snp.makeConstraints {
                $0.top.equalTo(thumbnailImagesCollectionView.snp.bottom).offset(12)
                $0.centerX.equalToSuperview()
            }
            descriptionLabel.snp.makeConstraints {
                $0.top.equalTo(thumbnailImagesCollectionView.snp.bottom).offset(shouldShowPageControl ? 34 : 16)
                $0.leading.trailing.equalToSuperview().inset(24)
                $0.bottom.equalToSuperview().offset(-16).priority(999)
            }
        case false:
            [thumbnailImageView, emptyThumbnailImageView, thumbnailImagesCollectionView, emptyThumbnailView].forEach {
                $0.snp.makeConstraints {
                    $0.size.equalTo(70)
                    $0.top.bottom.equalToSuperview().inset(17.5).priority(999)
                    $0.leading.equalToSuperview().offset(24)
                }
            }
            titleLabel.snp.makeConstraints {
                $0.height.equalTo(24)
                $0.top.equalToSuperview().offset(12)
                $0.leading.equalTo(thumbnailImageView.snp.trailing).offset(12)
                $0.trailing.lessThanOrEqualTo(openCloseView.snp.leading).offset(-16)
            }
            openCloseView.snp.makeConstraints {
                $0.trailing.equalToSuperview().offset(-24)
                $0.centerY.equalTo(titleLabel)
                $0.width.greaterThanOrEqualTo(64)
            }
            descriptionLabel.snp.makeConstraints {
                $0.top.equalTo(titleLabel.snp.bottom)
                $0.leading.equalTo(titleLabel)
                $0.trailing.equalToSuperview().offset(-24)
            }
            dateLabel.snp.makeConstraints {
                $0.height.equalTo(19)
                $0.leading.equalTo(titleLabel)
                $0.trailing.equalToSuperview().offset(-24)
                $0.bottom.equalToSuperview().offset(-12)
            }
        }
    }
}
