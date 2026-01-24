//
//  LostItemDataContentView.swift
//  koin
//
//  Created by 홍기정 on 1/18/26.
//

import UIKit
import Combine

final class LostItemDataContentView: UIView {
    
    // MARK: - Properties
    let imageTapPublisher = PassthroughSubject<([String], IndexPath), Never>()
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    private let contentStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 8
        $0.alignment = .center
    }
    
    private let imageCollectionView = ShopSummaryImagesCollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout().then {
        $0.scrollDirection = .horizontal
        $0.itemSize = CGSize(width: UIScreen.main.bounds.width - 63, height: 278)
        $0.minimumLineSpacing = 0
    }).then {
        $0.showsHorizontalScrollIndicator = false
        $0.contentInsetAdjustmentBehavior = .never
    }
    
    private let pageControl = UIPageControl().then {
        $0.currentPage = 0
        $0.pageIndicatorTintColor = UIColor.appColor(.neutral300)
        $0.currentPageIndicatorTintColor = UIColor.appColor(.primary400)
        $0.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
    }
    
    private let labelStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 24
        $0.alignment = .fill
    }
    
    private let contentLabel = UILabel().then {
        $0.numberOfLines = 0
        $0.font = .appFont(.pretendardRegular, size: 14)
        $0.textColor = .appColor(.neutral800)
    }
    
    private let councilLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardRegular, size: 12)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        $0.textColor = UIColor.appColor(.neutral500)
        $0.numberOfLines = 3
        let text = "분실물 수령을 희망하시는 분은 재실 시간 내에\n학생회관 320호 총학생회 사무실로 방문해 주시기 바랍니다.\n재실 시간은 공지 사항을 참고해 주시기 바랍니다."
        let attributedString = NSMutableAttributedString(string: text)
        let range = (text as NSString).range(of: "학생회관 320호 총학생회 사무실")
        attributedString.addAttribute(.foregroundColor, value: UIColor.appColor(.neutral700), range: range)
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: text.count))
        $0.attributedText = attributedString
        $0.backgroundColor = UIColor.appColor(.neutral100)
        $0.layer.cornerRadius = 12
        $0.layer.masksToBounds = true
        $0.textAlignment = .center
        $0.isHidden = true
    }
    
    // MARK: - Initializer
    init() {
        super.init(frame: .zero)
        configureView()
        bind()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    func configure(images: [Image], content: String?, isCouncil: Bool) {
        imageCollectionView.configure(images: images)
        imageCollectionView.isHidden = images.isEmpty
        
        pageControl.numberOfPages = images.count
        pageControl.isHidden = images.count < 2
        
        if let content = content,
           !content.isEmpty {
            contentLabel.attributedText = NSAttributedString(string: "\(content)", attributes: [
                .font : UIFont.appFont(.pretendardRegular, size: 14),
                .foregroundColor : UIColor.appColor(.neutral800),
                .paragraphStyle : NSMutableParagraphStyle().then { $0.lineSpacing = 1.6 }
            ])
            contentLabel.isHidden = false
        } else {
            contentLabel.isHidden = true
        }
        
        councilLabel.isHidden = !isCouncil
        
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    private func bind() {
        imageCollectionView.didTapThumbnailPublisher.sink { [weak self] indexPath in
            guard let self else { return }
            imageTapPublisher.send((imageCollectionView.orderImages.map { $0.imageUrl }, indexPath))
        }.store(in: &subscriptions)
        
        imageCollectionView.didScrollOutputSubject.sink { [weak self] page in
            guard let self else { return }
            pageControl.currentPage = page
        }.store(in: &subscriptions)
    }
}


extension LostItemDataContentView {
    
    private func setUpLayouts() {
        [contentLabel, councilLabel].forEach {
            labelStackView.addArrangedSubview($0)
        }
        [imageCollectionView, pageControl, labelStackView].forEach {
            contentStackView.addArrangedSubview($0)
        }
        [contentStackView].forEach {
            addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        contentStackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-16)
        }
        
        imageCollectionView.snp.makeConstraints {
            $0.width.equalTo(UIScreen.main.bounds.width - 63)
            $0.height.equalTo(278)
        }
        
        pageControl.snp.makeConstraints {
            $0.height.equalTo(30)
        }
        
        contentLabel.snp.makeConstraints {
            $0.width.equalTo(UIScreen.main.bounds.width - 48)
        }
        
        councilLabel.snp.makeConstraints {
            $0.width.equalTo(UIScreen.main.bounds.width - 48)
            $0.height.equalTo(89)
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
    }
}
