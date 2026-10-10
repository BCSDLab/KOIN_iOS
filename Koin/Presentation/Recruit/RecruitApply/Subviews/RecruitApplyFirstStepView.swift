//
//  RecruitApplyFirstStepView.swift
//  koin
//
//  Created by 홍기정 on 9/27/26.
//

import Combine
import SnapKit
import Then
import UIKit

final class RecruitApplyFirstStepView: UIScrollView {

    enum Section {
        case skill
        case activity
    }

    // MARK: - Publisher
    let loadInfoButtonTappedPublisher = PassthroughSubject<Void, Never>()
    let departmentButtonTappedPublisher = PassthroughSubject<Void, Never>()
    let didChangeHeightPublisher = PassthroughSubject<(Section, Int), Never>()

    var nicknameChangedPublisher: AnyPublisher<String?, Never> {
        nicknameView.textChangedPublisher.eraseToAnyPublisher()
    }
    var studentNumberChangedPublisher: AnyPublisher<String?, Never> {
        studentNumberView.textChangedPublisher.eraseToAnyPublisher()
    }
    var skillsChangedPublisher: AnyPublisher<[String], Never> {
        skillTableView.skillsChangedPublisher.eraseToAnyPublisher()
    }
    var skillAddButtonTappedPublisher: AnyPublisher<Void, Never> {
        skillTableView.addButtonTappedPublisher.eraseToAnyPublisher()
    }
    var activityAddButtonTappedPublisher: AnyPublisher<Void, Never> {
        activityTableView.addButtonTappedPublisher.eraseToAnyPublisher()
    }
    var activityEditButtonTappedPublisher: AnyPublisher<Void, Never> {
        activityTableView.editButtonTappedPublisher.eraseToAnyPublisher()
    }
    var activityEditCompleteButtonTappedPublisher: AnyPublisher<Void, Never> {
        activityTableView.editCompleteButtonTappedPublisher.eraseToAnyPublisher()
    }
    var activitiesChangedPublisher: AnyPublisher<[RecruitProfileActivityRequest], Never> {
        activityTableView.activitiesChangedPublisher.eraseToAnyPublisher()
    }
    var introductionChangedPublisher: AnyPublisher<String?, Never> {
        introductionView.textChangedPublisher.eraseToAnyPublisher()
    }

    // MARK: - Properties
    private var subscriptions = Set<AnyCancellable>()
    
    var isEditingActivity: Bool {
        activityTableView.hasEditingRow
    }
    
    // MARK: - Dropdown
    var departmentDropdownAnchor: UIView {
        departmentButton
    }
    
    // MARK: - UI Components
    private let contentStackView = UIStackView()
    private let stepView = RecruitStepView(
        firstStepTitle: "기본 정보",
        secondStepTitle: "지원서 작성",
        isFirstStep: true
    )
    private let loadInfoStackView = UIStackView()
    private let loadInfoHeaderView: RecruitSectionHeaderView = {
        let title = NSMutableAttributedString(
            string: "코인",
            attributes: [
                .font: UIFont.appFont(.pretendardSemiBold, size: 16),
                .foregroundColor: UIColor.appColor(.new500)
            ]
        )
        title.append(NSAttributedString(
            string: " 회원정보 불러오기",
            attributes: [
                .font: UIFont.appFont(.pretendardSemiBold, size: 16),
                .foregroundColor: UIColor.appColor(.neutral800)
            ]
        ))
        return RecruitSectionHeaderView(
            attributedTitle: title,
            description: "닉네임, 학과(학부), 학번"
        )
    }()
    private let loadInfoButton = UIButton(type: .system)
    private let nicknameView = RecruitTextFieldView(
        title: "닉네임",
        isRequired: true,
        limit: 20,
        placeholder: "닉네임을 입력해주세요."
    )
    private let departmentContainerView = UIView()
    private let departmentHeaderView = RecruitPostSectionHeaderView(
        title: "학과 · 학부",
        isRequired: true
    )
    private let departmentButton = RecruitDropdownTriggerButton(
        placeholder: "학과 · 학부를 선택해주세요."
    )
    private let studentNumberView = RecruitTextFieldView(
        title: "학번",
        isRequired: true,
        limit: nil,
        placeholder: "학번을 작성해주세요.",
        keyboardType: .numberPad
    )
    private let skillSectionStackView = UIStackView()
    private let skillHeaderView = RecruitSectionHeaderView(
        title: "보유기술 / 자격증",
        description: "기술 / 자격증은 항목별로 하나씩 작성해주세요."
    )
    private let skillTableView = RecruitProfilePostSkillTableView()
    private let activitySectionStackView = UIStackView()
    private let activityHeaderView = RecruitSectionHeaderView(
        title: "활동 이력",
        description: "공모전, 대외활동, 자치단체 등 활동 이력을 작성해주세요."
    )
    private let activityTableView = RecruitProfilePostActivityTableView()
    private let introductionView = RecruitPostTextViewView(
        title: "자기소개",
        isRequired: true,
        limit: 1000,
        placeholder: "자기소개를 작성해주세요."
    )

