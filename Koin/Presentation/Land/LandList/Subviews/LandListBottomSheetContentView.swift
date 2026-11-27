//
//  LandListBottomSheetContentView.swift
//  koin
//
//  Created by 홍기정 on 11/23/26.
//

import UIKit
import Combine
import SnapKit

final class LandListBottomSheetContentView: UIView, KoinBottomSheetContent {
    // MARK: - Properties
    weak var delegate: KoinBottomSheetDelegate?
    var filterTappedPublisher: PassthroughSubject<LandListFilter, Never> {
        filterView.filterTappedPublisher
    }
    var closeTappedPublisher: PassthroughSubject<Void, Never> {
        focusedView.closeTappedPublisher
    }
    var rowTappedPublisher: PassthroughSubject<LandRow, Never> {
        tableView.rowTappedPublisher
    }
    var detailTappedPublisher: PassthroughSubject<LandRow, Never> {
        focusedView.detailTappedPublisher
    }

    // MARK: - UI Components
    private let titleLabel = UILabel()
    private let filterView = LandListFilterView()
    private let tableView = LandListTableView()
    private let listView = UIView()
    
    private let focusedView = LandListFocusedView()

    // MARK: - Initializer
    init() {
        super.init(frame: .zero)
        configureView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension LandListBottomSheetContentView {
    func sheetHeight(in context: KoinBottomSheetContext) -> CGFloat {
        if focusedView.isHidden {
            return context.maximumHeight / 2
        }
        let focusedHeight = focusedView.systemLayoutSizeFitting(
            CGSize(width: context.width, height: 0),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height
        return min(focusedHeight, context.maximumHeight)
    }
}

extension LandListBottomSheetContentView {
    func configure(
        filter: LandListFilter,
        rows: [LandRow]
    ) {
        titleLabel.text = "\(LandListFilter.all.displayName)(\(rows.count))"
        filterView.configure(selectedFilter: filter)
        tableView.configure(rows: rows)
    }
    
    func showFocused(row: LandRow) {
        focusedView.configure(row: row)
        listView.isHidden = true
        focusedView.isHidden = false
        delegate?.invalidateHeight(animated: true)
    }
    
    func showList() {
        guard listView.isHidden else { return }
        listView.isHidden = false
        focusedView.isHidden = true
        delegate?.invalidateHeight(animated: true)
    }
}

extension LandListBottomSheetContentView {
    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }
    
    private func setUpStyles() {
        backgroundColor = .appColor(.neutral0)
        
        titleLabel.do {
            $0.font = .appFont(.pretendardSemiBold, size: 18)
            $0.textColor = UIColor.ColorSystem.Neutral.gray800
        }
        focusedView.do {
            $0.isHidden = true
        }
    }
    
    private func setUpLayouts() {
        [listView, focusedView].forEach {
            addSubview($0)
        }
        [titleLabel, filterView, tableView].forEach {
            listView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        listView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        focusedView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.lessThanOrEqualToSuperview()
        }
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.leading.trailing.equalToSuperview().inset(32)
            $0.height.equalTo(54)
        }
        filterView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom)
            $0.leading.trailing.equalToSuperview()
        }
        tableView.snp.makeConstraints {
            $0.top.equalTo(filterView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
}
