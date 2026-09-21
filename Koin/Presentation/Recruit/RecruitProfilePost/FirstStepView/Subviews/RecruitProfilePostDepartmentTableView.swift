//
//  RecruitProfilePostDepartmentTableView.swift
//  koin
//
//  Created by 홍기정 on 9/14/26.
//

import Combine
import Then
import UIKit

final class RecruitProfilePostDepartmentTableView: UITableView {

    // MARK: - Publisher
    let departmentSelectedPublisher = PassthroughSubject<String, Never>()

    // MARK: - Properties
    private var departments: [String] = []

    // MARK: - Initializer
    init() {
        super.init(frame: .zero, style: .plain)
        configureView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public
    func configure(departments: [String]) {
        self.departments = departments
        reloadData()
        isScrollEnabled = departments.count > 5
    }
}

extension RecruitProfilePostDepartmentTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        departments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: RecruitProfilePostDepartmentTableViewCell.identifier,
            for: indexPath
        ) as? RecruitProfilePostDepartmentTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(department: departments[indexPath.row])
        return cell
    }
}

extension RecruitProfilePostDepartmentTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        departmentSelectedPublisher.send(departments[indexPath.row])
    }
}

extension RecruitProfilePostDepartmentTableView {
    private func configureView() {
        backgroundColor = .clear
        separatorStyle = .none
        rowHeight = 34
        sectionHeaderHeight = 0
        sectionFooterHeight = 0
        sectionHeaderTopPadding = 0
        contentInset = .zero
        showsVerticalScrollIndicator = false
        dataSource = self
        delegate = self
        register(
            RecruitProfilePostDepartmentTableViewCell.self,
            forCellReuseIdentifier: RecruitProfilePostDepartmentTableViewCell.identifier
        )
    }
}
