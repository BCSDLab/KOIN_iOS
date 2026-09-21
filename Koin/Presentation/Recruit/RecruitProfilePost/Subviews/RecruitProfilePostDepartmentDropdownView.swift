//
//  RecruitProfilePostDepartmentDropdownView.swift
//  koin
//
//  Created by 홍기정 on 9/13/26.
//

import Combine
import SnapKit
import Then
import UIKit

final class RecruitProfilePostDepartmentDropdownView: UIView, KoinDropdownContentView {

    // MARK: - Properties
    private let dismissTappedSubject = PassthroughSubject<Void, Never>()
    private var subscriptions = Set<AnyCancellable>()
    
    var dismissTappedPublisher: AnyPublisher<Void, Never> {
        dismissTappedSubject.eraseToAnyPublisher()
    }
    var height: CGFloat {
        let visibleRows = min(departments.count, 5)
        return CGFloat(visibleRows) * 34 + 6 * 2
    }

    private let onSelect: (String) -> Void
    private var departments: [String] = []
    
    // MARK: - UI Component
    private let tableView = RecruitProfilePostDepartmentTableView()

    // MARK: - Initializer
    init(
        onSelect: @escaping (String) -> Void
    ) {
        self.onSelect = onSelect
        super.init(frame: .zero)
        configureView()
        bind()
    }
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public
    func configure(departments: [String]) {
        self.departments = departments
        tableView.configure(departments: departments)
    }
}

extension RecruitProfilePostDepartmentDropdownView {
    private func bind() {
        tableView.departmentSelectedPublisher
            .sink { [weak self] department in
                guard let self else { return }
                onSelect(department)
                dismissTappedSubject.send()
            }
            .store(in: &subscriptions)
    }
}

extension RecruitProfilePostDepartmentDropdownView {
    private func configureView() {
        backgroundColor = .appColor(.neutral0)
        layer.cornerRadius = 16
        clipsToBounds = true

        addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.verticalEdges.equalToSuperview().inset(6)
        }
    }
}
