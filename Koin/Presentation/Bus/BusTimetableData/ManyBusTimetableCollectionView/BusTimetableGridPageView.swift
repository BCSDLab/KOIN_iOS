//
//  BusTimetableGridPageView.swift
//  koin
//
//  Created by 홍기정 on 11/4/26.
//

import Combine
import SnapKit
import Then
import UIKit

/// 회차 그리드 페이지: 승하차장명 고정 컬럼 + 회차 컬럼 가로 스크롤, 페이지 전체는 세로 스크롤.
final class BusTimetableGridPageView: UIScrollView {
    // MARK: - Properties
    static let headerRowHeight: CGFloat = 52
    static let rowHeight: CGFloat = 50
    let tapIncorrectButtonPublisher = PassthroughSubject<Void, Never>()
    private var gridHeightConstraint: Constraint?

    // MARK: - UI Components
    private let contentView = UIView()

    private let headerBandView = UIView().then {
        $0.backgroundColor = .appColor(.neutral100)
    }

    private let stationTableView = ManyBusTimetableTableView(frame: .zero, style: .plain)

    private let separatorView = UIView().then {
        $0.backgroundColor = .appColor(.neutral300)
    }

    private let timeCollectionView = ManyBusTimetableCollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        $0.collectionViewLayout = layout
    }

    private let incorrectBusInfoButton = UIButton().then {
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage.appImage(asset: .incorrectInfo)
        let title = AttributedString("정보가 정확하지 않나요?", attributes: AttributeContainer([
            .font: UIFont.appFont(.pretendardRegular, size: 12),
            .foregroundColor: UIColor.appColor(.neutral500)
        ]))
        configuration.attributedTitle = title
        configuration.imagePadding = 4
        configuration.contentInsets = .init(top: 5, leading: 0, bottom: 5, trailing: 0)
        $0.configuration = configuration
    }

    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(nodeInfo: [NodeInfo], routeInfo: [RouteInfo]) {
        stationTableView.configure(timetable: nodeInfo)
        timeCollectionView.configure(busInfo: routeInfo)
        // 가로 flow layout은 높이가 한 컬럼보다 작으면 섹션을 다음 열로 접는다 → 데이터로 정확히 계산.
        gridHeightConstraint?.update(offset: Self.headerRowHeight + Self.rowHeight * CGFloat(nodeInfo.count))
    }

    @objc private func tapIncorrectButton() {
        tapIncorrectButtonPublisher.send()
    }
}

extension BusTimetableGridPageView {
    private func setUpLayouts() {
        addSubview(contentView)
        [headerBandView, stationTableView, separatorView, timeCollectionView, incorrectBusInfoButton].forEach {
            contentView.addSubview($0)
        }
    }

    private func setUpConstraints() {
        contentView.snp.makeConstraints {
            $0.edges.equalTo(contentLayoutGuide)
            $0.width.equalTo(frameLayoutGuide)
        }
        headerBandView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(Self.headerRowHeight)
        }
        stationTableView.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
            $0.width.equalTo(156)
            gridHeightConstraint = $0.height.equalTo(Self.headerRowHeight).constraint
        }
        separatorView.snp.makeConstraints {
            $0.leading.equalTo(stationTableView.snp.trailing)
            $0.top.bottom.equalTo(stationTableView)
            $0.width.equalTo(1)
        }
        timeCollectionView.snp.makeConstraints {
            $0.leading.equalTo(separatorView.snp.trailing)
            $0.trailing.equalToSuperview()
            $0.top.bottom.equalTo(stationTableView)
        }
        incorrectBusInfoButton.snp.makeConstraints {
            $0.top.equalTo(stationTableView.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(24)
            $0.height.equalTo(20)
            $0.bottom.equalToSuperview().inset(24)
        }
    }

    private func configureView() {
        backgroundColor = .appColor(.neutral0)
        showsVerticalScrollIndicator = false
        contentInsetAdjustmentBehavior = .never
        stationTableView.sectionHeaderTopPadding = 0
        setUpLayouts()
        setUpConstraints()
        incorrectBusInfoButton.addTarget(self, action: #selector(tapIncorrectButton), for: .touchUpInside)
    }
}
