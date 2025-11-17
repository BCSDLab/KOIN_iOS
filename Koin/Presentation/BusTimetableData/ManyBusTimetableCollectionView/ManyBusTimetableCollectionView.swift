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
    let contentWidthPublisher = PassthroughSubject<CGFloat, Never>()

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
        contentInset = .zero

        register(ManyBusTimetableCollectionViewCell.self,
                 forCellWithReuseIdentifier: ManyBusTimetableCollectionViewCell.identifier)
        register(ManyBusTimetableCollectionViewHeaderCell.self,
                 forCellWithReuseIdentifier: ManyBusTimetableCollectionViewHeaderCell.reuseIdentifier)

        dataSource = self
        delegate = self
    }

    func configure(busInfo: [RouteInfo]) {
        self.busTimeData = busInfo
        reloadData()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentWidthPublisher.send(contentSize.width)
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

        if indexPath.item == 0 {
            let sample = firstValidTime(in: busTimeData[indexPath.section].arrivalTime) ?? "—"
            let width = textWidth(sample,
                                  font: .appFont(.pretendardRegular, size: 14)) + 50
            return CGSize(width: width, height: 52)
        } else {
            let time = busTimeData[indexPath.section].arrivalTime[indexPath.item - 1] ?? "—"
            let width = textWidth(time,
                                  font: .appFont(.pretendardBold, size: 16)) + 20
            return CGSize(width: width, height: 46)
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat { 0 }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat { 0 }

    private func firstValidTime(in times: [String?]) -> String? {
        for time in times where time != nil && !(time?.isEmpty ?? true) { return time }
        return nil
    }

    private func textWidth(_ text: String, font: UIFont) -> CGFloat {
        let attributes = [NSAttributedString.Key.font: font]
        let size = (text as NSString).size(withAttributes: attributes)
        return ceil(size.width)
    }
}
