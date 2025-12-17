//
//  MenuListCollectionViewCell.swift
//  Koin
//
//  Created by 김나훈 on 3/15/24.
//

import Combine
import UIKit

final class MenuImageCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    let imageTapPublisher = PassthroughSubject<UIImage?, Never>()
    
    // MARK: - UI Components
    private let imageView = UIImageView().then {
        $0.isUserInteractionEnabled = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))
        imageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(imageURL: String) {
        imageView.loadImage(from: imageURL)
    }
}

extension MenuImageCollectionViewCell: UIScrollViewDelegate {
    
    @objc func imageViewTapped(_ sender: UITapGestureRecognizer) {
        imageTapPublisher.send(imageView.image)
    }
    
}

extension MenuImageCollectionViewCell {
    private func setUpLayouts() {
        [imageView].forEach {
            self.addSubview($0)
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
