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
    private var busSearchResultForLoad: [ScheduleInformation] = []
    private var itemsToShow: Int = 20
    private var shouldShowSeeMoreButton: Bool = true
    
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
    }
    
    func setBusSearchTime(departTime: String) {
        guard let view = self.headerView(forSection: 0) as? BusSearchResultTableViewHeader else { return }
        view.configureDepartTime(departTime: departTime)
    }
    
    func setBusSearchResult(busSearchResult: SearchBusInfoResult) {
        self.busSearchResult = busSearchResult
        self.busSearchResultForLoad = Array(busSearchResult.schedule.prefix(itemsToShow)) // 처음 20개만 부여
        shouldShowSeeMoreButton = busSearchResult.schedule.count > itemsToShow
        reloadData()
    }
    
    private func loadMoreResults() {
        let currentCount = busSearchResultForLoad.count
        
        guard currentCount < busSearchResult.schedule.count else {
            return
        }

        let newCount = min(currentCount + itemsToShow, busSearchResult.schedule.count)
        busSearchResultForLoad += Array(busSearchResult.schedule[currentCount..<newCount])
        shouldShowSeeMoreButton = newCount < busSearchResult.schedule.count
        
        reloadData()
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
        return busSearchResultForLoad.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: BusSearchResultTableViewCell.identifier, for: indexPath) as? BusSearchResultTableViewCell else { return UITableViewCell() }
        cell.configure(searchModel: busSearchResultForLoad[indexPath.row])
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
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: BusSearchResultTableViewFooter.reuseIdentifier) as? BusSearchResultTableViewFooter else { return UIView() }
        view.tapSeeMoreButtonPublisher.sink { [weak self] in
            self?.loadMoreResults()
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
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return shouldShowSeeMoreButton ? 90 : 0
    }
}



