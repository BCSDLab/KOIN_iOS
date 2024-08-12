//
//  ReviewImageUploadCollectionViewCell.swift
//  koin
//
//  Created by 김나훈 on 8/13/24.
//

import Combine
import UIKit

final class ReviewImageUploadCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    let cancelButtonPublisher = PassthroughSubject<Void, Never>()
    
    // MARK: - UI Components
    
    private let imageView = UIImageView().then { _ in
    }
    

    private let cancelButton =  UIButton().then {
        $0.setImage(UIImage.appImage(asset: .cancelYellow), for: .normal)
    }


    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(imageUrl: String) {
        imageView.loadImage(from: imageUrl)
    }
    
    @objc private func cancelButtonTapped() {
        cancelButtonPublisher.send(())
    }
}

extension ReviewImageUploadCollectionViewCell {
    private func setUpLayouts() {
        [imageView, cancelButton].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        imageView.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top).offset(8)
            make.leading.equalTo(contentView.snp.leading)
            make.trailing.equalTo(contentView.snp.trailing).offset(-5)
            make.bottom.equalTo(contentView.snp.bottom).offset(8)
        }
        cancelButton.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top)
            make.trailing.equalTo(contentView.snp.trailing)
            make.width.equalTo(16)
            make.height.equalTo(16)
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
    }
}
