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
    let moveDetailTimetablePublisher = PassthroughSubject<Void, Never>()
    private var busInfo: [ShuttleTimetableInfos]  = [ShuttleTimetableInfos(region: "천안 아산", routes: [ShuttleTimetableInfo(routeType: .circular, routeName: "천안역"), ShuttleTimetableInfo(routeType: .circular, routeName: "천안역"), ShuttleTimetableInfo(routeType: .circular, routeName: "천안역"), ShuttleTimetableInfo(routeType: .circular, routeName: "천안역"), ShuttleTimetableInfo(routeType: .circular, routeName: "천안역")]), ShuttleTimetableInfos(region: "청주", routes: [ShuttleTimetableInfo(routeType: .circular, routeName: "청주셔틀"), ShuttleTimetableInfo(routeType: .circular, routeName: "용암동"), ShuttleTimetableInfo(routeType: .circular, routeName: "동남지구"), ShuttleTimetableInfo(routeType: .circular, routeName: "산남/분평")])]
    
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
    
    func updateShuttleBusInfo(busInfo: [ShuttleTimetableInfos]) {
        self.busInfo = busInfo
        reloadData()
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
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ShuttleTimetableTableViewCell.identifier, for: indexPath) as? ShuttleTimetableTableViewCell
        else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        let routeInfo = busInfo[section].routes[indexPath.row]
        cell.configure(routeType: routeInfo.routeType.rawValue, route: routeInfo.routeName)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        moveDetailTimetablePublisher.send()
    }
}

extension ShuttleTimetableTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 38
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 61
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 14
    }
}





