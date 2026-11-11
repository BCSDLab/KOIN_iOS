//
//  ManyBusTimetableCollectionView.swift
//  koin
//
//  Created by JOOMINKYUNG on 12/7/24.
//

import Combine
import UIKit

final class ManyBusTimetableCollectionView: UICollectionView {

    // MARK: Properties
    private var busTimeData: [RouteInfo] = []
    private var columnWidths: [CGFloat] = []
    var headerRowHeight: CGFloat = BusTimetableGridPageView.compactHeaderRowHeight

    // MARK: Init
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        backgroundColor = .clear
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        isScrollEnabled = true
        contentInset = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 0)

        register(ManyBusTimetableCollectionViewCell.self,
                 forCellWithReuseIdentifier: ManyBusTimetableCollectionViewCell.identifier)
        register(ManyBusTimetableCollectionViewHeaderCell.self,
                 forCellWithReuseIdentifier: ManyBusTimetableCollectionViewHeaderCell.reuseIdentifier)

        dataSource = self
        delegate = self
    }

    func configure(busInfo: [RouteInfo]) {
        self.busTimeData = busInfo
        // 셀마다 시간 전체를 재측정하지 않도록 컬럼 폭은 데이터 설정 시 한 번만 계산한다.
        self.columnWidths = busInfo.map { columnWidth(route: $0) }
        reloadData()
    }
}

// MARK: - UICollectionViewDataSource
extension ManyBusTimetableCollectionView: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        busTimeData.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        busTimeData[section].arrivalTime.count + 1
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0 {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ManyBusTimetableCollectionViewHeaderCell.reuseIdentifier,
                for: indexPath
            ) as? ManyBusTimetableCollectionViewHeaderCell else {
                return UICollectionViewCell()
            }

            let route = busTimeData[indexPath.section]
            cell.configure(name: route.name, detail: route.detail)
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ManyBusTimetableCollectionViewCell.identifier,
                for: indexPath
            ) as? ManyBusTimetableCollectionViewCell else {
                return UICollectionViewCell()
            }
            let time = busTimeData[indexPath.section].arrivalTime[indexPath.item - 1]
            cell.configure(busTime: time)
            return cell
        }
    }
}

// MARK: - UICollectionViewDelegate
extension ManyBusTimetableCollectionView: UICollectionViewDelegate {}

// MARK: - UICollectionViewDelegateFlowLayout
extension ManyBusTimetableCollectionView: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = columnWidths[indexPath.section]
        if indexPath.item == 0 {
            return CGSize(width: width, height: headerRowHeight)
        } else {
            return CGSize(width: width, height: BusTimetableGridPageView.rowHeight)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 4)
    }
    
    /// 회차 컬럼 폭: 기본 64, 헤더(회차명·detail)나 시간이 더 길면 좌우 padding 8을 더한 폭
    private func columnWidth(route: RouteInfo) -> CGFloat {
        let headerWidth = ([route.name] + [route.detail].compactMap { $0 })
            .map { textWidth($0, font: .appFont(.pretendardRegular, size: 14)) }
            .max() ?? 0
        let timeWidth = route.arrivalTime
            .map { textWidth($0 ?? "", font: .appFont(.pretendardBold, size: 16)) }
            .max() ?? 0
        return max(64, max(headerWidth, timeWidth) + 16)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat { 0 }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat { 0 }

    private func textWidth(_ text: String, font: UIFont) -> CGFloat {
        let attributes = [NSAttributedString.Key.font: font]
        let size = (text as NSString).size(withAttributes: attributes)
        return ceil(size.width)
    }
}
