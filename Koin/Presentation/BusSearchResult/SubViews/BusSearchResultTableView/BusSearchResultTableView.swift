//
//  BusSearchResultTableView.swift
//  koin
//
//  Created by JOOMINKYUNG on 11/10/24.
//

import Combine
import DropDown
import UIKit

final class BusSearchResultTableView: UITableView {
    // MARK: - Properties
    let tapDepartTimeButtonPublisher = PassthroughSubject<Void, Never>()
    let tapDepartBusTypeButtonPublisher = PassthroughSubject<BusType, Never>()
    private var subscriptions = Set<AnyCancellable>()
    private var busSearchResult: SearchBusInfoResult = .init(depart: .koreatech, arrival: .terminal, departDate: Date(), departTime: Date(), schedule: [])
    private var busSearchSchedule: [ScheduleInformation] = []
    
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
        register(BusSearchResultTableViewFooter.self, forHeaderFooterViewReuseIdentifier: BusSearchResultTableViewFooter.reuseIdentifier)
        delegate = self
        dataSource = self
        separatorStyle = .none
        backgroundColor = .systemBackground
        sectionHeaderTopPadding = 0
    }
    
    func setBusSearchTime(departTime: String) {
        guard let view = self.headerView(forSection: 0) as? BusSearchResultTableViewHeader else { return }
        view.configureDepartTime(departTime: departTime)
    }
    
    func setBusSearchResult(busSearchResult: SearchBusInfoResult) {
        self.busSearchResult = busSearchResult
        self.busSearchSchedule = busSearchResult.schedule
        reloadData()
        if busSearchResult.schedule.count > 0 {
            scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
    
    private func showDropDown() {
        let dropDown = DropDown()
        guard let view = self.headerView(forSection: 0) as? BusSearchResultTableViewHeader else { return }
        dropDown.dataSource = ["전체 차종", "셔틀버스", "대성고속", "시내버스"]
        dropDown.selectionAction = { [weak self] (index, item) in
            let busType: BusType = index == 0 ? .noValue : BusType.allCases[index - 1]
            view.configureDepartBusType(busType: busType)
            self?.tapDepartBusTypeButtonPublisher.send(busType)
        }
        dropDown.anchorView = view
        dropDown.bottomOffset = .init(x: (dropDown.anchorView?.plainView.bounds.width ?? 0) - 128, y: (dropDown.anchorView?.plainView.bounds.height ?? 0) - 16)
        dropDown.width = 104
        dropDown.show()
    }
}


extension BusSearchResultTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return busSearchSchedule.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: BusSearchResultTableViewCell.identifier, for: indexPath) as? BusSearchResultTableViewCell else { return UITableViewCell() }
        cell.selectionStyle = .none
        cell.configure(searchModel: busSearchSchedule[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: BusSearchResultTableViewHeader.identifier) as? BusSearchResultTableViewHeader else { return UIView() }
        view.tapDepartTimeButtonPublisher.sink { [weak self] in
            self?.tapDepartTimeButtonPublisher.send()
        }.store(in: &view.subscriptions)
        view.tapDepartBusTypeButtonPublisher.sink { [weak self] in
            self?.showDropDown()
        }.store(in: &view.subscriptions)
        return view
    }
}

extension BusSearchResultTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 72
    }
}



