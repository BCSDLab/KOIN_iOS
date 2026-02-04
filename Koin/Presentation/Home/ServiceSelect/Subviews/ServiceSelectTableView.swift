//
//  ServiceSelectTableView.swift
//  koin
//
//  Created by 홍기정 on 1/17/26.
//

import UIKit
import Combine

final class ServiceSelectTableView: UITableView {
    
    enum Service: String {
        case notice = "게시판"
        case lostItem = "분실물"
        case busTimeTable = "버스 시간표"
        case busSearch = "교통편 조회하기"
        case shop = "주변 상점"
        case dining = "식단"
        case timetable = "시간표"
        case facility = "교내 시설물 정보"
        case land = "복덕방"
        case business = "코인 for Business"
    }
    
    // MARK: - Properties
    private let services: [Service] = [.notice, .lostItem, .busTimeTable, .busSearch, .shop, .dining, .timetable, .facility, .land, .business]
    let serviceTappedPublisher = PassthroughSubject<Service, Never>()
    
    // MARK: - Initializer
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: .grouped)
        commonInit()
        separatorStyle = .none
        backgroundColor = .white
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - CommonInit
    private func commonInit() {
        register(ServiceSelectTableViewCell.self, forCellReuseIdentifier: ServiceSelectTableViewCell.identifier)
        dataSource = self
        delegate = self
    }
}

extension ServiceSelectTableView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return services.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ServiceSelectTableViewCell.identifier, for: indexPath) as? ServiceSelectTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(service: services[indexPath.row].rawValue)
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = ServiceSelectTableViewHeaderView()
        return header
    }
}

extension ServiceSelectTableView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        serviceTappedPublisher.send(services[indexPath.row])
    }
}
