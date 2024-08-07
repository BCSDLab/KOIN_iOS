//
//  EventListCollectionViewCell.swift
//  koin
//
//  Created by 김나훈 on 4/11/24.
//

import Combine
import UIKit

final class EventListCollectionViewCell: UICollectionViewCell {
    
    var isExpanded = false
    
    // MARK: - UI Components
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 5
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appFont(.pretendardMedium, size: 16)
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appFont(.pretendardRegular, size: 12)
        label.numberOfLines = 2
        label.textColor = UIColor.appColor(.neutral500)
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appFont(.pretendardRegular, size: 10)
        label.textColor = UIColor.appColor(.neutral500)
        return label
    }()
    
    private let viewAllButton: UIButton = {
        let button = UIButton()
        return button
    }()
    
    private let separateView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.appColor(.neutral200)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        viewAllButton.addTarget(self, action: #selector(viewAllButtonTapped), for: .touchUpInside)
    }
    
    override func prepareForReuse() {
        titleLabel.text = ""
        descriptionLabel.text = ""
        dateLabel.text = ""
        imageView.image = nil
        // ???: 이거 왜 세그먼트 컨트롤 때문에 아래와 같은 작업을 해야하는걸까?
        isExpanded = false
        updateLayoutForExpandedState()
        guard let collectionView = superview as? UICollectionView else { return }
        (superview as? EventListCollectionView)?.heightChanged?()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(event: ShopEvent) {
        titleLabel.text = event.title
        descriptionLabel.text = event.content
        dateLabel.text = event.startDate
        addButtonText(viewAll: false)
        guard let imageList = event.thumbnailImages else {
            imageView.image = UIImage.appImage(asset: .ownerReadyImage)
            return
        }
        if !imageList.isEmpty { imageView.loadImage(from: imageList[0]) } else {
            imageView.image = UIImage.appImage(asset: .ownerReadyImage)
        }
        
    }
    @objc private func viewAllButtonTapped() {
        isExpanded.toggle()
        addButtonText(viewAll: isExpanded)
        
        guard let collectionView = superview as? UICollectionView else { return }
        
        collectionView.performBatchUpdates({
            updateLayoutForExpandedState()
        }, completion: { [weak self] _ in
            (self?.superview as? EventListCollectionView)?.heightChanged?()
        })
        
    }
    private func updateLayoutForExpandedState() {
        descriptionLabel.numberOfLines = isExpanded ? 0 : 2
        UIView.animate(withDuration: 0.3) {
            self.setUpConstraints()
            self.layoutIfNeeded()
        }
    }
    
    func addButtonText(viewAll: Bool) {
        let text = "전체보기 "
        let image: UIImage = (viewAll ? UIImage.appImage(asset: .arrowUp) : UIImage.appImage(asset: .arrowDown)) ?? UIImage()
        
        let attributedText = NSMutableAttributedString(string: text, attributes: [
            .font: UIFont.appFont(.pretendardMedium, size: 12),
            .foregroundColor: UIColor.appColor(.neutral500)
        ])
        
        let textAttachment = NSTextAttachment()
        textAttachment.image = image
        textAttachment.bounds = CGRect(x: 0, y: -5, width: 16, height: 16)
        
        attributedText.append(NSAttributedString(attachment: textAttachment))
        
        viewAllButton.setAttributedTitle(attributedText, for: .normal)
    }
    
}

extension EventListCollectionViewCell: UIScrollViewDelegate {
    
    
}

extension EventListCollectionViewCell {
    private func setUpLayouts() {
        [imageView, titleLabel, viewAllButton, descriptionLabel, dateLabel, separateView].forEach {
            self.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        [imageView, titleLabel, descriptionLabel, viewAllButton, dateLabel, separateView].forEach {
            $0.snp.removeConstraints()
        }
        titleLabel.font = isExpanded ? UIFont.appFont(.pretendardMedium, size: 18) : UIFont.appFont(.pretendardMedium, size: 16)
        descriptionLabel.font = isExpanded ? UIFont.appFont(.pretendardRegular, size: 14) : UIFont.appFont(.pretendardRegular, size: 12)
        descriptionLabel.textColor = isExpanded ? UIColor.appColor(.neutral600) : UIColor.appColor(.neutral500)
        
        dateLabel.font = isExpanded ? UIFont.appFont(.pretendardMedium, size: 12) : UIFont.appFont(.pretendardMedium, size: 10)
        
        if !isExpanded {
            imageView.snp.remakeConstraints { make in
                make.top.equalTo(self.snp.top).offset(10)
                make.leading.equalTo(self.snp.leading).offset(24)
                make.height.equalTo(80)
                make.width.equalTo(72)
            }
            titleLabel.snp.remakeConstraints { make in
                make.top.equalTo(imageView.snp.top)
                make.leading.equalTo(imageView.snp.trailing).offset(16)
                make.trailing.equalTo(viewAllButton.snp.leading).offset(-5)
            }
            
            descriptionLabel.snp.remakeConstraints { make in
                make.top.equalTo(titleLabel.snp.bottom).offset(8)
                make.leading.equalTo(titleLabel.snp.leading)
                make.trailing.equalTo(self.snp.trailing)
            }
            
            viewAllButton.snp.remakeConstraints { make in
                make.top.equalTo(imageView.snp.top)
                make.trailing.equalTo(self.snp.trailing).offset(-24)
                make.width.equalTo(62)
                make.height.equalTo(16)
            }
            
            dateLabel.snp.remakeConstraints { make in
                make.bottom.equalTo(imageView.snp.bottom).offset(-1.5)
                make.leading.equalTo(descriptionLabel.snp.leading)
            }
            
            separateView.snp.remakeConstraints { make in
                make.leading.equalTo(imageView.snp.leading)
                make.trailing.equalTo(viewAllButton.snp.trailing)
                make.bottom.equalTo(self.snp.bottom)
                make.height.equalTo(1)
            }
        }
        else {
            imageView.snp.remakeConstraints { make in
                make.top.equalTo(self.snp.top).offset(10)
                make.leading.equalTo(self.snp.leading).offset(24)
                make.trailing.equalTo(self.snp.trailing).offset(-24)
                make.height.equalTo(363)
            }
            
            titleLabel.snp.remakeConstraints { make in
                make.top.equalTo(imageView.snp.bottom).offset(16)
                make.leading.equalTo(imageView.snp.leading)
                make.height.equalTo(21)
            }
            viewAllButton.snp.remakeConstraints { make in
                make.top.equalTo(titleLabel.snp.top)
                make.trailing.equalTo(imageView.snp.trailing)
            }
            descriptionLabel.snp.remakeConstraints { make in
                make.top.equalTo(titleLabel.snp.bottom).offset(12)
                make.leading.equalTo(imageView.snp.leading)
                make.trailing.equalTo(imageView.snp.trailing)
            }
            dateLabel.snp.remakeConstraints { make in
                make.top.equalTo(descriptionLabel.snp.bottom).offset(6)
                make.leading.equalTo(imageView.snp.leading)
            }
            
            separateView.snp.remakeConstraints { make in
                make.height.equalTo(1)
                make.leading.equalTo(imageView.snp.leading)
                make.trailing.equalTo(imageView.snp.trailing)
                make.bottom.equalTo(self.snp.bottom)
            }
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
    }
    
}



