//
//  RecruitApplyRoleSelectionView.swift
//  koin
//
//  Created by 홍기정 on 9/27/26.
//

import Combine
import SnapKit
import Then
import UIKit

final class RecruitApplyRoleSelectionView: UIView {

    // MARK: - Publisher
    let selectedRoleChangedPublisher = PassthroughSubject<RecruitRole, Never>()

    // MARK: - Properties
    private let roles: [RecruitRole]
    private var selectedRoleId: Int?
    
    // MARK: - UI Components
    private let stackView = UIStackView()
    private let headerView = RecruitPostSectionHeaderView(
        title: "지원 역할 선택",
        isRequired: true
    )
    private var roleButtons: [RecruitApplyRoleButton] = []

    init(roles: [RecruitRole]) {
        self.roles = roles
        super.init(frame: .zero)
        configureView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension RecruitApplyRoleSelectionView {
    private func configureView() {
        setUpStyle()
        setUpLayouts()
        setUpConstraints()
    }

    private func setUpStyle() {
        stackView.do {
            $0.axis = .vertical
            $0.spacing = 8
        }
    }

    private func setUpLayouts() {
        addSubview(stackView)
        stackView.addArrangedSubview(headerView)

        roleButtons = roles.enumerated().map { index, role in
            let button = RecruitApplyRoleButton(role: role)
            button.tag = index
            button.addTarget(self, action: #selector(roleButtonTapped(_:)), for: .touchUpInside)
            stackView.addArrangedSubview(button)
            return button
        }
    }

    private func setUpConstraints() {
        roleButtons.forEach { button in
            button.snp.makeConstraints { $0.height.equalTo(40) }
        }
        stackView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }

    @objc private func roleButtonTapped(_ sender: RecruitApplyRoleButton) {
        guard roles.indices.contains(sender.tag), !roles[sender.tag].isClosed else { return }
        selectedRoleId = roles[sender.tag].id
        for (index, button) in roleButtons.enumerated() {
            button.setSelected(roles[index].id == selectedRoleId)
        }
        selectedRoleChangedPublisher.send(roles[sender.tag])
        UISelectionFeedbackGenerator().selectionChanged()
    }
}

private final class RecruitApplyRoleButton: UIButton {

    private let recruitRole: RecruitRole
    private let radioView = UIView()
    private let radioDotView = UIView()
    private let roleLabel = UILabel()
    private let closedLabel = UILabel()

    init(role: RecruitRole) {
        self.recruitRole = role
        super.init(frame: .zero)
        configureView()
        setSelected(false)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setSelected(_ isSelected: Bool) {
        radioDotView.isHidden = !isSelected
    }
}

extension RecruitApplyRoleButton {
    private func configureView() {
        setUpStyle()
        setUpLayouts()
        setUpConstraints()
    }

    private func setUpStyle() {
        backgroundColor = .appColor(recruitRole.isClosed ? .neutral200 : .neutral0)
        layer.cornerRadius = 16
        isEnabled = !recruitRole.isClosed

        radioView.do {
            $0.backgroundColor = .clear
            $0.layer.cornerRadius = 10
            $0.layer.borderWidth = 1.5
            $0.layer.borderColor = UIColor.appColor(.neutral400).cgColor
            $0.isUserInteractionEnabled = false
        }
        radioDotView.do {
            $0.backgroundColor = .appColor(.new500)
            $0.layer.cornerRadius = 5
            $0.isUserInteractionEnabled = false
        }
        roleLabel.do {
            $0.text = recruitRole.name
            $0.font = .appFont(.pretendardRegular, size: 14)
            $0.textColor = .appColor(recruitRole.isClosed ? .neutral500 : .neutral800)
            $0.isUserInteractionEnabled = false
        }
        closedLabel.do {
            $0.text = recruitRole.isClosed ? "모집 마감" : nil
            $0.font = .appFont(.pretendardRegular, size: 14)
            $0.textColor = .appColor(.neutral600)
            $0.isHidden = !recruitRole.isClosed
            $0.isUserInteractionEnabled = false
        }
    }

    private func setUpLayouts() {
        [radioView, roleLabel, closedLabel].forEach {
            addSubview($0)
        }
        radioView.addSubview(radioDotView)
    }

    private func setUpConstraints() {
        radioView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(20)
        }
        radioDotView.snp.makeConstraints { $0.center.equalToSuperview(); $0.size.equalTo(10) }
        roleLabel.snp.makeConstraints {
            $0.leading.equalTo(radioView.snp.trailing).offset(12)
            $0.centerY.equalToSuperview()
        }
        closedLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalToSuperview()
        }
    }
}
