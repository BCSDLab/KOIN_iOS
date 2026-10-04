//
//  RecruitApplyViewController.swift
//  koin
//
//  Created by 홍기정 on 9/27/26.
//

import Combine
import SnapKit
import Then
import UIKit

protocol RecruitApplyViewControllerDelegate: AnyObject {
    func didApply()
}

final class RecruitApplyViewController: UIViewController {

    // MARK: - Properties
    private weak var delegate: RecruitApplyViewControllerDelegate?
    private let viewModel: RecruitApplyViewModel
    private let inputSubject = PassthroughSubject<RecruitApplyViewModel.Input, Never>()
    private var subscriptions = Set<AnyCancellable>()

    private let recruit: RecruitData
    private var basicInfo = BasicInfo()
    private var profileRequest = RecruitProfileRequest()
    private var applyRequest = RecruitApplyRequest()
    private var isFirstStep = true

    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    
    private let firstPageView = UIView()
    private let secondPageView = UIView()
    private let firstStepView = RecruitApplyFirstStepView()
    private let secondStepView: RecruitApplySecondStepView
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
    private let applyButton = StatefulButton(
        title: "지원하기",
        font: .appFont(.pretendardSemiBold, size: 15),
        enabledColor: .appColor(.new500),
        disabledColor: .appColor(.neutral400),
        enabledTextColor: .appColor(.neutral0),
        disabledTextColor: .appColor(.neutral0),
        cornerRadius: 16
    )
    private let previousButton = UIButton()

    // MARK: - Dropdown
    private lazy var dropdownHost = KoinDropdownHost(scrollView: firstStepView)
    private lazy var departmentDropdownContentView = RecruitProfilePostDepartmentDropdownView { [weak self] department in
        guard let self else { return }
        basicInfo.department = department
        firstStepView.configure(department: department)
        updateNextButtonState()
    }
    private lazy var departmentDropdown = dropdownHost.makeDropdown(
        anchor: firstStepView.departmentDropdownAnchor,
        contentView: departmentDropdownContentView,
        configuration: .init(topPadding: 12, shadow: .shadow2)
    )

