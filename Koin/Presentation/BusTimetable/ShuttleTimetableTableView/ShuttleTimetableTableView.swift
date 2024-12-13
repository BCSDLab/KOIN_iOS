//
//  ShuttleTimetableTableView.swift
//  koin
//
//  Created by JOOMINKYUNG on 11/30/24.
//

import Combine
import SnapKit
import UIKit

final class ShuttleTimetableTableView: UITableView {
    // MARK: - Properties
    private var subscribtions = Set<AnyCancellable>()
    let moveDetailTimetablePublisher = PassthroughSubject<String, Never>()
    let heightPublisher = PassthroughSubject<CGFloat, Never>()
    private var busInfo: ShuttleRouteDTO = .init(routeRegions: [], semesterInfo: SemesterInfo(name: "", from: "", to: ""))
    
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
        register(ShuttleTimetableTableViewCell.self, forCellReuseIdentifier: ShuttleTimetableTableViewCell.identifier)
        delegate = self
        dataSource = self
        separatorStyle = .none
        showsVerticalScrollIndicator = false
        isScrollEnabled = false
        contentInset = .zero
        self.backgroundColor = .systemBackground
    }
    
    func updateShuttleBusInfo(busInfo: ShuttleRouteDTO) {
        self.busInfo = busInfo
        reloadData()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        heightPublisher.send(self.contentSize.height)
    }
}

extension ShuttleTimetableTableView: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return busInfo.routeRegions.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return busInfo.routeRegions[section].routes.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        let label = UILabel()
        label.text = busInfo.routeRegions[section].region
        label.font = .appFont(.pretendardBold, size: 18)
        label.textColor = .appColor(.neutral800)
        view.addSubview(label)
        label.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.centerY.equalToSuperview()
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section != busInfo.routeRegions.count - 1 {
            let view = UIView()
            let coloredView = UIView()
            view.backgroundColor = .systemBackground
            coloredView.backgroundColor = .appColor(.neutral100)
            view.addSubview(coloredView)
            
            view.frame = .init(x: 0, y: 0, width: tableView.frame.width, height: 14)
            coloredView.frame = .init(x: 0, y: 7, width: tableView.frame.width, height: 7)
            return view
        }
        else {
            let view = UIView()
            let label = UILabel()
            label.text = "\(busInfo.semesterInfo.name)(\(busInfo.semesterInfo.from) ~ \(busInfo.semesterInfo.to))의\n시간표가 제공됩니다."
            label.font = .appFont(.pretendardRegular, size: 14)
            label.textAlignment = .left
            label.textColor = .appColor(.neutral500)
            label.numberOfLines = 0
            label.frame = .init(x: 23, y: 8, width: tableView.frame.width, height: 44)
            view.addSubview(label)
            view.frame = .init(x: 0, y: 0, width: tableView.frame.width, height: 60)
            return view
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ShuttleTimetableTableViewCell.identifier, for: indexPath) as? ShuttleTimetableTableViewCell
        else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        let routeInfo = busInfo.routeRegions[section].routes[indexPath.row]
        cell.configure(routeType: routeInfo.type, route: routeInfo.routeName, subRoute: routeInfo.subName)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        moveDetailTimetablePublisher.send(busInfo.routeRegions[indexPath.section].routes[indexPath.row].id)
    }
}

extension ShuttleTimetableTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let routeInfo = busInfo.routeRegions[indexPath.section].routes[indexPath.row]
        if routeInfo.subName != nil {
            return 57
        }
        else {
            return 38
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 61
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section != busInfo.routeRegions.count - 1 {
            return 14
        }
        else {
            return 60
        }
    }
}





