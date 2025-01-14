//
//  LostArticleImageCollectionViewCell.swift
//  koin
//
//  Created by 김나훈 on 1/15/25.
//

import Combine
import UIKit

final class LostArticleImageCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    let cancelButtonPublisher = PassthroughSubject<Void, Never>()
    var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    
    private let imageView = UIImageView().then { _ in
    }
    

    private let cancelButton =  UIButton().then {
        $0.setImage(UIImage.appImage(asset: .cancelBlue), for: .normal)
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
    }
    
    @objc private func cancelButtonTapped() {
        cancelButtonPublisher.send(())
    }
}

extension LostArticleImageCollectionViewCell {
    private func setUpLayouts() {
        [imageView, cancelButton].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerY.equalToSuperview()
            make.leading.equalTo(contentView.snp.leading)
            make.trailing.equalTo(contentView.snp.trailing)
            make.bottom.equalToSuperview()
        }
        cancelButton.snp.makeConstraints { make in
            make.centerY.equalTo(contentView.snp.top)
            make.centerX.equalTo(contentView.snp.trailing)
            make.width.equalTo(16)
            make.height.equalTo(16)
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
    }
}