    // MARK: - Initializer
    init(
        viewModel: RecruitApplyViewModel,
        recruit: RecruitData,
        delegate: RecruitApplyViewControllerDelegate?
    ) {
        self.viewModel = viewModel
        self.delegate = delegate
        self.recruit = recruit
        self.secondStepView = RecruitApplySecondStepView(recruit: recruit)
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "팀원 모집 지원"
        configureView()
        firstStepView.prepareDropdown(host: dropdownHost)
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

extension RecruitApplyViewController {
    private func bind() {
        viewModel.transform(with: inputSubject.eraseToAnyPublisher())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] output in
                switch output {
                case let .updateRecruitProfile(profile):
                    self?.updateRecruitProfile(profile)
                    self?.firstStepView.configure(profile)
                    self?.updateNextButtonState()
                case let .updateDepartments(departments):
                    self?.departmentDropdownContentView.configure(departments: departments)
                case .applyCompleted:
                    self?.handleApplyCompleted()
                case let .showToast(message):
                    self?.showToastMessage(message: message, bottomInset: 72)
                }
            }
            .store(in: &subscriptions)

        firstStepView.loadInfoButtonTappedPublisher
            .sink { [weak self] in self?.inputSubject.send(.loadRecruitProfile) }
            .store(in: &subscriptions)
        firstStepView.nicknameChangedPublisher
            .sink { [weak self] value in
                self?.basicInfo.nickname = value
                self?.profileRequest.nickname = value
                self?.updateNextButtonState()
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
            .sink { [weak self] value in self?.basicInfo.studentNumber = value
                self?.updateNextButtonState()
            }
            .store(in: &subscriptions)
        firstStepView.skillsChangedPublisher
            .sink { [weak self] value in self?.profileRequest.skills = value
                self?.updateNextButtonState()
            }
            .store(in: &subscriptions)
        firstStepView.activitiesChangedPublisher
            .sink { [weak self] value in
                self?.profileRequest.activities = value
                self?.updateNextButtonState()
            }
            .store(in: &subscriptions)
        firstStepView.introductionChangedPublisher
            .sink { [weak self] value in
                self?.profileRequest.introduction = value
                self?.updateNextButtonState()
            }
            .store(in: &subscriptions)
        firstStepView.didChangeHeightPublisher
            .sink { [weak self] in
                guard let self else { return }
                view.layoutIfNeeded()
                UIView.animate(
                    springDuration: 0.25,
                    options: [.beginFromCurrentState, .allowUserInteraction]
                ) {
                    self.firstStepView.applyPendingSizeChange()
                    self.updateNextButtonState()
                    self.view.layoutIfNeeded()
                }
            }
            .store(in: &subscriptions)

        secondStepView.selectedRoleChangedPublisher
            .sink { [weak self] value
                in self?.applyRequest.selectedRole = value
                self?.updateApplyButtonState()
            }
            .store(in: &subscriptions)
        secondStepView.motivationChangedPublisher
            .sink { [weak self] value in
                self?.applyRequest.motivation = value
                self?.updateApplyButtonState()
            }
            .store(in: &subscriptions)
        secondStepView.availableTimeChangedPublisher
            .sink { [weak self] value in
                self?.applyRequest.availableTime = value
                self?.updateApplyButtonState()
            }
            .store(in: &subscriptions)
    }
}

extension RecruitApplyViewController {
    private func setAddTargets() {
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        previousButton.addTarget(self, action: #selector(previousButtonTapped), for: .touchUpInside)
        applyButton.addTarget(self, action: #selector(applyButtonTapped), for: .touchUpInside)
    }

    @objc private func nextButtonTapped() {
        guard isFirstStepValid, !firstStepView.isEditingActivity else { return }
        isFirstStep = false
        view.endEditing(true)
        dropdownHost.dismissPresented()
        view.layoutIfNeeded()
        scrollView.setContentOffset(CGPoint(x: scrollView.bounds.width, y: 0), animated: true)
    }

    @objc private func previousButtonTapped() {
        isFirstStep = true
        view.endEditing(true)
        dropdownHost.dismissPresented()
        view.layoutIfNeeded()
        scrollView.setContentOffset(.zero, animated: true)
    }

    @objc private func applyButtonTapped() {
        guard isSecondStepValid else { return }
        let apply = { [weak self] in
            guard let self else { return }
            inputSubject.send(.apply(
                recruitmentId: recruit.id,
                basicInfo: basicInfo,
                profileRequest: profileRequest,
                applyRequest: applyRequest
            ))
        }
        let modalViewController = KoinModalViewController(configuration: .init(
            appearance: .new,
            content: .singleTitle(text: "해당 팀원 모집에 지원하시겠어요?"),
            button: .buttons(
                leftButtonTitle: "취소하기",
                rightButtonTitle: "지원하기",
                rightButtonAction: apply
            )
        ))
        present(modalViewController, animated: true)
    }

    private func handleApplyCompleted() {
        delegate?.didApply()
        navigationController?.popViewController(animated: true)
    }
}

extension RecruitApplyViewController {
    private func observeKeyboard() {
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notification in
                guard let self else { return }
                let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
                let keyboardMinY = keyboardFrame.map { self.view.convert($0, from: nil).minY }
                    ?? firstStepView.convert(firstStepView.bounds, to: view).maxY
                let activeView: UIScrollView = isFirstStep ? firstStepView : secondStepView
                let activeMaxY = activeView.convert(activeView.bounds, to: view).maxY
                let bottomInset = max(16, activeMaxY - keyboardMinY + 16)
                let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0.25
                let curveValue = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt
                    ?? UInt(UIView.AnimationCurve.easeInOut.rawValue)
                let options = UIView.AnimationOptions(rawValue: curveValue << 16)

                UIView.animate(
                    withDuration: duration,
                    delay: 0,
                    options: [.beginFromCurrentState, options]
                ) {
                    activeView.contentInset.bottom = bottomInset
                    activeView.verticalScrollIndicatorInsets.bottom = bottomInset
                } completion: { [weak self, weak activeView] _ in
                    guard let self, let activeView else { return }
                    scrollFirstResponderToVisible(in: activeView)
                }
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
            self?.firstStepView.verticalScrollIndicatorInsets.bottom = 16
            self?.secondStepView.verticalScrollIndicatorInsets.bottom = 16
        }
    }

    private func scrollFirstResponderToVisible(in scrollView: UIScrollView) {
        guard let firstResponder = findFirstResponder(in: scrollView) else { return }
        var rect = firstResponder.convert(firstResponder.bounds, to: scrollView)
        rect.size.height += 16
        scrollView.scrollRectToVisible(rect, animated: true)
    }

    private func findFirstResponder(in view: UIView) -> UIView? {
        if view.isFirstResponder {
            return view
        }
        for subview in view.subviews {
            if let firstResponder = findFirstResponder(in: subview) {
                return firstResponder
            }
        }
        return nil
    }
}

extension RecruitApplyViewController {
    private func updateRecruitProfile(_ profile: RecruitProfile) {
        basicInfo = profile.toBasicInfo()
        profileRequest = profile.toRequest()
    }
}

extension RecruitApplyViewController {
    private var isFirstStepValid: Bool {
        basicInfo.isValid && profileRequest.isValid
    }

    private var isSecondStepValid: Bool {
        applyRequest.isValid(for: recruit.type)
    }

    private func updateNextButtonState() {
        nextButton.updateState(
            isEnabled: isFirstStepValid && !firstStepView.isEditingActivity
        )
    }

    private func updateApplyButtonState() {
        applyButton.updateState(isEnabled: isSecondStepValid)
    }
}

extension RecruitApplyViewController {
    private func configureView() {
        setUpStyle()
        setUpLayouts()
        setUpConstraints()
    }

    private func setUpStyle() {
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
        previousButton.do {
            $0.setAttributedTitle(NSAttributedString(
                string: "이전",
                attributes: [
                    .font: UIFont.appFont(.pretendardSemiBold, size: 15),
                    .foregroundColor: UIColor.appColor(.new500)
                ]
            ), for: .normal)
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
        [previousButton, applyButton].forEach {
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
            $0.snp.makeConstraints { $0.width.equalTo(scrollView.frameLayoutGuide) }
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
