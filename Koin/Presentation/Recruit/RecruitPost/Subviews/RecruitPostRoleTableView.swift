//
//  RecruitPostRoleTableView.swift
//  koin
//
//  Created by 홍기정 on 9/11/26.
//

import UIKit
import Combine

final class RecruitPostRoleTableView: UITableView {
    // MARK: - Publishers
    let nameChangedPublisher = PassthroughSubject<(index: Int, text: String, isComposing: Bool), Never>()
    let nameEditingEndedPublisher = PassthroughSubject<(index: Int, text: String), Never>()
    let addMembersTappedPublisher = PassthroughSubject<Int, Never>()
    let subtractMembersTappedPublisher = PassthroughSubject<Int, Never>()
    let deleteRoleTappedPublisher = PassthroughSubject<Int, Never>()

    // MARK: - Properties
    private var type: RecruitRoleType = .roleBased
    private var numberOfGeneralMembers: Int?
    private var rows: [RecruitRoleRequest] = [.init()]
    private var showsNameTextField = true
    private var canSubtractMembers = [false]
    private var canAddMember = true
    private var showsDeleteButton = false

    private var displayedRowCount: Int {
        type == .general ? 1 : rows.count
    }

    override var intrinsicContentSize: CGSize {
        let rows = displayedRowCount * 44
        let spacing = max(0, displayedRowCount - 1) * 8
        return CGSize(width: UIView.noIntrinsicMetric, height: CGFloat(rows + spacing))
    }

    // MARK: - Initializer
    init() {
        super.init(frame: .zero, style: .plain)
        commonInit()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public
    func configure(
        type: RecruitRoleType,
        numberOfGeneralMembers: Int?,
        rows: [RecruitRoleRequest],
        showsNameTextField: Bool,
        canSubtractMembers: [Bool],
        canAddMember: Bool,
        showsDeleteButton: Bool,
        rowChangeIndex: Int? = nil
    ) {
        let previousType = self.type
        let previousRowCount = displayedRowCount
        
        self.type = type
        self.numberOfGeneralMembers = numberOfGeneralMembers
        self.rows = rows
        self.showsNameTextField = showsNameTextField
        self.canSubtractMembers = canSubtractMembers
        self.canAddMember = canAddMember
        self.showsDeleteButton = showsDeleteButton
        
        reload(
            previousType: previousType, 
            previousRowCount: previousRowCount,
            rowChangeIndex: rowChangeIndex
        )
    }
    
    private func reload(
        previousType: RecruitRoleType,
        previousRowCount: Int,
        rowChangeIndex: Int? = nil,
    ) {
        var didChangeRoleType: Bool {
            previousType != type
        }
        var didAddRole: Bool {
            if type == .roleBased,
               let rowChangeIndex,
               displayedRowCount == previousRowCount + 1,
               rows.indices.contains(rowChangeIndex) {
                return true
            } else {
                return false
            }
        }
        var didSubtractRole: Bool {
            if type == .roleBased,
               let rowChangeIndex,
               displayedRowCount == previousRowCount - 1,
               (0..<previousRowCount).contains(rowChangeIndex) {
                return true
            } else {
                return false
            }
        }
        var didChangeContent: Bool {
            if let rowChangeIndex,
               displayedRowCount == previousRowCount,
               (0..<displayedRowCount).contains(rowChangeIndex) {
                return true
            } else {
                return false
            }
        }
        
        if previousRowCount != displayedRowCount {
            invalidateIntrinsicContentSize()
        }
        
        performBatchUpdates { [weak self] in
            guard let self else { return }
            if didAddRole {
                guard let rowChangeIndex else {
                    return
                }
                if previousRowCount == 1 {
                    reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                }
                insertRows(at: [IndexPath(row: rowChangeIndex, section: 0)], with: .automatic)
            } else if didSubtractRole && rows.count == 1 {
                reloadSections(IndexSet(integer: 0), with: .automatic)
            } else if didSubtractRole && rows.count != 1 {
                guard let rowChangeIndex else {
                    return
                }
                deleteRows(at: [IndexPath(row: rowChangeIndex, section: 0)], with: .automatic)
            } else if didChangeContent {
                guard let rowChangeIndex else {
                    return
                }
                reloadRows(at: [IndexPath(row: rowChangeIndex, section: 0)], with: .automatic)
            } else {
                reloadSections(.init(integer: 0), with: .automatic)
                
            }
        } completion: { [weak self] _ in
            guard let self else {
                return
            }
            if didAddRole || didSubtractRole || didChangeContent {
                updateVisibleMemberControls()
            }
        }
    }

    func configure(name: String, at index: Int) {
        guard rows.indices.contains(index) else { return }
        rows[index].name = name
        let indexPath = IndexPath(row: index, section: 0)
        (cellForRow(at: indexPath) as? RecruitPostRoleTableViewCell)?.configure(name: name)
    }
}

extension RecruitPostRoleTableView {
    private func updateVisibleMemberControls() {
        for indexPath in indexPathsForVisibleRows ?? [] {
            guard let cell = cellForRow(at: indexPath) as? RecruitPostRoleTableViewCell else { continue }
            switch type {
            case .general:
                cell.configure(
                    numberOfGeneralMembers: numberOfGeneralMembers,
                    canSubtractMember: canSubtractMember(at: indexPath.row),
                    canAddMember: canAddMember
                )
            case .roleBased:
                guard rows.indices.contains(indexPath.row) else { continue }
                let row = rows[indexPath.row]
                cell.configure(
                    numberOfMembers: row.maximumParticipants,
                    canSubtractMember: canSubtractMember(at: indexPath.row),
                    canAddMember: canAddMember,
                    showsDeleteButton: showsDeleteButton
                )
            }
        }
    }
}

extension RecruitPostRoleTableView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        displayedRowCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: RecruitPostRoleTableViewCell.identifier,
            for: indexPath
        ) as? RecruitPostRoleTableViewCell else {
            return UITableViewCell()
        }
        switch type {
        case .general:
            cell.configure(
                numberOfGeneralMembers: numberOfGeneralMembers,
                canSubtractMember: canSubtractMember(at: indexPath.row),
                canAddMember: canAddMember
            )
        case .roleBased:
            cell.configure(
                model: rows[indexPath.row],
                showsNameTextField: showsNameTextField,
                canSubtractMember: canSubtractMember(at: indexPath.row),
                canAddMember: canAddMember,
                showsDeleteButton: showsDeleteButton
            )
        }
        bind(cell)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        indexPath.row == displayedRowCount - 1 ? 44 : 52
    }
}

