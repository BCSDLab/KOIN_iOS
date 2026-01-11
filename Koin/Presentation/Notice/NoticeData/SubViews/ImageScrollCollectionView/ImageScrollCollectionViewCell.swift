//
//  ImageScrollCollectionViewCell.swift
//  koin
//
//  Created by 김나훈 on 1/16/25.
//

import Combine
import SnapKit
import UIKit
import Then

final class ImageScrollCollectionViewCell: UICollectionViewCell {
    
    let imageTapPublisher = PassthroughSubject<UIImage, Never>()
    var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    private let imageView = UIImageView().then {
        $0.isUserInteractionEnabled = true
    }
    private var subscribtions = Set<AnyCancellable>()
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        imageView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func imageTapped() {
        guard let image = imageView.image else { return }
        imageTapPublisher.send(image)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(imageUrl: String) {
        imageView.loadImage(from: imageUrl)
    }
    
}

extension ImageScrollCollectionViewCell {
    private func setUpLayouts() {
        [imageView].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
    }
}
