//
//  RecruitApplySecondStepView.swift
//  koin
//
//  Created by 홍기정 on 9/27/26.
//

import Combine
import SnapKit
import Then
import UIKit

final class RecruitApplySecondStepView: UIScrollView {

    // MARK: - Publisher
    let selectedRoleChangedPublisher = PassthroughSubject<RecruitRole, Never>()
    var motivationChangedPublisher: AnyPublisher<String?, Never> {
        motivationView.textChangedPublisher.eraseToAnyPublisher()
    }
    var availableTimeChangedPublisher: AnyPublisher<String?, Never> {
        availableTimeView.textChangedPublisher.eraseToAnyPublisher()
    }

    // MARK: - Properties
    private var subscriptions = Set<AnyCancellable>()
    private let showsRoleSelection: Bool
    
    // MARK: - UI Components
    private let contentStackView = UIStackView()
    private let stepView = RecruitStepView(
        firstStepTitle: "기본 정보",
        secondStepTitle: "지원서 작성",
        isFirstStep: false
    )
    private let roleSelectionView: RecruitApplyRoleSelectionView
    private let motivationView = RecruitPostTextViewView(
        title: "지원동기",
        isRequired: true,
        limit: 1000,
        placeholder: "지원동기를 작성해주세요."
    )
    private let availableTimeView = RecruitPostTextViewView(
        title: "참여 가능 시간",
        isRequired: true,
        limit: 100,
        placeholder: "참여 가능한 시간을 작성해주세요."
    )

    // MARK: - Initializer
    init(recruit: RecruitData) {
        showsRoleSelection = recruit.type == .roleBased
        roleSelectionView = RecruitApplyRoleSelectionView(roles: recruit.roles)
        super.init(frame: .zero)
        configureView()
        bind()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension RecruitApplySecondStepView {
    private func bind() {
        roleSelectionView.selectedRoleChangedPublisher
            .subscribe(selectedRoleChangedPublisher)
            .store(in: &subscriptions)
    }
}

extension RecruitApplySecondStepView {
    private func configureView() {
        setUpStyle()
        setUpLayouts()
        setUpConstraints()
    }

    private func setUpStyle() {
        backgroundColor = .appColor(.newBackground)
        showsVerticalScrollIndicator = false
        alwaysBounceVertical = true
        keyboardDismissMode = .interactive
        contentInsetAdjustmentBehavior = .never
        contentInset = UIEdgeInsets(top: 32, left: 0, bottom: 16, right: 0)

        contentStackView.do {
            $0.axis = .vertical
            $0.spacing = 24
            $0.setCustomSpacing(32, after: stepView)
        }
        roleSelectionView.isHidden = !showsRoleSelection
    }

    private func setUpLayouts() {
        [stepView, roleSelectionView, motivationView, availableTimeView].forEach {
            contentStackView.addArrangedSubview($0)
        }
        [contentStackView].forEach {
            addSubview($0)
        }
    }

    private func setUpConstraints() {
        contentStackView.snp.makeConstraints {
            $0.top.bottom.equalTo(contentLayoutGuide)
            $0.leading.trailing.equalTo(contentLayoutGuide).inset(24)
            $0.width.equalTo(frameLayoutGuide).offset(-48)
        }
        stepView.snp.makeConstraints {
            $0.height.equalTo(52)
        }
    }
}
