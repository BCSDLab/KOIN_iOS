//
//  ExpressOrCityTimetableTableView.swift
//  koin
//
//  Created by JOOMINKYUNG on 11/30/24.
//

import Combine
import SnapKit
import UIKit

final class ExpressOrCityTimetableTableView: UITableView {
    // MARK: - Properties
    private var subscribtions = Set<AnyCancellable>()
    private var busInfo: [BusArrivalInfo] = []
    private var updatedAt: String = ""
    let tapIncorrectButtonPublisher = PassthroughSubject<Void, Never>()
    
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
        isScrollEnabled = true
        contentInsetAdjustmentBehavior = .never
        backgroundColor = .systemBackground
        register(BusTimetableTableViewFooterView.self, forHeaderFooterViewReuseIdentifier: BusTimetableTableViewFooterView.identifier)
    }
    
    func updateBusInfo(busInfo: BusTimetableInfo) {
        self.busInfo = busInfo.arrivalInfos
        self.updatedAt = busInfo.updatedAt
        reloadData()
    }
    }

extension ExpressOrCityTimetableTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return busInfo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ExpressOrCityTimetableTableViewCell.identifier, for: indexPath) as? ExpressOrCityTimetableTableViewCell
        else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        let arrivalInfo = busInfo[indexPath.row]
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
        morningLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(24)
            $0.height.equalTo(26)
        }
        afternoonLabel.snp.makeConstraints {
            $0.top.height.equalTo(morningLabel)
            $0.leading.equalTo(morningLabel.snp.trailing).offset(16)
            $0.trailing.equalToSuperview().inset(24)
            $0.width.equalTo(morningLabel)
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: BusTimetableTableViewFooterView.identifier) as? BusTimetableTableViewFooterView else { return UIView() }
        
        view.configure(updatedDate: "업데이트 날짜: \(updatedAt)")
        view.tapIncorrenctBusInfoButtonPublisher.sink { [weak self] in
            self?.tapIncorrectButtonPublisher.send()
        }.store(in: &view.subscriptions)
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
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return 66
    }
}




