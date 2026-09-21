//
//  RecruitProfilePostActivityTableView.swift
//  koin
//
//  Created by 홍기정 on 9/21/26.
//

import Combine
import UIKit

final class RecruitProfilePostActivityTableView: UITableView {
    
    private enum RowMode {
        case display
        case editing
    }
    
    private struct Row {
        var draft: RecruitProfileActivityRequest
        var committed: RecruitProfileActivityRequest?
        var mode: RowMode
    }
    
    private enum PendingSizeChange {
        case insert(IndexPath)
        case delete(IndexPath)
        case reload(IndexPath)
    }
    
    // MARK: - Properties
    let activitiesChangedPublisher = PassthroughSubject<[RecruitProfileActivityRequest], Never>()
    let didChangeHeightPublisher = PassthroughSubject<Void, Never>()
    
    private var rows: [Row] = []
    private var footerSubscriptions = Set<AnyCancellable>()
    
    private weak var dropdownHost: KoinDropdownHost?
    private var lastContentHeight: CGFloat = 0
    private var pendingSizeChange: PendingSizeChange?
    
    var hasEditingRow: Bool {
        if let _ = rows.first(where: { $0.mode == .editing }) {
            return true
        }
        return false
    }
    
    // MARK: - Initializer
    init() {
        super.init(frame: .zero, style: .plain)
        configureView()
        commonInit()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Override
    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: max(40, contentSize.height))
    }
    
    override var contentSize: CGSize {
        didSet {
            guard contentSize.height != lastContentHeight else { return }
            lastContentHeight = contentSize.height
            invalidateIntrinsicContentSize()
        }
    }
    
    // MARK: - Public
    func configure(activities: [RecruitProfileActivityRequest]) {
        rows = activities.map { Row(draft: $0, committed: $0, mode: .display) }
        pendingSizeChange = nil
        reloadData()
    }
    
    func prepareDropdown(host: KoinDropdownHost) {
        dropdownHost = host
    }
    
    func applyPendingSizeChange() {
        guard let pendingSizeChange else { return }
        self.pendingSizeChange = nil
        invalidateIntrinsicContentSize()
        performBatchUpdates {
            switch pendingSizeChange {
            case let .insert(indexPath):
                insertRows(at: [indexPath], with: .automatic)
            case let .delete(indexPath):
                deleteRows(at: [indexPath], with: .automatic)
            case let .reload(indexPath):
                reloadRows(at: [indexPath], with: .automatic)
            }
        }
    }
}

extension RecruitProfilePostActivityTableView {
    private func addActivity() {
        dropdownHost?.dismissPresented()
        let indexPath = IndexPath(row: rows.count, section: 0)
        rows.append(Row(
            draft: RecruitProfileActivityRequest(),
            committed: nil,
            mode: .editing
        ))
        pendingSizeChange = .insert(indexPath)
        didChangeHeightPublisher.send()
    }
    
    private func editActivity(at indexPath: IndexPath) {
        guard rows.indices.contains(indexPath.row),
              let committed = rows[indexPath.row].committed else { return }
        dropdownHost?.dismissPresented()
        rows[indexPath.row].draft = committed
        rows[indexPath.row].mode = .editing
        pendingSizeChange = .reload(indexPath)
        didChangeHeightPublisher.send()
    }
    
    private func completeActivity(at indexPath: IndexPath) {
        guard rows.indices.contains(indexPath.row),
              rows[indexPath.row].draft.isValid else { return }
        dropdownHost?.dismissPresented()
        rows[indexPath.row].committed = rows[indexPath.row].draft
        rows[indexPath.row].mode = .display
        pendingSizeChange = .reload(indexPath)
        didChangeHeightPublisher.send()
        
        activitiesChangedPublisher.send(rows.compactMap(\.committed))
    }
    
    private func deleteActivity(at indexPath: IndexPath) {
        guard rows.indices.contains(indexPath.row) else { return }
        dropdownHost?.dismissPresented()
        rows.remove(at: indexPath.row)
        pendingSizeChange = .delete(indexPath)
        didChangeHeightPublisher.send()
        
        activitiesChangedPublisher.send(rows.compactMap(\.committed))
    }
}

