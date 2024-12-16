//
//  BusSearchResultTableView.swift
//  koin
//
//  Created by JOOMINKYUNG on 11/10/24.
//

import Combine
import UIKit

//추후 API 명세를 받고 모델을 정의할 것
struct TempBusSearchResult {
    let busType: BusType
    let busTime: String
    let remainTime: String
}

final class BusSearchResultTableView: UITableView {
    // MARK: - Properties
    private var subscribtions = Set<AnyCancellable>()
    private var busSearchResultList = [TempBusSearchResult(busType: .shuttleBus, busTime: "10:33", remainTime: "10분전"), TempBusSearchResult(busType: .shuttleBus, busTime: "10:33", remainTime: "10분전"), TempBusSearchResult(busType: .shuttleBus, busTime: "10:33", remainTime: "10분전"), TempBusSearchResult(busType: .shuttleBus, busTime: "10:33", remainTime: "10분전"), TempBusSearchResult(busType: .shuttleBus, busTime: "10:33", remainTime: "10분전"), TempBusSearchResult(busType: .shuttleBus, busTime: "10:33", remainTime: "10분전"), TempBusSearchResult(busType: .shuttleBus, busTime: "10:33", remainTime: "10분전")]
    
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
        delegate = self
        dataSource = self
        separatorStyle = .none
    }
}

extension BusSearchResultTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return busSearchResultList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: BusSearchResultTableViewCell.identifier, for: indexPath) as? BusSearchResultTableViewCell else { return UITableViewCell() }
        cell.configure(searchModel: busSearchResultList[indexPath.row])
        return cell
    }
}

extension BusSearchResultTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}



