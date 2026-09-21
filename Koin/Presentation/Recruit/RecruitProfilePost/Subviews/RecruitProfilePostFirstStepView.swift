//
//  RecruitProfilePostFirstStepView.swift
//  koin
//
//  Created by 홍기정 on 9/15/26.
//

import Combine
import SnapKit
import Then
import UIKit

final class RecruitProfilePostFirstStepView: UIScrollView {

    // MARK: - Publishers
    let loadInfoButtonTappedPublisher = PassthroughSubject<Void, Never>()
    let departmentButtonTappedPublisher = PassthroughSubject<Void, Never>()
    var nicknameChangedPublisher: AnyPublisher<String?, Never> {
        nicknameView.textChangedPublisher.eraseToAnyPublisher()
    }
    var studentNumberChangedPublisher: AnyPublisher<String?, Never> {
        studentNumberView.textChangedPublisher.eraseToAnyPublisher()
    }
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
        limit: 10,
        placeholder: "학번을 작성해주세요.",
        keyboardType: .numberPad
    )

    // MARK: - Initializer
    init() {
        super.init(frame: .zero)
        configureView()
        setAddTargets()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public
    func configure(_ info: BasicInfo) {
        nicknameView.configure(text: info.nickname)
        departmentButton.configure(text: info.department)
        studentNumberView.configure(text: info.studentNumber)
    }

    func configure(department: String?) {
        departmentButton.configure(text: department)
    }
}

extension RecruitProfilePostFirstStepView {
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

extension RecruitProfilePostFirstStepView {
    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }

    private func setUpStyles() {
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
        loadInfoStackView.do {
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
        }
        configure(department: nil)
    }

    private func setUpLayouts() {
        [loadInfoHeaderView, loadInfoButton].forEach {
            loadInfoStackView.addArrangedSubview($0)
        }
        [departmentHeaderView, departmentButton].forEach {
            departmentContainerView.addSubview($0)
        }
        [stepView, loadInfoStackView, nicknameView, departmentContainerView, studentNumberView].forEach {
            contentStackView.addArrangedSubview($0)
        }
        addSubview(contentStackView)
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
