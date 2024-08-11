//
//  ReviewListHeaderView.swift
//  koin
//
//  Created by 김나훈 on 8/11/24.
//

import Combine
import DropDown
import Then
import UIKit

final class ReviewListHeaderView: UICollectionReusableView {
    
    static let identifier = "ReviewListHeaderView"
    let sortTypeButtonPublisher = PassthroughSubject<ReviewSortType, Never>()
    let myReviewButtonPublisher = PassthroughSubject<Bool, Never>()
    
    private let separateView = UIView().then {
        $0.backgroundColor = UIColor.appColor(.neutral200)
    }
    
    private let sortTypeButton = UIButton().then { _ in
    }
    
    private let myReviewButton = UIButton().then { _ in
    }
    
    private let dropDown = DropDown()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setUpSortTypeButtonText(type: .latest)
        setUpMyReviewButtonText()
        setUpDropDown()
        sortTypeButton.addTarget(self, action: #selector(sortTypeButtonTapped), for: .touchUpInside)
        myReviewButton.addTarget(self, action: #selector(myReviewButtonTapped), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpDropDown() {
        dropDown.anchorView = sortTypeButton
        dropDown.bottomOffset = CGPoint(x: 0, y: sortTypeButton.bounds.height + 22)
        dropDown.direction = .bottom
        dropDown.dataSource = ReviewSortType.allCases.map { $0.koreanDescription }
        dropDown.selectionAction = { [weak self] index, item in
            guard let self = self else { return }
            let selectedSortType = ReviewSortType.allCases[index]
            self.setUpSortTypeButtonText(type: selectedSortType)
            sortTypeButtonPublisher.send(selectedSortType)
        }
        dropDown.cancelAction = { [weak self] in
            self?.updateSortTypeButtonImage(for: .chevronDown)
        }
    }
    @objc private func sortTypeButtonTapped() {
        var configuration = sortTypeButton.configuration
        let imageSize = CGSize(width: 15, height: 12)
        let image = UIImage(systemName: SFSymbols.chevronUp.rawValue)
        let resizedImage = image?.withConfiguration(
            UIImage.SymbolConfiguration(pointSize: imageSize.width, weight: .regular)
        )
        configuration?.image = resizedImage
        sortTypeButton.configuration = configuration
        dropDown.show()
    }
    
    @objc private func myReviewButtonTapped() {
        myReviewButton.isSelected.toggle()
        setUpMyReviewButtonText()
        myReviewButtonPublisher.send(myReviewButton.isSelected)
    }
    
    private func setUpSortTypeButtonText(type: ReviewSortType) {
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
    
    private func setUpMyReviewButtonText() {
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
extension ReviewListHeaderView {
    
    private func setupViews() {
        [separateView, sortTypeButton, myReviewButton].forEach { component in
            addSubview(component)
        }
        
        separateView.snp.makeConstraints { make in
            make.top.equalTo(self.snp.top)
            make.leading.equalTo(self.snp.leading)
            make.trailing.equalTo(self.snp.trailing).offset(-16)
            make.height.equalTo(1)
        }
        
        sortTypeButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(self.snp.leading)
            make.width.equalTo(100)
            make.height.equalTo(22)
        }
        
        myReviewButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalTo(self.snp.trailing).offset(-24)
            make.width.equalTo(120)
            make.height.equalTo(22)
        }
        
    }
    
}
