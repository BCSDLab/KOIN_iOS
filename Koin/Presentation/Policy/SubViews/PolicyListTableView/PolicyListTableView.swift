//
//  PolicyListTableView.swift
//  koin
//
//  Created by 김나훈 on 9/5/24.
//

import Combine
import UIKit

final class PolicyListTableView: UITableView, UITableViewDataSource, UITableViewDelegate {
    
    private var policyList: [String] = []
    let selectedCellPublisher = PassthroughSubject<Int, Never>()
    
    override init(frame: CGRect, style: UITableView.Style = .plain) {
        super.init(frame: frame, style: style)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        isScrollEnabled = false
        contentInset = .zero
        register(PolicyListTableViewCell.self, forCellReuseIdentifier: PolicyListTableViewCell.identifier)
        dataSource = self
        delegate = self
        separatorInset = .zero
    }
    
    func setUpPolicyList(type: PolicyType) {
        policyList = PolicyModel.shared.getPolicyTexts(for: type).enumerated().map { (index, policy) in
            "제 \(index+1)조 (\(policy.title))"
        }
        reloadData()
    }
}

extension PolicyListTableView {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return policyList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PolicyListTableViewCell.identifier, for: indexPath) as? PolicyListTableViewCell else {
            return UITableViewCell()
        }
        
        cell.configure(titleText: policyList[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedCellPublisher.send(indexPath.row)
    }
}
