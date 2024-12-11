//
//  BusSearchResultTableView.swift
//  koin
//
//  Created by JOOMINKYUNG on 11/10/24.
//

import Combine
import UIKit

final class BusSearchResultTableView: UITableView {
    // MARK: - Properties
    let tapDepartTimeButtonPublisher = PassthroughSubject<Void, Never>()
    let departTimeAndBusTypePublisher = PassthroughSubject<(String, BusType), Never>()
    private var subscribtions = Set<AnyCancellable>()
    private var busSearchResult: [ScheduleInformation] = []
    
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
        register(BusSearchResultTableViewCell.self, forCellReuseIdentifier: BusSearchResultTableViewCell.identifier)
        register(BusSearchResultTableViewHeader.self, forHeaderFooterViewReuseIdentifier: BusSearchResultTableViewHeader.identifier)
        delegate = self
        dataSource = self
        separatorStyle = .none
        backgroundColor = .systemBackground
    }
    
    func configureDepartInfo(date: String) {
        guard let view = self.headerView(forSection: 0) as? BusSearchResultTableViewHeader else { return }
        view.configureDepartTime(departTime: date)
    }
    
    func setBusSearchDate(busSearchResult: [ScheduleInformation]) {
        self.busSearchResult = busSearchResult
        reloadData()
    }
}

extension BusSearchResultTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return busSearchResult.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: BusSearchResultTableViewCell.identifier, for: indexPath) as? BusSearchResultTableViewCell else { return UITableViewCell() }
        cell.configure(searchModel: busSearchResult[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: BusSearchResultTableViewHeader.identifier) as? BusSearchResultTableViewHeader else { return UIView() }
        view.tapDepartTimeButtonPublisher.sink { [weak self] in
            self?.tapDepartTimeButtonPublisher.send()
        }.store(in: &view.subscriptions)
        return view
    }
}

extension BusSearchResultTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 72
    }
}