    // MARK: - Initializer
    init() {
        super.init(frame: .zero)
        configureView()
        setAddTargets()
        bind()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public
    func configure(_ info: BasicInfo) {
        nicknameView.configure(text: info.nickname)
        departmentButton.configure(text: info.department)
        studentNumberView.configure(text: info.studentNumber)
    }

    func configure(_ profile: RecruitProfile) {
        configure(profile.toBasicInfo())
        skillTableView.configure(skills: profile.skills)
        activityTableView.configure(activities: profile.activities.map { $0.toRequest() })
        introductionView.configure(text: profile.selfIntroduction)
    }

    func configure(department: String?) {
        departmentButton.configure(text: department)
    }

    func prepareDropdown(host: KoinDropdownHost) {
        activityTableView.prepareDropdown(host: host)
    }

    func applyPendingSizeChange() {
        skillTableView.applyPendingSizeChange()
        activityTableView.applyPendingSizeChange()
    }

    func scrollBottomToVisible(of section: Section) {
        let tableView: UITableView = switch section {
        case .skill:
            skillTableView
        case .activity:
            activityTableView
        }
        let bottomRect = tableView.convert(
            CGRect(x: 0, y: tableView.bounds.maxY - 1, width: tableView.bounds.width, height: 1),
            to: self
        )
        scrollRectToVisible(bottomRect, animated: false)
    }
}

extension RecruitApplyFirstStepView {
    private func bind() {
        Publishers.Merge(
            skillTableView.didChangeHeightPublisher.map { (.skill, $0) },
            activityTableView.didChangeHeightPublisher.map { (.activity, $0) }
        )
        .subscribe(didChangeHeightPublisher)
        .store(in: &subscriptions)
    }
}

extension RecruitApplyFirstStepView {
    private func setAddTargets() {
        loadInfoButton.addTarget(self, action: #selector(loadInfoButtonTapped), for: .touchUpInside)
        departmentButton.addTarget(self, action: #selector(departmentButtonTapped), for: .touchUpInside)
    }
    
    @objc private func loadInfoButtonTapped() {
        loadInfoButtonTappedPublisher.send()
    }
    
    @objc private func departmentButtonTapped() {
        departmentButtonTappedPublisher.send()
    }
}


extension RecruitApplyFirstStepView {
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
        }
        [loadInfoStackView, skillSectionStackView, activitySectionStackView].forEach {
            $0.axis = .vertical
            $0.spacing = 8
        }
        loadInfoButton.do {
            var configuration = UIButton.Configuration.plain()
            configuration.attributedTitle = AttributedString(
                "회원정보 불러오기",
                attributes: AttributeContainer([
                    .font: UIFont.appFont(.pretendardRegular, size: 14),
                    .foregroundColor: UIColor.appColor(.new500)
                ])
            )
            $0.configuration = configuration
            $0.layer.cornerRadius = 16
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.appColor(.new500).cgColor
            $0.backgroundColor = .appColor(.neutral0)
        }
    }

    private func setUpLayouts() {
        [loadInfoHeaderView, loadInfoButton].forEach {
            loadInfoStackView.addArrangedSubview($0)
        }
        [departmentHeaderView, departmentButton].forEach {
            departmentContainerView.addSubview($0)
        }
        [skillHeaderView, skillTableView].forEach {
            skillSectionStackView.addArrangedSubview($0)
        }
        [activityHeaderView, activityTableView].forEach {
            activitySectionStackView.addArrangedSubview($0)
        }
        [stepView, loadInfoStackView, nicknameView, departmentContainerView, studentNumberView,
         skillSectionStackView, activitySectionStackView, introductionView].forEach {
            contentStackView.addArrangedSubview($0)
        }
        addSubview(contentStackView)

        contentStackView.setCustomSpacing(32, after: stepView)
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
        loadInfoButton.snp.makeConstraints {
            $0.height.equalTo(40)
        }
        departmentHeaderView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
        departmentButton.snp.makeConstraints {
            $0.top.equalTo(departmentHeaderView.snp.bottom).offset(8)
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(40)
        }
    }
}
