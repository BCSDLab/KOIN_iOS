//
//  RecruitProfilePostSkillTableView.swift
//  koin
//
//  Created by 홍기정 on 9/21/26.
//

import Combine
import UIKit

final class RecruitProfilePostSkillTableView: UITableView {
    
    private enum PendingSizeChange {
        case insert(IndexPath)
        case delete(IndexPath)
    }
    
    // MARK: - Properties
    let skillsChangedPublisher = PassthroughSubject<[String], Never>()
    let didChangeHeightPublisher = PassthroughSubject<Void, Never>()
    
    private var skills: [String] = []
    private var footerSubscriptions = Set<AnyCancellable>()
    private var pendingSizeChange: PendingSizeChange?
    
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
        CGSize(width: UIView.noIntrinsicMetric, height: CGFloat(skills.count * 48 + 40))
    }
    
    // MARK: - Public
    func configure(skills: [String]) {
        self.skills = skills
        pendingSizeChange = nil
        invalidateIntrinsicContentSize()
        reloadData()
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
            }
        }
    }
}

extension RecruitProfilePostSkillTableView {
    private func addSkill() {
        let indexPath = IndexPath(row: skills.count, section: 0)
        skills.append("")
        pendingSizeChange = .insert(indexPath)
        didChangeHeightPublisher.send()
        skillsChangedPublisher.send(skills)
    }
    
    private func deleteSkill(at indexPath: IndexPath) {
        guard skills.indices.contains(indexPath.row) else { return }
        skills.remove(at: indexPath.row)
        pendingSizeChange = .delete(indexPath)
        didChangeHeightPublisher.send()
        skillsChangedPublisher.send(skills)
    }
}

extension RecruitProfilePostSkillTableView: UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        skills.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let cell = dequeueReusableCell(
            withIdentifier: RecruitProfilePostSkillTableViewCell.identifier,
            for: indexPath
        ) as? RecruitProfilePostSkillTableViewCell else {
            return UITableViewCell()
        }

        cell.configure(text: skills[indexPath.row])
        cell.cellSubscriptions.removeAll()
        cell.textChangedPublisher
            .sink { [weak self, weak cell] text in
                guard let self,
                      let cell,
                      let currentIndexPath = self.indexPath(for: cell),
                      skills.indices.contains(currentIndexPath.row) else { return }
                skills[currentIndexPath.row] = text
                skillsChangedPublisher.send(skills)
            }
            .store(in: &cell.cellSubscriptions)
        cell.deleteButtonTappedPublisher
            .sink { [weak self, weak cell] in
                guard let self,
                      let cell,
                      let currentIndexPath = self.indexPath(for: cell) else { return }
                deleteSkill(at: currentIndexPath)
            }
            .store(in: &cell.cellSubscriptions)
        return cell
    }

    func tableView(
        _ tableView: UITableView,
        viewForFooterInSection section: Int
    ) -> UIView? {
        guard let footer = dequeueReusableHeaderFooterView(
            withIdentifier: RecruitProfilePostAddTableFooterView.identifier
        ) as? RecruitProfilePostAddTableFooterView else { return nil }

        footer.configure(title: "보유기술/자격증 추가")
        footerSubscriptions.removeAll()
        footer.addButtonTappedPublisher
            .sink { [weak self] in self?.addSkill() }
            .store(in: &footerSubscriptions)
        return footer
    }
}

extension RecruitProfilePostSkillTableView: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        heightForFooterInSection section: Int
    ) -> CGFloat {
        40
    }
}

extension RecruitProfilePostSkillTableView {
    private func configureView() {
        backgroundColor = .clear
        separatorStyle = .none
        rowHeight = 48
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
            RecruitProfilePostSkillTableViewCell.self,
            forCellReuseIdentifier: RecruitProfilePostSkillTableViewCell.identifier
        )
        register(
            RecruitProfilePostAddTableFooterView.self,
            forHeaderFooterViewReuseIdentifier: RecruitProfilePostAddTableFooterView.identifier
        )
    }
}
