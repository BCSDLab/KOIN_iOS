//
//  HomeTabbarView.swift
//  koin
//
//  Created by 홍기정 on 6/2/26.
//

import SnapKit
import UIKit

final class HomeTabbarView: UIView {
    
    enum Layout {
        static let horizontalPadding: CGFloat = 24
        static let itemTopPadding: CGFloat = 12
        static let barHeight: CGFloat = 52
        static let cornerRadius: CGFloat = 16
    }
    
    // MARK: - Properties
    var onTapItem: ((Int) -> Void)?
    
    // MARK: - UI Components
    private let tabItemStackView = UIStackView()
    private var tabItemViews: [HomeTabbarItemView] = []
    
    // MARK: - Initializer
    init(items: [HomeTabbarItem]) {
        super.init(frame: .zero)
        configureView(items)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    func updateSelectedIndex(_ index: Int) {
        tabItemViews.enumerated().forEach { itemIndex, itemView in
            itemView.updateSelection(isSelected: itemIndex == index)
        }
    }
}

extension HomeTabbarView {
    
    private func configureView(_ items: [HomeTabbarItem]) {
        setUpStyles()
        setUpLayout()
        setUpConstraints()
        setUpItems(items)
    }

    private func setUpStyles() {
        backgroundColor = .white
        self.layer.do {
            $0.cornerRadius = Layout.cornerRadius
            $0.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            $0.shadowColor = UIColor.black.withAlphaComponent(0.08).cgColor
            $0.shadowOpacity = 1
            $0.shadowRadius = 16
            $0.shadowOffset = CGSize(width: 0, height: 8)
        }
        tabItemStackView.do {
            $0.axis = .horizontal
            $0.alignment = .center
            $0.distribution = .equalSpacing
        }
    }

    private func setUpLayout() {
        addSubview(tabItemStackView)
    }
    
    private func setUpConstraints() {
        tabItemStackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(Layout.itemTopPadding)
            $0.leading.equalToSuperview().offset(Layout.horizontalPadding)
            $0.trailing.equalToSuperview().inset(Layout.horizontalPadding)
        }
    }

    private func setUpItems(_ items: [HomeTabbarItem]) {
        tabItemViews = items.enumerated().map { index, item in
            let itemView = HomeTabbarItemView(title: item.title, imageAsset: item.imageAsset)
            itemView.tag = index
            itemView.addTarget(self, action: #selector(handleTap(_:)), for: .touchUpInside)
            tabItemStackView.addArrangedSubview(itemView)
            return itemView
        }
    }

    @objc private func handleTap(_ sender: UIControl) {
        onTapItem?(sender.tag)
    }
}
