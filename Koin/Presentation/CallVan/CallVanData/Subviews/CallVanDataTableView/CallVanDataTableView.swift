//
//  CallVanDataTableView.swift
//  koin
//
//  Created by 홍기정 on 3/10/26.
//

import UIKit
import Combine

final class CallVanDataTableView: UITableView {
    
    // MARK: - Properties
    let reportButtonTappedPublisher = PassthroughSubject<Int, Never>()
    private var participants: [CallVanParticipant] = []
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - Initializer
    init() {
        super.init(frame: .zero, style: .plain)
        commonInit()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    func configure(participants: [CallVanParticipant]) {
        self.participants = participants
        reloadData()
    }
    
    func closeReportButton() {
        closeReportButton(nil)
    }
}

extension CallVanDataTableView {
    
    private func commonInit() {
        dataSource = self
        register(CallVanDataTableViewCell.self, forCellReuseIdentifier: CallVanDataTableViewCell.identifier)
        
        rowHeight = 56
        allowsSelection = false
        separatorStyle = .none
    }
}

extension CallVanDataTableView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        participants.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CallVanDataTableViewCell.identifier, for: indexPath) as? CallVanDataTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(participant: participants[indexPath.row], shoudHideSepearatorView: indexPath.row == participants.count - 1)
        cell.layer.zPosition = CGFloat(participants.count - indexPath.row)
        bind(cell)
        return cell
    }
}

extension CallVanDataTableView {
    
    private func bind(_ cell: CallVanDataTableViewCell) {
        cell.threeCircleButtonTappedPublisher.sink { [weak self, weak cell] in
            guard let self, let cell else { return }
            closeReportButton(cell)
        }.store(in: &cell.subscriptions)
        
        cell.reportButtonTappedPublisher.sink { [weak self] userId in
            self?.reportButtonTappedPublisher.send(userId)
        }.store(in: &cell.subscriptions)
    }
    
    private func closeReportButton(_ cell: CallVanDataTableViewCell?) {
        for row in 0..<participants.count {
            let indexPath = IndexPath(row: row, section: 0)
            let targetCell = cellForRow(at: indexPath) as? CallVanDataTableViewCell
            
            if targetCell != cell {
                targetCell?.closeReportButton()
            }
        }
    }
}
