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
    let moveDetailTimetablePublisher = PassthroughSubject<(String, String, String), Never>()
    let heightPublisher = PassthroughSubject<CGFloat, Never>()
    let tapIncorrectButtonPublisher = PassthroughSubject<Void, Never>()
    private var busInfo: [RouteRegion] = []
    private var semesterInfo: SemesterInfo = SemesterInfo(name: "", from: "", to: "")
    
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
        register(BusTimetableTableViewFooterView.self, forHeaderFooterViewReuseIdentifier: BusTimetableTableViewFooterView.identifier)
        delegate = self
        dataSource = self
        separatorStyle = .none
        showsVerticalScrollIndicator = false
        isScrollEnabled = false
        contentInset = .zero
        self.backgroundColor = .systemBackground
    }
    
    func updateShuttleBusInfo(busInfo: ShuttleRouteDTO) {
        self.busInfo = busInfo.routeRegions
        self.semesterInfo = busInfo.semesterInfo
        reloadData()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        heightPublisher.send(self.contentSize.height)
    }
}

extension ShuttleTimetableTableView: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return busInfo.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return busInfo[section].routes.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        let label = UILabel()
        label.text = busInfo[section].region
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
        if section != busInfo.count - 1 {
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
            guard let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: BusTimetableTableViewFooterView.identifier) as? BusTimetableTableViewFooterView else { return UIView() }
            
            view.configure(updatedDate: "\(semesterInfo.name)(\(semesterInfo.from) ~ \(semesterInfo.to))의\n시간표가 제공됩니다.")
            view.tapIncorrenctBusInfoButtonPublisher.sink { [weak self] in
                self?.tapIncorrectButtonPublisher.send()
            }.store(in: &view.subscriptions)
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
        let routeInfo = busInfo[section].routes[indexPath.row]
        cell.configure(routeType: routeInfo.type, route: routeInfo.routeName, subRoute: routeInfo.subName)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = busInfo[indexPath.section].routes[indexPath.row]
        moveDetailTimetablePublisher.send((item.id, item.type.rawValue, item.routeName))
    }
}

extension ShuttleTimetableTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let routeInfo = busInfo[indexPath.section].routes[indexPath.row]
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
        if section != busInfo.count - 1 {
            return 14
        }
        else {
            return 60
        }
    }
}





