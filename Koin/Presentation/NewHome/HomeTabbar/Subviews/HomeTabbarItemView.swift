//
//  HomeTabbarItemView.swift
//  koin
//
//  Created by 홍기정 on 6/2/26.
//

import SnapKit
import UIKit

final class HomeTabbarItemView: UIControl {

    // MARK: - UI Components
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let stackView = UIStackView()

    // MARK: - Initializer
    init(title: String, imageAsset: ImageAsset) {
        super.init(frame: .zero)
        imageView.image = UIImage.appImage(asset: imageAsset)?.withRenderingMode(.alwaysTemplate)
        titleLabel.text = title
        configureView()
        updateSelection(isSelected: false)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public
    func updateSelection(isSelected: Bool) {
        let color = isSelected ? UIColor.appColor(.new500) : UIColor.appColor(.neutral800)
        imageView.tintColor = color
        titleLabel.textColor = color
    }
}

extension HomeTabbarItemView {
    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }
    
    private func setUpStyles() {
        imageView.contentMode = .scaleAspectFit
        
        titleLabel.font = .appFont(.pretendardRegular, size: 10)
        titleLabel.textAlignment = .center
        
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 0
        stackView.isUserInteractionEnabled = false
    }
    
    private func setUpLayouts() {
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(titleLabel)
        
        addSubview(stackView)
    }
    
    private func setUpConstraints() {
        titleLabel.snp.makeConstraints {
            $0.height.equalTo(16)
        }
        stackView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        self.snp.makeConstraints {
            $0.width.equalTo(35)
            $0.height.equalTo(40)
        }
    }
}
