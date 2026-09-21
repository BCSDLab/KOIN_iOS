//
//  RecruitProfilePostViewController.swift
//  koin
//
//  Created by 홍기정 on 9/13/26.
//

import Combine
import SnapKit
import Then
import UIKit

final class RecruitProfilePostViewController: UIViewController {

    // MARK: - Properties
    private let viewModel: RecruitProfilePostViewModel
    private let inputSubject = PassthroughSubject<RecruitProfilePostViewModel.Input, Never>()
    private var subscriptions = Set<AnyCancellable>()
    
    private var basicInfo = BasicInfo()
    private var request = RecruitProfileRequest()
    private var isFirstStep = true

    private var titleText: String {
        switch viewModel.mode {
        case .post:
            return "팀원 모집 프로필"
        case .modify:
            return "팀원 모집 프로필 수정"
        }
    }
    private var completeButtonTitle: String {
        switch viewModel.mode {
        case .post:
            return "저장"
        case .modify:
            return "수정하기"
        }
    }
    private var completeModalTitle: String {
        switch viewModel.mode {
        case .post:
            return "프로필을 저장하시겠어요?"
        case .modify:
            return "프로필을 수정하시겠어요?"
        }
    }
    private var completeModalButtonTitle: String {
        switch viewModel.mode {
        case .post:
            return "저장하기"
        case .modify:
            return "수정하기"
        }
    }

    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private let firstPageView = UIView()
    private let secondPageView = UIView()
    private let firstStepView = RecruitProfilePostFirstStepView()
    private let secondStepView = RecruitProfilePostSecondStepView()
    private let secondStepButtonStackView = UIStackView()
    
    private let nextButton = StatefulButton(
        title: "다음",
        font: .appFont(.pretendardSemiBold, size: 15),
        enabledColor: .appColor(.new500),
        disabledColor: .appColor(.neutral400),
        enabledTextColor: .appColor(.neutral0),
        disabledTextColor: .appColor(.neutral0),
        cornerRadius: 16
    )
    private let prevButton = UIButton()
    private lazy var completeButton = StatefulButton(
        title: completeButtonTitle,
        font: .appFont(.pretendardSemiBold, size: 15),
        enabledColor: .appColor(.new500),
        disabledColor: .appColor(.neutral400),
        enabledTextColor: .appColor(.neutral0),
        disabledTextColor: .appColor(.neutral0),
        cornerRadius: 16
    )

    // MARK: - Dropdown
    private lazy var firstStepDropdownHost = KoinDropdownHost(scrollView: firstStepView)
    private lazy var secondStepDropdownHost = KoinDropdownHost(scrollView: secondStepView)
    private lazy var departmentDropdownContentView = RecruitProfilePostDepartmentDropdownView { [weak self] department in
        guard let self else { return }
        basicInfo.department = department
        firstStepView.configure(department: department)
        nextButton.updateState(isEnabled: basicInfo.isValid)
    }
    private lazy var departmentDropdown = firstStepDropdownHost.makeDropdown(
        anchor: firstStepView.departmentDropdownAnchor,
        contentView: departmentDropdownContentView,
        configuration: .init(topPadding: 12, shadow: .shadow2)
    )

    // MARK: - Initializer
    init(viewModel: RecruitProfilePostViewModel) {
        self.viewModel = viewModel
        switch viewModel.mode {
        case .post:
            self.request = RecruitProfileRequest()
        case let .modify(profile):
            self.basicInfo = profile.toBasicInfo()
            self.request = profile.toRequest()
        }
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = titleText
        configureView()
        secondStepView.prepareDropdown(host: secondStepDropdownHost)
        secondStepView.configure(request)
        completeButton.updateState(isEnabled: request.isValid)
        setAddTargets()
        bind()
        observeKeyboard()
        hideKeyboardWhenTappedAround()
        inputSubject.send(.viewDidLoad)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar(style: .newBackground)
    }
}

