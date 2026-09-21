//
//  RecruitProfilePostSecondStepView.swift
//  koin
//
//  Created by 홍기정 on 9/15/26.
//

import Combine
import SnapKit
import Then
import UIKit

final class RecruitProfilePostSecondStepView: UIScrollView {

    // MARK: - Publishers
    let preferredRoleChangedPublisher = PassthroughSubject<String?, Never>()
    let skillsChangedPublisher = PassthroughSubject<[String], Never>()
    let activitiesChangedPublisher = PassthroughSubject<[RecruitProfileActivityRequest], Never>()
    let introductionChangedPublisher = PassthroughSubject<String?, Never>()
    let didChangeHeightPublisher = PassthroughSubject<Void, Never>()

    // MARK: - Properties
    private var subscriptions = Set<AnyCancellable>()
    
    var isEditing: Bool {
        activityTableView.hasEditingRow
    }

    // MARK: - UI Components
    private let contentStackView = UIStackView()
    private let stepView = RecruitStepView(
        firstStepTitle: "기본 정보",
        secondStepTitle: "지원서 작성",
        isFirstStep: false
    )
    private let preferredRoleView = RecruitTextFieldView(
        title: "선호 역할",
        isRequired: true,
        limit: 20,
        placeholder: "선호 역할을 작성해주세요."
    )
    private let skillSectionStackView = UIStackView()
    private let skillHeaderView = RecruitSectionHeaderView(
        title: "보유기술/자격증",
        description: "기술 / 자격증은 항목별로 하나씩 작성해주세요."
    )
    private let skillTableView = RecruitProfilePostSkillTableView()
    private let activitySectionStackView = UIStackView()
    private let activityHeaderView = RecruitSectionHeaderView(
        title: "활동이력",
        description: "공모전, 대외활동, 자치단체 등 활동 이력을 작성해주세요."
    )
    private let activityTableView = RecruitProfilePostActivityTableView()
    private let introductionView = RecruitPostTextViewView(
        title: "자기소개",
        isRequired: true,
        limit: 1000,
        placeholder: "자기소개를 작성해주세요."
    )

    init() {
        super.init(frame: .zero)
        configureView()
        bind()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(_ request: RecruitProfileRequest) {
        preferredRoleView.configure(text: request.preferredRole)
        skillTableView.configure(skills: request.skills)
        activityTableView.configure(activities: request.activities)
        introductionView.configure(text: request.introduction)
    }

    func prepareDropdown(host: KoinDropdownHost) {
        activityTableView.prepareDropdown(host: host)
    }

    func applyPendingSizeChange() {
        skillTableView.applyPendingSizeChange()
        activityTableView.applyPendingSizeChange()
    }

    private func bind() {
        preferredRoleView.textChangedPublisher
            .subscribe(preferredRoleChangedPublisher)
            .store(in: &subscriptions)
        skillTableView.skillsChangedPublisher
            .subscribe(skillsChangedPublisher)
            .store(in: &subscriptions)
        activityTableView.activitiesChangedPublisher
            .subscribe(activitiesChangedPublisher)
            .store(in: &subscriptions)
        introductionView.textChangedPublisher
            .subscribe(introductionChangedPublisher)
            .store(in: &subscriptions)

        Publishers.Merge(
            skillTableView.didChangeHeightPublisher,
            activityTableView.didChangeHeightPublisher
        )
        .subscribe(didChangeHeightPublisher)
        .store(in: &subscriptions)
    }

    private func configureView() {
        backgroundColor = .appColor(.newBackground)
        showsVerticalScrollIndicator = false
        alwaysBounceVertical = true
        keyboardDismissMode = .interactive
        contentInsetAdjustmentBehavior = .never
        contentInset = UIEdgeInsets(top: 32, left: 0, bottom: 16, right: 0)

        contentStackView.do {
            $0.axis = .vertical
            $0.spacing = 24
        }
        [skillSectionStackView, activitySectionStackView].forEach {
            $0.axis = .vertical
            $0.spacing = 8
        }

        [skillHeaderView, skillTableView].forEach(skillSectionStackView.addArrangedSubview)
        [activityHeaderView, activityTableView].forEach(activitySectionStackView.addArrangedSubview)
        [stepView, preferredRoleView, skillSectionStackView,
         activitySectionStackView, introductionView].forEach(contentStackView.addArrangedSubview)
        addSubview(contentStackView)

        contentStackView.setCustomSpacing(32, after: stepView)
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
