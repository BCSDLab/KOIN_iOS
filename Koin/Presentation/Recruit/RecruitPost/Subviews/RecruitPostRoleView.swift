//
//  RecruitPostRoleView.swift
//  koin
//
//  Created by 홍기정 on 8/30/26.
//

import UIKit
import Combine
import SnapKit
import Then

final class RecruitPostRoleView: UIView {
    // MARK: - Publishers
    let roleTypeChangedPublisher = PassthroughSubject<RecruitRoleType, Never>()
    let rolesChangedPublisher = PassthroughSubject<[RecruitRoleRequest], Never>()
    let numberOfGeneralMembersChangedPublisher = PassthroughSubject<Int?, Never>()
    let didChangeHeightPublisher = PassthroughSubject<Void, Never>()

    // MARK: - Properties
    private var subscriptions: Set<AnyCancellable> = []
    private var roleType: RecruitRoleType
    private var roles: [RecruitRoleRequest]
    private var numberOfGeneralMembers: Int
    private var pendingRowChangeIndex: Int? = nil

    private let minimumNumberOfMembers = 1
    private let maximumNumberOfRoles = 5
    private let maximumRoleNameLength = 10
    private let maximumNumberOfMembers = 10

    // MARK: - UI Components
    private let headerView = RecruitPostSectionHeaderView(title: "모집 인원 및 역할", isRequired: true)
    private let descriptionLabel = UILabel()
    private let addRoleButton = UIButton()
    private let changeRoleTypeButton = UIButton()
    private let tableView = RecruitPostRoleTableView()