extension RecruitProfilePostViewController {
    private func setAddTargets() {
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        prevButton.addTarget(self, action: #selector(prevButtonTapped), for: .touchUpInside)
        completeButton.addTarget(self, action: #selector(completeButtonTapped), for: .touchUpInside)
    }

    @objc private func nextButtonTapped() {
        guard isFirstStep && basicInfo.isValid else {
            return
        }
        showSecondStep()
    }
    
    @objc private func prevButtonTapped() {
        showFirstStep()
    }
    
    @objc private func completeButtonTapped() {
        guard basicInfo.isValid && request.isValid else {
            return
        }
        let rightButtonAction = { [weak self] in
            /* do something */
        }
        let modalViewController = KoinModalViewController(
            configuration: .init(
                appearance: .new,
                content: .singleTitle(text: completeModalTitle),
                button: .buttons(
                    leftButtonTitle: "취소하기",
                    rightButtonTitle: completeModalButtonTitle,
                    rightButtonAction: rightButtonAction
                )
            )
        )
        present(modalViewController, animated: true)
    }
    
    private func showFirstStep() {
        showStep(isFirstStep: true)
    }
    
    private func showSecondStep() {
        showStep(isFirstStep: false)
    }
    
    private func showStep(isFirstStep: Bool) {
        view.endEditing(true)
        firstStepDropdownHost.dismissPresented()
        secondStepDropdownHost.dismissPresented()
        self.isFirstStep = isFirstStep
        
        view.layoutIfNeeded()
        scrollView.setContentOffset(
            CGPoint(x: isFirstStep ? 0 : scrollView.bounds.width, y: 0),
            animated: true
        )
    }
}

extension RecruitProfilePostViewController {
    private func bind() {
        viewModel.transform(with: inputSubject.eraseToAnyPublisher())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] output in
                guard let self else { return }
                switch output {
                case let .updateBasicInfo(info):
                    configureBasicInfo(info)
                case let .updateDepartments(departments):
                    departmentDropdownContentView.configure(departments: departments)
                case let .showToast(message):
                    showToastMessage(message: message, bottomInset: 72)
                }
            }
            .store(in: &subscriptions)

        firstStepView.loadInfoButtonTappedPublisher
            .sink { [weak self] in
                self?.inputSubject.send(.loadUserData)
            }
            .store(in: &subscriptions)

        firstStepView.nicknameChangedPublisher
            .sink { [weak self] nickname in
                guard let self else { return }
                basicInfo.nickname = nickname
                nextButton.updateState(isEnabled: basicInfo.isValid)
            }
            .store(in: &subscriptions)

        firstStepView.departmentButtonTappedPublisher
            .sink { [weak self] in
                guard let self else { return }
                view.endEditing(true)
                restoreFirstStepContentInsetBottom { [weak self] in
                    self?.departmentDropdown.toggle()
                }
            }
            .store(in: &subscriptions)

        firstStepView.studentNumberChangedPublisher
            .sink { [weak self] studentNumber in
                guard let self else { return }
                basicInfo.studentNumber = studentNumber
                nextButton.updateState(isEnabled: basicInfo.isValid)
            }
            .store(in: &subscriptions)

        secondStepView.preferredRoleChangedPublisher
            .sink { [weak self] preferredRole in
                guard let self else { return }
                request.preferredRole = preferredRole
                updateCompleteButtonState()
            }
            .store(in: &subscriptions)

        secondStepView.skillsChangedPublisher
            .sink { [weak self] skills in
                guard let self else { return }
                request.skills = skills
                updateCompleteButtonState()
            }
            .store(in: &subscriptions)

        secondStepView.activitiesChangedPublisher
            .sink { [weak self] activities in
                guard let self else { return }
                request.activities = activities
                updateCompleteButtonState()
            }
            .store(in: &subscriptions)

        secondStepView.introductionChangedPublisher
            .sink { [weak self] introduction in
                guard let self else { return }
                request.introduction = introduction
                updateCompleteButtonState()
            }
            .store(in: &subscriptions)

        secondStepView.didChangeHeightPublisher
            .sink { [weak self] in
                guard let self else { return }
                view.layoutIfNeeded()
                UIView.animate(
                    springDuration: 0.25,
                    options: [.beginFromCurrentState, .allowUserInteraction]
                ) {
                    self.secondStepView.applyPendingSizeChange()
                    self.view.layoutIfNeeded()
                }
            }
            .store(in: &subscriptions)
    }
}

extension RecruitProfilePostViewController {
    private func configureBasicInfo(_ basicInfo: BasicInfo) {
        self.basicInfo = basicInfo
        firstStepView.configure(basicInfo)
        nextButton.updateState(isEnabled: basicInfo.isValid)
    }

