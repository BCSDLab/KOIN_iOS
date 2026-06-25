//
//  HomeTabBar.swift
//  koin
//
//  Created by 홍기정 on 6/2/26.
//

import SnapKit
import UIKit

final class HomeTabBar: UIView {
    
    // MARK: - Layout
    private enum Layout {
        static let contentWidth: CGFloat = 35
        static let horizontalEdgesPadding: CGFloat = 24
        static let baseHeight: CGFloat = 52
        static let topPadding: CGFloat = 12
        static let cornerRadius: CGFloat = 16
    }
    private var additionalHeight: CGFloat {
        safeAreaInsets.bottom < 0.5 ? 6 : 0
    }
    private var bottomPadding: CGFloat {
        safeAreaInsets.bottom < 0.5 ? 6 : safeAreaInsets.bottom
    }
    private var interItemSpacing: CGFloat {
        let occupiedWidth = Layout.contentWidth * CGFloat(TabBarButtons.count)
        let leftWidth = self.bounds.width - Layout.horizontalEdgesPadding * 2 - occupiedWidth
        let result = leftWidth / CGFloat(TabBarButtons.count - 1)
        return result
    }
    
    // MARK: - Properties
    static let viewTag = 2143534265
    private let onTapItem: (Int) -> Void
    
    // MARK: - UI Components
    private var TabBarButtons: [HomeTabBarButton] = []
    
    // MARK: - Initializer
    init(tabs: [HomeTab], selectedTab: HomeTab, onTapItem: @escaping (Int)->Void) {
        self.onTapItem = onTapItem
        super.init(frame: .zero)
        self.tag = Self.viewTag
        self.TabBarButtons = tabs.map { tab in
            let TabBarButton = HomeTabBarButton(title: tab.title, imageAsset: tab.imageAsset)
            TabBarButton.tag = tab.rawValue
            TabBarButton.updateSelection(isSelected: tab == selectedTab)
            TabBarButton.addTarget(self, action: #selector(handleTap(_:)), for: .touchUpInside)
            return TabBarButton
        }
        configureView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    override func layoutSubviews() {
        super.layoutSubviews()
        updateButtonInsets()
    }
}

extension HomeTabBar {
    private func updateButtonInsets() {
        TabBarButtons.first?.updateContentInsets(left: Layout.horizontalEdgesPadding, right: interItemSpacing/2)
        TabBarButtons.last?.updateContentInsets(left: interItemSpacing/2, right: Layout.horizontalEdgesPadding)
        for index in TabBarButtons.indices {
            if index == 0 || index == TabBarButtons.count-1 { continue }
            TabBarButtons[index].updateContentInsets(left: interItemSpacing/2, right: interItemSpacing/2)
        }
    }
}

extension HomeTabBar {
    @objc private func handleTap(_ sender: UIControl) {
        onTapItem(sender.tag)
    }
}

extension HomeTabBar {
    
    private func configureView() {
        setUpStyles()
        setUpLayout()
        setUpConstraints()
    }
    
    private func setUpStyles() {
        backgroundColor = .appColor(.neutral0)
        self.layer.do {
            $0.cornerRadius = Layout.cornerRadius
            $0.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            $0.applySketchShadow(
                color: .appColor(.neutral800),
                alpha: 0.08,
                x: 0,
                y: -8,
                blur: 32,
                spread: 0
            )
        }
    }
    
    private func setUpLayout() {
        TabBarButtons.forEach {
            addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        TabBarButtons.first?.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.top.equalToSuperview()
        }
        for index in TabBarButtons.indices {
            if index == 0 {
                continue
            }
            TabBarButtons[index].snp.makeConstraints {
                $0.leading.equalTo(TabBarButtons[index-1].snp.trailing)
                $0.top.equalToSuperview()
            }
        }
    }
}
