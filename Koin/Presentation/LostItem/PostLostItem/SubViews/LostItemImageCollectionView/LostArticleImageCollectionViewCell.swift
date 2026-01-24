//
//  LostArticleImageCollectionViewCell.swift
//  koin
//
//  Created by 김나훈 on 1/15/25.
//

import Combine
import UIKit

final class LostItemImageCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    let shouldDismissDropDownKeyBoardPublisher = PassthroughSubject<Void, Never>()
    let cancelButtonPublisher = PassthroughSubject<Void, Never>()
    var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    
    private let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
    }

    private let cancelButton =  UIButton().then {
        $0.setImage(UIImage.appImage(asset: .cancelBlue), for: .normal)
    }

    // MARK: - Initializer
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
        imageView.loadImageWithSpinner(from: imageUrl)
    }
    
    @objc private func cancelButtonTapped() {
        shouldDismissDropDownKeyBoardPublisher.send()
        cancelButtonPublisher.send(())
    }
    
    // MARK: - cell의 bounds 밖에있는 deleteButton이 눌리도록 함
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if super.point(inside: point, with: event) {
            return true
        }
        
        for subview in subviews {
            let pointInSubview = subview.convert(point, from: self)
            if !subview.isHidden
                && subview.isUserInteractionEnabled
                && subview.point(inside: pointInSubview, with: event) {
                return true
            }
        }
        return false
    }
}

extension LostItemImageCollectionViewCell {
    private func setUpLayouts() {
        [imageView, cancelButton].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
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