    private func updateCompleteButtonState() {
        completeButton.updateState(isEnabled: request.isValid)
    }
}

extension RecruitProfilePostViewController {
    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }
    
    private func setUpStyles() {
        view.backgroundColor = .appColor(.newBackground)
        
        scrollView.do {
            $0.isPagingEnabled = true
            $0.isScrollEnabled = false
            $0.bounces = false
            $0.showsHorizontalScrollIndicator = false
            $0.showsVerticalScrollIndicator = false
            $0.contentInsetAdjustmentBehavior = .never
        }
        stackView.do {
            $0.axis = .horizontal
            $0.alignment = .fill
            $0.distribution = .fill
            $0.spacing = 0
        }
        secondStepButtonStackView.do {
            $0.axis = .horizontal
            $0.alignment = .fill
            $0.distribution = .fillEqually
            $0.spacing = 12
        }
        prevButton.do {
            $0.setAttributedTitle(NSAttributedString(
                string: "이전",
                attributes: [
                    .font: UIFont.appFont(.pretendardSemiBold, size: 15),
                    .foregroundColor: UIColor.appColor(.new500)
                ]), for: .normal)
            $0.backgroundColor = .clear
            $0.layer.borderColor = UIColor.appColor(.new500).cgColor
            $0.layer.borderWidth = 1
            $0.layer.cornerRadius = 16
        }
    }
    
    private func setUpLayouts() {
        [firstStepView, nextButton].forEach {
            firstPageView.addSubview($0)
        }
        [prevButton, completeButton].forEach {
            secondStepButtonStackView.addArrangedSubview($0)
        }
        [secondStepView, secondStepButtonStackView].forEach {
            secondPageView.addSubview($0)
        }
        [firstPageView, secondPageView].forEach {
            stackView.addArrangedSubview($0)
        }
        scrollView.addSubview(stackView)
        view.addSubview(scrollView)
    }
    
    private func setUpConstraints() {
        stackView.snp.makeConstraints {
            $0.edges.equalTo(scrollView.contentLayoutGuide)
            $0.height.equalTo(scrollView.frameLayoutGuide)
        }
        [firstPageView, secondPageView].forEach {
            $0.snp.makeConstraints {
                $0.width.equalTo(scrollView.frameLayoutGuide)
            }
        }
        scrollView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        firstStepView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(nextButton.snp.top).offset(-16)
        }
        nextButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(32)
            $0.bottom.equalToSuperview().offset(-16)
            $0.height.equalTo(48)
        }
        secondStepView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(secondStepButtonStackView.snp.top).offset(-16)
        }
        secondStepButtonStackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(32)
            $0.bottom.equalToSuperview().offset(-16)
            $0.height.equalTo(48)
        }
    }
}

extension RecruitProfilePostViewController {
    private func observeKeyboard() {
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notification in
                guard let self else { return }
                let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
                let keyboardMinY = keyboardFrame.map { [weak self] in
                    self?.view.convert($0, from: nil).minY ?? 0
                } ?? firstStepView.convert(firstStepView.bounds, to: view).maxY
                let activeStepView: UIScrollView = isFirstStep ? firstStepView : secondStepView
                let activeStepMaxY = activeStepView.convert(activeStepView.bounds, to: view).maxY
                activeStepView.contentInset.bottom = max(16, activeStepMaxY - keyboardMinY + 16)
            }
            .store(in: &subscriptions)

        NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.restoreStepContentInsetBottom()
            }
            .store(in: &subscriptions)
    }

    private func restoreFirstStepContentInsetBottom(_ completion: (() -> Void)? = nil) {
        UIView.animate(
            springDuration: 0.1,
            options: [.beginFromCurrentState]
        ) { [weak self] in
            self?.firstStepView.contentInset.bottom = 16
        } completion: { _ in
            completion?()
        }
    }

    private func restoreStepContentInsetBottom() {
        UIView.animate(
            springDuration: 0.1,
            options: [.beginFromCurrentState]
        ) { [weak self] in
            self?.firstStepView.contentInset.bottom = 16
            self?.secondStepView.contentInset.bottom = 16
        }
    }
}