extension RecruitProfilePostActivityTableView: UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        rows.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        switch rows[indexPath.row].mode {
        case .display:
            return displayCell(for: indexPath)
        case .editing:
            return editCell(for: indexPath)
        }
    }

    func tableView(
        _ tableView: UITableView,
        viewForFooterInSection section: Int
    ) -> UIView? {
        guard let footer = dequeueReusableHeaderFooterView(
            withIdentifier: RecruitProfilePostAddTableFooterView.identifier
        ) as? RecruitProfilePostAddTableFooterView else { return nil }

        footer.configure(title: "활동이력 추가")
        footerSubscriptions.removeAll()
        footer.addButtonTappedPublisher
            .sink { [weak self] in self?.addActivity() }
            .store(in: &footerSubscriptions)
        return footer
    }

    private func displayCell(for indexPath: IndexPath) -> UITableViewCell {
        guard let cell = dequeueReusableCell(
            withIdentifier: RecruitProfilePostActivityDisplayTableViewCell.identifier,
            for: indexPath
        ) as? RecruitProfilePostActivityDisplayTableViewCell,
              let activity = rows[indexPath.row].committed else {
            return UITableViewCell()
        }
        cell.configure(activity: activity)
        cell.cellSubscriptions.removeAll()
        cell.editButtonTappedPublisher
            .sink { [weak self, weak cell] in
                guard let self, let cell, let currentIndexPath = self.indexPath(for: cell) else { return }
                editActivity(at: currentIndexPath)
            }
            .store(in: &cell.cellSubscriptions)
        cell.deleteButtonTappedPublisher
            .sink { [weak self, weak cell] in
                guard let self, let cell, let currentIndexPath = self.indexPath(for: cell) else { return }
                deleteActivity(at: currentIndexPath)
            }
            .store(in: &cell.cellSubscriptions)
        return cell
    }

    private func editCell(for indexPath: IndexPath) -> UITableViewCell {
        guard let cell = dequeueReusableCell(
            withIdentifier: RecruitProfilePostActivityEditTableViewCell.identifier,
            for: indexPath
        ) as? RecruitProfilePostActivityEditTableViewCell else {
            return UITableViewCell()
        }

        if let dropdownHost {
            cell.prepareDropdown(host: dropdownHost)
        }
        cell.configure(activity: rows[indexPath.row].draft)
        cell.cellSubscriptions.removeAll()
        cell.activityChangedPublisher
            .sink { [weak self, weak cell] activity in
                guard let self,
                      let cell,
                      let currentIndexPath = self.indexPath(for: cell),
                      rows.indices.contains(currentIndexPath.row) else { return }
                rows[currentIndexPath.row].draft = activity
            }
            .store(in: &cell.cellSubscriptions)
        cell.completeButtonTappedPublisher
            .sink { [weak self, weak cell] in
                guard let self, let cell, let currentIndexPath = self.indexPath(for: cell) else { return }
                completeActivity(at: currentIndexPath)
            }
            .store(in: &cell.cellSubscriptions)
        cell.deleteButtonTappedPublisher
            .sink { [weak self, weak cell] in
                guard let self, let cell, let currentIndexPath = self.indexPath(for: cell) else { return }
                deleteActivity(at: currentIndexPath)
            }
            .store(in: &cell.cellSubscriptions)
        return cell
    }
}

extension RecruitProfilePostActivityTableView: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        heightForFooterInSection section: Int
    ) -> CGFloat {
        40
    }
}

extension RecruitProfilePostActivityTableView {
    private func configureView() {
        backgroundColor = .clear
        separatorStyle = .none
        rowHeight = UITableView.automaticDimension
        estimatedRowHeight = 180
        sectionHeaderHeight = 0
        sectionFooterHeight = 40
        sectionHeaderTopPadding = 0
        showsVerticalScrollIndicator = false
        isScrollEnabled = false
    }
    
    private func commonInit() {
        dataSource = self
        delegate = self
        register(
            RecruitProfilePostActivityDisplayTableViewCell.self,
            forCellReuseIdentifier: RecruitProfilePostActivityDisplayTableViewCell.identifier
        )
        register(
            RecruitProfilePostActivityEditTableViewCell.self,
            forCellReuseIdentifier: RecruitProfilePostActivityEditTableViewCell.identifier
        )
        register(
            RecruitProfilePostAddTableFooterView.self,
            forHeaderFooterViewReuseIdentifier: RecruitProfilePostAddTableFooterView.identifier
        )
    }
}
