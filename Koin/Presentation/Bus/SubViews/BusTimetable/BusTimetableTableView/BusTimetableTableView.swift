//
//  BusTimetableTableView.swift
//  koin
//
//  Created by JOOMINKYUNG on 7/27/24.
//

import SnapKit
import UIKit

final class BusTimetableTableView: UITableView, UITableViewDataSource, UITableViewDelegate {
    // MARK: - Properties
    private var busTimetableModel: BusTimetableInfo = BusTimetableInfo(courseName: "", routeName: "", arrivalInfos: [], updatedAt: "")
    private var busTimetableHeader: (String, String) = ("","")
    
    // MARK: - Initialization
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        register(BusTimetableTableViewCell.self, forCellReuseIdentifier: BusTimetableTableViewCell.identifier)
        register(BusTimetableTableViewHeaderView.self, forHeaderFooterViewReuseIdentifier: BusTimetableTableViewHeaderView.identifier)
        delegate = self
        dataSource = self
    }
    
    func setBusTimetableList(busTimetableModel: BusTimetableInfo, busTimetableHeader: (String, String)) {
        self.busTimetableModel = busTimetableModel
        self.busTimetableHeader = busTimetableHeader
        self.reloadData()
    }
}
extension BusTimetableTableView {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return busTimetableModel.arrivalInfos.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == busTimetableModel.arrivalInfos.count {
            let cell = UITableViewCell()
            var content = cell.defaultContentConfiguration()
            let updatedDate = busTimetableModel.updatedAt
            content.directionalLayoutMargins = .init(top: 10, leading: 22, bottom: 0, trailing: 22)
            content.attributedText = NSAttributedString(string: "기점 출발 시간표로 노선 별로 기점이 상이할 수 있습니다.", attributes: [
                .font: UIFont.appFont(.pretendardMedium, size: 12),.foregroundColor: UIColor.gray
            ])
            content.secondaryAttributedText = NSAttributedString(string: "업데이트 날짜: \(updatedDate)", attributes: [
                .font: UIFont.appFont(.pretendardMedium, size: 12), .foregroundColor: UIColor.gray
            ])
            cell.contentConfiguration = content
            cell.contentView.backgroundColor = .systemBackground
            cell.contentView.layer.addBorder([.top], color: UIColor.appColor(.neutral400), width: 1)
            return cell
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: BusTimetableTableViewCell.identifier, for: indexPath) as? BusTimetableTableViewCell
        else {
            return UITableViewCell()
        }
        cell.configure(arrivalInfo: busTimetableModel.arrivalInfos[indexPath.row])
        return cell
    }
}

extension BusTimetableTableView {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 39
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 39
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 39
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: BusTimetableTableViewHeaderView.identifier) as? BusTimetableTableViewHeaderView
        else {
            return UITableViewHeaderFooterView()
        }
        
        view.contentView.backgroundColor = UIColor.appColor(.neutral50)
        view.configure(headerInfo: busTimetableHeader)
        view.contentView.layer.addBorder([.top, .bottom], color: UIColor.appColor(.neutral400), width: 1)
        return view
    }

}
