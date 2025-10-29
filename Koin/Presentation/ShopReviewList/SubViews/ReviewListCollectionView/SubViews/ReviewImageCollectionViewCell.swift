//
//  ReviewImageCollectionViewCell.swift
//  koin
//
//  Created by 김나훈 on 7/9/24.
//

import Combine
import Then
import UIKit

final class ReviewImageCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    let imageTapPublisher = PassthroughSubject<UIImage?, Never>()
    var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    
    private let menuImageView = UIImageView().then {
        $0.layer.cornerRadius = 10
        $0.layer.masksToBounds = true
        $0.isUserInteractionEnabled = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        menuImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageTapped)))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }
    
    @objc private func imageTapped() {
        imageTapPublisher.send(menuImageView.image)
    }
    
    func configure(imageURL: String) {
        menuImageView.loadImage(from: imageURL)
    }
}

extension ReviewImageCollectionViewCell {
    private func setUpLayouts() {
        [menuImageView].forEach {
            self.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        menuImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
    }
    
}
