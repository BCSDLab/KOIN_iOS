//
//  BusTimetableTabBarView.swift
//  koin
//
//  Created by 홍기정 on 11/4/26.
//

import Combine
import SnapKit
import Then
import UIKit

final class BusTimetableTabBarView: UIView {
    // MARK: - Properties
    let selectTabPublisher = PassthroughSubject<Int, Never>()
    private let titles: [String]
    private var tabButtons: [UIButton] = []
    private var indicatorLeadingConstraint: Constraint?

    // MARK: - UI Components
    private let stackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fillEqually
    }

    private let bottomLineView = UIView().then {
        $0.backgroundColor = .appColor(.neutral400)
    }

    private let indicatorView = UIView().then {
        $0.backgroundColor = .appColor(.new500)
    }

    // MARK: - Initialization
    init(titles: [String]) {
        self.titles = titles
        super.init(frame: .zero)
        configureView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public
    func update(selectedIndex: Int) {
        tabButtons.enumerated().forEach { index, button in
            let isSelected = index == selectedIndex
            button.isSelected = isSelected
            button.setTitleColor(isSelected ? .appColor(.new500) : .appColor(.neutral500), for: .normal)
            button.titleLabel?.font = isSelected ? .appFont(.pretendardSemiBold, size: 16) : .appFont(.pretendardRegular, size: 16)
        }
    }

    /// 페이지 스크롤 진행도(0 ~ titles.count - 1)에 맞춰 밑줄을 옮긴다.
    func updateIndicator(progress: CGFloat) {
        guard !titles.isEmpty else { return }
        let clamped = min(max(progress, 0), CGFloat(titles.count - 1))
        indicatorLeadingConstraint?.update(offset: bounds.width / CGFloat(titles.count) * clamped)
    }

    @objc private func tapTabButton(_ sender: UIButton) {
        selectTabPublisher.send(sender.tag)
    }
}

extension BusTimetableTabBarView {
    private func setUpLayouts() {
        titles.enumerated().forEach { index, title in
            let button = UIButton(type: .custom)
            button.tag = index
            button.setTitle(title, for: .normal)
            button.addTarget(self, action: #selector(tapTabButton(_:)), for: .touchUpInside)
            tabButtons.append(button)
            stackView.addArrangedSubview(button)
        }
        [stackView, bottomLineView, indicatorView].forEach {
            addSubview($0)
        }
    }

    private func setUpConstraints() {
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        bottomLineView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }
        indicatorView.snp.makeConstraints {
            indicatorLeadingConstraint = $0.leading.equalToSuperview().constraint
            $0.bottom.equalToSuperview()
            $0.height.equalTo(2)
            $0.width.equalToSuperview().dividedBy(max(titles.count, 1))
        }
    }

    private func configureView() {
        backgroundColor = .appColor(.neutral0)
        setUpLayouts()
        setUpConstraints()
        update(selectedIndex: 0)
    }
}
