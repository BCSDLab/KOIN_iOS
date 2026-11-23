//
//  LandListFilterView.swift
//  koin
//
//  Created by 홍기정 on 11/23/26.
//

import UIKit
import Combine
import SnapKit

final class LandListFilterView: UIView {

    // MARK: - Properties
    let filterTappedPublisher = PassthroughSubject<LandListFilter, Never>()
    private let filters = LandListFilter.allCases

    // MARK: - UI Components
    private let stackView = UIStackView()
    private lazy var buttons = filters.map {
        LandListFilterButton(title: $0.displayName)
    }

    // MARK: - Initializer
    init() {
        super.init(frame: .zero)
        configureView()
        setAddTargets()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension LandListFilterView {
    func configure(selectedFilter: LandListFilter) {
        zip(filters, buttons).forEach { filter, button in
            button.isSelected = filter == selectedFilter
        }
    }
}

extension LandListFilterView {
    private func setAddTargets() {
        buttons.forEach {
            $0.addTarget(self, action: #selector(filterButtonTapped(_:)), for: .touchUpInside)
        }
    }
    
    @objc private func filterButtonTapped(_ sender: LandListFilterButton) {
        guard let index = buttons.firstIndex(of: sender) else { return }
        filterTappedPublisher.send(filters[index])
    }
}

extension LandListFilterView {
    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }
    
    private func setUpStyles() {
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
    }
    
    private func setUpLayouts() {
        addSubview(stackView)
        buttons.forEach {
            stackView.addArrangedSubview($0)
        }
    }
    
    private func setUpConstraints() {
        stackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.bottom.equalToSuperview().offset(-8)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.lessThanOrEqualToSuperview().offset(-24)
        }
        buttons.forEach { button in
            button.snp.makeConstraints {
                $0.height.equalTo(34)
            }
        }
    }
}
