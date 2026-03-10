//
//  CallVanReportImagesCollectionViewCell.swift
//  koin
//
//  Created by 홍기정 on 3/10/26.
//

import UIKit
import Combine
import SnapKit
import Then

final class CallVanReportImagesCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    let cancelButtonPublisher = PassthroughSubject<String, Never>()
    private var imageUrl: String?
    var subscriptions = Set<AnyCancellable>()
    
    // MARK: - UI Components
    private let imageView = UIImageView()
    private let cancelButton = UIButton()
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        setAddTargets()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Override
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        subscriptions.forEach { $0.cancel() }
        subscriptions.removeAll()
    }
    
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
    
    // MARK: - Public
    func configure(imageUrl: String) {
        self.imageUrl = imageUrl
        imageView.loadImageWithSpinner(from: imageUrl)
    }
}

extension CallVanReportImagesCollectionViewCell {
    
    private func setAddTargets() {
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
    }
    
    @objc private func cancelButtonTapped() {
        if let imageUrl {
            cancelButtonPublisher.send(imageUrl)
        }
    }
}

extension CallVanReportImagesCollectionViewCell {
    
    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }
    
    private func setUpStyles() {
        imageView.do {
            $0.contentMode = .scaleAspectFill
            $0.clipsToBounds = true
        }
        cancelButton.do {
            $0.setImage(UIImage.appImage(asset: .cancelBlue)?.withRenderingMode(.alwaysTemplate), for: .normal)
            $0.tintColor = UIColor.appColor(.new900)
        }
    }
    
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
            $0.centerY.equalTo(contentView.snp.top)
            $0.centerX.equalTo(contentView.snp.trailing)
            $0.size.equalTo(16)
        }
    }
}
