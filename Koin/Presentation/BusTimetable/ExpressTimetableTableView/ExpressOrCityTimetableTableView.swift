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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
    }
}

extension ExpressOrCityTimetableTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 61
    }
}




