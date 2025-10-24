//
//  ReviewListHeaderView.swift
//  koin
//
//  Created by 김나훈 on 8/11/24.
//

import Combine
import UIKit
import DropDown
import SnapKit

final class ReviewListHeaderView: UICollectionReusableView {
    
    // MARK: - Constants
    
    static let identifier = "ReviewListHeaderView"
    
    // MARK: - Publishers
    
    let sortTypeButtonPublisher = PassthroughSubject<ReviewSortType, Never>()
    let myReviewButtonPublisher = PassthroughSubject<Bool, Never>()
    
    // MARK: - UI Components
    
    private let separateView = UIView().then {
        $0.backgroundColor = UIColor.appColor(.neutral300)
    }
    
    private let sortTypeButton = UIButton()
    
    private let myReviewButton = UIButton()
    
    private let dropDown = DropDown()
    
    // MARK: - Initialize
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        configureButtons()
        setupDropDown()
        setAddTarget()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    func updateHeader(fetchStandard: ReviewSortType, isMine: Bool) {
        configureSortTypeButton(type: fetchStandard)
        myReviewButton.isSelected = isMine
        configureMyReviewButton()
    }
}

extension ReviewListHeaderView {
    
    private func configureButtons() {
        configureSortTypeButton(type: .latest)
        configureMyReviewButton()
    }
    
    private func setAddTarget() {
        sortTypeButton.addTarget(self, action: #selector(sortTypeButtonTapped), for: .touchUpInside)
        myReviewButton.addTarget(self, action: #selector(myReviewButtonTapped), for: .touchUpInside)
    }
    
    private func setupDropDown() {
        dropDown.anchorView = sortTypeButton
        dropDown.bottomOffset = CGPoint(x: 0, y: sortTypeButton.bounds.height + 22)
        dropDown.direction = .bottom
        dropDown.dataSource = ReviewSortType.allCases.map { $0.koreanDescription }
        
        dropDown.selectionAction = { [weak self] index, _ in
            guard let self else { return }
            let selectedSortType = ReviewSortType.allCases[index]
            self.configureSortTypeButton(type: selectedSortType)
            self.sortTypeButtonPublisher.send(selectedSortType)
        }
        
        dropDown.cancelAction = { [weak self] in
            self?.updateSortTypeButtonImage(for: .chevronDown)
        }
    }
}

// MARK: - Button Configuration
extension ReviewListHeaderView {
    
    private func configureSortTypeButton(type: ReviewSortType) {
        var configuration = UIButton.Configuration.plain()
        
        var text = AttributedString(type.koreanDescription)
        text.font = UIFont.appFont(.pretendardRegular, size: 14)
        configuration.attributedTitle = text
        
        let imageSize = CGSize(width: 15, height: 12)
        let image = UIImage(systemName: SFSymbols.chevronDown.rawValue)
        let resizedImage = image?.withConfiguration(
            UIImage.SymbolConfiguration(pointSize: imageSize.width, weight: .regular)
        )
        configuration.image = resizedImage
        configuration.imagePlacement = .trailing
        configuration.imagePadding = 4
        
        configuration.baseBackgroundColor = .systemBackground
        configuration.baseForegroundColor = UIColor.appColor(.neutral500)
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        sortTypeButton.contentHorizontalAlignment = .leading
        sortTypeButton.configuration = configuration
    }
    
    private func configureMyReviewButton() {
        var configuration = UIButton.Configuration.plain()
        let imageSize = CGSize(width: 14.17, height: 14.17)
        let image = myReviewButton.isSelected
        ? UIImage(systemName: SFSymbols.checkmarkSquare.rawValue)
        : UIImage(systemName: SFSymbols.square.rawValue)
        
        let resizedImage = image?.withConfiguration(
            UIImage.SymbolConfiguration(pointSize: imageSize.width, weight: .regular)
        )
        configuration.image = resizedImage
        
        var text = AttributedString("내가 작성한 리뷰")
        text.font = UIFont.appFont(.pretendardRegular, size: 14)
        configuration.attributedTitle = text
        
        configuration.imagePadding = 4
        configuration.baseBackgroundColor = .systemBackground
        configuration.baseForegroundColor = UIColor.appColor(.neutral500)
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        myReviewButton.contentHorizontalAlignment = .leading
        myReviewButton.configuration = configuration
    }
    
    private func updateSortTypeButtonImage(for symbol: SFSymbols) {
        var configuration = sortTypeButton.configuration
        let imageSize = CGSize(width: 15, height: 12)
        let image = UIImage(systemName: symbol.rawValue)
        let resizedImage = image?.withConfiguration(
            UIImage.SymbolConfiguration(pointSize: imageSize.width, weight: .regular)
        )
        configuration?.image = resizedImage
        sortTypeButton.configuration = configuration
    }
}

// MARK: - @objc
extension ReviewListHeaderView {
    
    @objc private func sortTypeButtonTapped() {
        updateSortTypeButtonImage(for: .chevronUp)
        dropDown.show()
    }
    
    @objc private func myReviewButtonTapped() {
        myReviewButton.isSelected.toggle()
        configureMyReviewButton()
        myReviewButtonPublisher.send(myReviewButton.isSelected)
    }
}

extension ReviewListHeaderView {
    
    private func setUpLayout() {
        [separateView, sortTypeButton, myReviewButton].forEach {
            addSubview($0)
        }
    }
    
    private func setupConstraints() {
        separateView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(1)
        }
        
        sortTypeButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(24)
            $0.width.equalTo(100)
            $0.height.equalTo(22)
        }
        
        myReviewButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-24)
            $0.width.equalTo(120)
            $0.height.equalTo(22)
        }
    }
    
    private func configureView() {
        setUpLayout()
        setupConstraints()
        self.backgroundColor = UIColor.appColor(.newBackground)
    }
}