    // MARK: - Initializer
    init(
        roleType: RecruitRoleType = .roleBased,
        roles: [RecruitRoleRequest] = [.init()],
        numberOfGeneralMembers: Int = 1
    ) {
        self.roleType = roleType
        self.roles = roles.isEmpty && roleType == .roleBased ? [.init()] : roles
        self.numberOfGeneralMembers = numberOfGeneralMembers
        super.init(frame: .zero)
        configureView()
        setAddTargets()
        bindTableView()
        updateViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public
    func configure(
        roleType: RecruitRoleType,
        roles: [RecruitRoleRequest],
        numberOfGeneralMembers: Int?
    ) {
        self.roleType = roleType
        self.roles = roles.isEmpty && roleType == .roleBased ? [.init()] : roles
        self.numberOfGeneralMembers = numberOfGeneralMembers ?? minimumNumberOfMembers
        pendingRowChangeIndex = nil
        updateViews()
    }

    func applyPendingSizeChange() {
        let rowChangeIndex = pendingRowChangeIndex
        pendingRowChangeIndex = nil
        updateViews(rowChangeIndex: rowChangeIndex)
    }
}

extension RecruitPostRoleView {
    private func setAddTargets() {
        addRoleButton.addTarget(self, action: #selector(addRoleButtonTapped), for: .touchUpInside)
        changeRoleTypeButton.addTarget(self, action: #selector(changeRoleTypeButtonTapped), for: .touchUpInside)
    }

    private func bindTableView() {
        tableView.nameChangedPublisher.sink { [weak self] value in
            self?.updateRoleName(at: value.index, text: value.text, trimWhitespace: false, isComposing: value.isComposing)
        }.store(in: &subscriptions)

        tableView.nameEditingEndedPublisher.sink { [weak self] value in
            self?.updateRoleName(at: value.index, text: value.text, trimWhitespace: true, isComposing: false)
        }.store(in: &subscriptions)

        tableView.addMembersTappedPublisher.sink { [weak self] index in
            self?.changeNumberOfMembers(at: index, by: 1)
        }.store(in: &subscriptions)

        tableView.subtractMembersTappedPublisher.sink { [weak self] index in
            self?.changeNumberOfMembers(at: index, by: -1)
        }.store(in: &subscriptions)

        tableView.deleteRoleTappedPublisher.sink { [weak self] index in
            self?.deleteRole(at: index)
        }.store(in: &subscriptions)
    }

    @objc private func addRoleButtonTapped() {
        guard roleType == .roleBased,
              roles.count < maximumNumberOfRoles,
              totalRoleMembers < maximumNumberOfMembers else { return }
        tableView.endEditing(true)
        roles.append(.init())
        pendingRowChangeIndex = roles.count - 1
        didChangeHeightPublisher.send()
        rolesChangedPublisher.send(roles)
    }

    @objc private func changeRoleTypeButtonTapped() {
        tableView.endEditing(true)
        pendingRowChangeIndex = nil
        let previousRowCount = displayedRowCount
        switch roleType {
        case .roleBased:
            roleType = .general
            roles = []
            numberOfGeneralMembers = minimumNumberOfMembers
            if previousRowCount != displayedRowCount {
                didChangeHeightPublisher.send()
            } else {
                updateViews()
            }
            roleTypeChangedPublisher.send(roleType)
            rolesChangedPublisher.send(roles)
            numberOfGeneralMembersChangedPublisher.send(numberOfGeneralMembers)
        case .general:
            roleType = .roleBased
            roles = [.init()]
            numberOfGeneralMembers = minimumNumberOfMembers
            if previousRowCount != displayedRowCount {
                didChangeHeightPublisher.send()
            } else {
                updateViews()
            }
            roleTypeChangedPublisher.send(roleType)
            rolesChangedPublisher.send(roles)
            numberOfGeneralMembersChangedPublisher.send(nil)
        }
    }

    private func updateRoleName(at index: Int, text: String, trimWhitespace: Bool, isComposing: Bool) {
        guard roleType == .roleBased, roles.indices.contains(index), !isComposing else { return }
        let input = trimWhitespace ? text.trimmingCharacters(in: .whitespacesAndNewlines) : text
        let name = String(input.prefix(maximumRoleNameLength))
        tableView.configure(name: name, at: index)
        guard roles[index].name != name else { return }
        roles[index].name = name
        rolesChangedPublisher.send(roles)
    }

    private func changeNumberOfMembers(at index: Int, by amount: Int) {
        switch roleType {
        case .general:
            guard index == 0 else { return }
            let next = numberOfGeneralMembers + amount
            guard (minimumNumberOfMembers...maximumNumberOfMembers).contains(next) else { return }
            numberOfGeneralMembers = next
            updateViews(rowChangeIndex: index)
            numberOfGeneralMembersChangedPublisher.send(next)
        case .roleBased:
            guard roles.indices.contains(index) else { return }
            let next = roles[index].maximumParticipants + amount
            guard next >= minimumNumberOfMembers,
                  totalRoleMembers + amount <= maximumNumberOfMembers else { return }
            roles[index].maximumParticipants = next
            updateViews(rowChangeIndex: index)
            rolesChangedPublisher.send(roles)
        }
    }

    private func deleteRole(at index: Int) {
        guard roleType == .roleBased, roles.count > 1, roles.indices.contains(index) else { return }
        tableView.endEditing(true)
        roles.remove(at: index)
        pendingRowChangeIndex = index
        didChangeHeightPublisher.send()
        rolesChangedPublisher.send(roles)
    }
}

extension RecruitPostRoleView {
    private var displayedRowCount: Int {
        roleType == .general ? 1 : roles.count
    }

    private var totalRoleMembers: Int {
        roles.reduce(0) { $0 + $1.maximumParticipants }
    }

    private func updateViews(rowChangeIndex: Int? = nil) {
        addRoleButton.isHidden = roleType == .general
        addRoleButton.isEnabled = roleType == .roleBased
            && roles.count < maximumNumberOfRoles
            && totalRoleMembers < maximumNumberOfMembers
        changeRoleTypeButton.isSelected = roleType == .general

        switch roleType {
        case .general:
            tableView.configure(
                type: roleType,
                numberOfGeneralMembers: numberOfGeneralMembers,
                rows: [],
                showsNameTextField: false,
                canSubtractMembers: [numberOfGeneralMembers > minimumNumberOfMembers],
                canAddMember: numberOfGeneralMembers < maximumNumberOfMembers,
                showsDeleteButton: false,
                rowChangeIndex: rowChangeIndex
            )
        case .roleBased:
            tableView.configure(
                type: roleType,
                numberOfGeneralMembers: nil,
                rows: roles,
                showsNameTextField: true,
                canSubtractMembers: roles.map { $0.maximumParticipants > minimumNumberOfMembers },
                canAddMember: totalRoleMembers < maximumNumberOfMembers,
                showsDeleteButton: roles.count > 1,
                rowChangeIndex: rowChangeIndex
            )
        }
    }
}

extension RecruitPostRoleView {
    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }

    private func setUpStyles() {
        descriptionLabel.do {
            $0.text = "역할을 추가하고 필요한 인원을 선택해주세요"
            $0.font = .appFont(.pretendardRegular, size: 12)
            $0.textColor = .appColor(.neutral500)
        }

        addRoleButton.do {
            var configuration = UIButton.Configuration.plain()
            configuration.attributedTitle = AttributedString(
                "역할 추가",
                attributes: AttributeContainer([
                    .font: UIFont.appFont(.pretendardRegular, size: 12),
                    .foregroundColor: UIColor.appColor(.neutral0)
                ])
            )
            configuration.image = UIImage.appImage(asset: .addThin)?
                .withTintColor(.appColor(.neutral0), renderingMode: .alwaysOriginal)
            configuration.imagePadding = 4
            configuration.background.cornerRadius = 15.5
            configuration.contentInsets = .init(top: 0, leading: 12, bottom: 0, trailing: 12)
            $0.configuration = configuration
            $0.configurationUpdateHandler = { button in
                var configuration = button.configuration
                configuration?.background.backgroundColor = button.isEnabled
                    ? .appColor(.new500) : .appColor(.neutral300)
                button.configuration = configuration
            }
        }

        changeRoleTypeButton.do {
            var configuration = UIButton.Configuration.plain()
            configuration.attributedTitle = AttributedString(
                "역할 구분 없이 모집하기",
                attributes: AttributeContainer([
                    .font: UIFont.appFont(.pretendardRegular, size: 12),
                    .foregroundColor: UIColor.appColor(.neutral500)
                ])
            )
            configuration.imagePlacement = .leading
            configuration.imagePadding = 4
            configuration.contentInsets = .zero
            configuration.automaticallyUpdateForSelection = false
            configuration.background.backgroundColor = .clear
            configuration.baseBackgroundColor = nil
            $0.configuration = configuration
            $0.contentHorizontalAlignment = .leading
            $0.configurationUpdateHandler = { button in
                let asset: ImageAsset = button.isSelected ? .circleCheckedPrimary500 : .circlePrimary500
                var configuration = button.configuration
                configuration?.image = UIImage.appImage(asset: asset)?
                    .withTintColor(.appColor(.new500), renderingMode: .alwaysOriginal)
                button.configuration = configuration
            }
        }
    }

    private func setUpLayouts() {
        [headerView, descriptionLabel, addRoleButton, changeRoleTypeButton, tableView].forEach {
            addSubview($0)
        }
    }

    private func setUpConstraints() {
        headerView.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
            $0.trailing.lessThanOrEqualTo(addRoleButton.snp.leading).offset(-8)
        }
        addRoleButton.snp.makeConstraints {
            $0.top.trailing.equalToSuperview()
            $0.height.equalTo(31)
        }
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom)
            $0.leading.equalToSuperview()
            $0.height.equalTo(19)
        }
        changeRoleTypeButton.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(24)
        }
        tableView.snp.makeConstraints {
            $0.top.equalTo(changeRoleTypeButton.snp.bottom).offset(8)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
}