extension RecruitPostRoleTableView {
    private func bind(_ cell: RecruitPostRoleTableViewCell) {
        cell.cellSubscriptions.removeAll()
        cell.nameChangedPublisher.sink { [weak self, weak cell] value in
            guard let self, let cell,
                  let index = self.index(of: cell) else {
                return
            }
            self.nameChangedPublisher.send((index, value.text, value.isComposing))
        }.store(in: &cell.cellSubscriptions)
        
        cell.nameEditingEndedPublisher.sink { [weak self, weak cell] text in
            guard let self, let cell,
                  let index = self.index(of: cell) else {
                return
            }
            self.nameEditingEndedPublisher.send((index, text))
        }.store(in: &cell.cellSubscriptions)
        
        cell.addMembersTappedPublisher.sink { [weak self, weak cell] in
            guard let self, let cell,
                  let index = self.index(of: cell) else {
                return
            }
            self.addMembersTappedPublisher.send(index)
        }.store(in: &cell.cellSubscriptions)
        
        cell.subtractMembersTappedPublisher.sink { [weak self, weak cell] in
            guard let self, let cell,
                  let index = self.index(of: cell) else {
                return
            }
            self.subtractMembersTappedPublisher.send(index)
        }.store(in: &cell.cellSubscriptions)
        
        cell.deleteTappedPublisher.sink { [weak self, weak cell] in
            guard let self, let cell,
                  let index = self.index(of: cell) else {
                return
            }
            self.deleteRoleTappedPublisher.send(index)
        }.store(in: &cell.cellSubscriptions)
    }
    
    private func index(of cell: RecruitPostRoleTableViewCell) -> Int? {
        indexPath(for: cell)?.row
    }
    
    private func canSubtractMember(at index: Int) -> Bool {
        canSubtractMembers.indices.contains(index) && canSubtractMembers[index]
    }
}

extension RecruitPostRoleTableView {
    
    private func commonInit() {
        backgroundColor = .clear
        separatorStyle = .none
        isScrollEnabled = false
        showsVerticalScrollIndicator = false
        rowHeight = 44
        sectionHeaderHeight = 0
        sectionFooterHeight = 0
        dataSource = self
        delegate = self
        register(RecruitPostRoleTableViewCell.self, forCellReuseIdentifier: RecruitPostRoleTableViewCell.identifier)
    }
}
