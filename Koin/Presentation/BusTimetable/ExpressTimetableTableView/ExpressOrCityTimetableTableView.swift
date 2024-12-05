//
//  ExpressOrCityTimetableTableView.swift
//  koin
//
//  Created by JOOMINKYUNG on 11/30/24.
//

import Combine
import UIKit

final class ExpressOrCityTimetableTableView: UITableView {
    // MARK: - Properties
    private var subscribtions = Set<AnyCancellable>()
    private var busInfo: BusTimetableInfo = .init(courseName: "", routeName: "", arrivalInfos: [BusArrivalInfo(leftNode: "08:03", rightNode: "21:46"), BusArrivalInfo(leftNode: "08:03", rightNode: "21:46"), BusArrivalInfo(leftNode: "08:03", rightNode: "21:46"), BusArrivalInfo(leftNode: "08:03", rightNode: "21:46"), BusArrivalInfo(leftNode: "08:03", rightNode: "21:46"), BusArrivalInfo(leftNode: "08:03", rightNode: "21:46"), BusArrivalInfo(leftNode: "08:03", rightNode: "21:46"), BusArrivalInfo(leftNode: "08:03", rightNode: "21:46"), BusArrivalInfo(leftNode: "08:03", rightNode: "21:46"), BusArrivalInfo(leftNode: "08:03", rightNode: "21:46"), BusArrivalInfo(leftNode: "08:03", rightNode: "21:46")], updatedAt: "")
    
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
        register(ExpressOrCityTimetableTableViewCell.self, forCellReuseIdentifier: ExpressOrCityTimetableTableViewCell.identifier)
        delegate = self
        dataSource = self
        separatorStyle = .none
        showsVerticalScrollIndicator = false
        isScrollEnabled = false
        backgroundColor = .systemBackground
    }
    
    func updateExpressBusInfo(busInfo: BusTimetableInfo) {
        self.busInfo = busInfo
        reloadData()
    }
}

extension ExpressOrCityTimetableTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return busInfo.arrivalInfos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ExpressOrCityTimetableTableViewCell.identifier, for: indexPath) as? ExpressOrCityTimetableTableViewCell
        else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        let arrivalInfo = busInfo.arrivalInfos[indexPath.row]
        cell.configure(morningBusInfo: arrivalInfo.leftNode ?? "", secondBusInfo: arrivalInfo.rightNode ?? "")
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        let morningLabel = UILabel()
        let afternoonLabel = UILabel()
        morningLabel.text = "오전"
        afternoonLabel.text = "오후"
        [morningLabel, afternoonLabel].forEach {
            $0.font = .appFont(.pretendardRegular, size: 16)
            $0.textColor = .appColor(.neutral600)
            $0.textAlignment = .left
            view.addSubview($0)
        }
        morningLabel.frame = .init(x: 24, y: 16, width: 163, height: 26)
        afternoonLabel.frame = .init(x: tableView.frame.width - 24 - 163, y: 16, width: 163, height: 26)
        
        view.frame = CGRect(x: 0, y: 16, width: tableView.frame.width, height: 50)
        return view
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
    }
}

extension ExpressOrCityTimetableTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 61
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
}




