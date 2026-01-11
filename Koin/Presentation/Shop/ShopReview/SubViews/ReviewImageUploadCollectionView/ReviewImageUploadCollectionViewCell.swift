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
    var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    
    private let imageView = UIImageView().then { _ in
    }
    

    private let cancelButton =  UIButton().then {
        $0.setImage(UIImage.appImage(asset: .cancelGray), for: .normal)
    }


    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }
    
    func configure(imageUrl: String) {
        imageView.loadImage(from: imageUrl)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
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
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        cancelButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(-6)
            $0.trailing.equalToSuperview().offset(6)
            $0.width.equalTo(16)
            $0.height.equalTo(16)
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
    }
}
