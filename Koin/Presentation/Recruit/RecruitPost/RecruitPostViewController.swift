//
//  RecruitPostViewController.swift
//  koin
//
//  Created by 홍기정 on 8/30/26.
//

import UIKit
import Combine
import SnapKit
import Then

final class RecruitPostViewController: UIViewController {
    
    private var navigationTitle: String {
        switch viewModel.mode {
        case .post:
            return "모집글 작성"
        case .modify:
            return "모집글 수정"
        }
    }
    private var submitButtonTitle: String {
        switch viewModel.mode {
        case .post:
            return "등록하기"
        case .modify:
            return "수정하기"
        }
    }
    private var submitModalMessage: String {
        switch viewModel.mode {
        case .post:
            return "해당 모집글을 등록하시겠습니까?"
        case .modify:
            return "해당 모집글을 수정하시겠습니까?"
        }
    }
    private var submitLogValue: String {
        switch viewModel.mode {
        case .post:
            return "등록하기"
        case .modify:
            return "수정 완료"
        }
    }
    private var completionMessage: String {
        switch viewModel.mode {
        case .post:
            return "모집글이 등록되었습니다."
        case .modify:
            return "모집글이 수정되었습니다."
        }
    }
    
    // MARK: - Properties
    private let viewModel: RecruitPostViewModel
    private let inputSubject = PassthroughSubject<RecruitPostViewModel.Input, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    private weak var focusedInputView: UIView?
    private var request: RecruitPostRequest = .init() {
        didSet {
            validate()
        }
    }
    /// 화면 진입 시 1회 고정. 모집 일정 최대 범위 기준
    private let today = Date()
    /// request의 시작·종료·마감일. 반영 시 라벨도 함께 갱신
    private var schedule: RecruitPostSchedule {
        get {
            RecruitPostSchedule(start: request.startDate, end: request.endDate, deadline: request.deadline)
        }
        set {
            var request = request
            request.startDate = newValue.start
            request.endDate = newValue.end
            request.deadline = newValue.deadline
            self.request = request
            scheduleView.configure(schedule: newValue)
        }
    }
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentStackView = UIStackView()
    
    private let categoryView = RecruitPostCategoryView()
    private let titleView = RecruitTextFieldView(
        title: "제목",
        isRequired: true,
        limit: 50,
        placeholder: "제목을 입력해주세요."
    )
    private let meetingTypeView = RecruitPostMeetingTypeView()
    private let scheduleView = RecruitPostScheduleView()
    private let roleView = RecruitPostRoleView()
    private let descriptionView = RecruitPostTextViewView(
        title: "모집 소개",
        isRequired: true,
        limit: 1000,
        placeholder: "소개를 작성해주세요."
    )
    private let relatedUrlView = RecruitTextFieldView(
        title: "관련 Url",
        isRequired: false,
        limit: nil,
        placeholder: "공모전/대외활동 등 모집글 관련 Url을 작성해주세요.",
        keyboardType: .URL
    )
    private let qualificationView = RecruitPostTextViewView(
        title: "지원 자격",
        isRequired: false,
        limit: 500,
        placeholder: "지원 자격 또는 우대사항을 작성해주세요."
    )
    
    private let postButton = UIButton()
    
    // MARK: - Dropdown
    private lazy var categoryDropdownContentView = RecruitPostCategoryDropdownView { [weak self] category in
        self?.logEvent(
            post: .teamWriteTeamWriteCategorySelect,
            modify: .teamEditTeamEditCategorySelect,
            value: category.rawValue
        )
        self?.request.category = category
        self?.categoryView.configure(category: category)
    }
    
    // MARK: - Initializer
    init(
        viewModel: RecruitPostViewModel,
    ) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = navigationTitle
        configureView()
        setAddTargets()
        bind()
        bindSections()
        roleView.configure(
            roleType: request.type,
            roles: request.roles,
            numberOfGeneralMembers: request.numberOfGeneralMembers
        )
        observeEditing()
        observeKeyboard()
        inputSubject.send(.viewDidLoad)
        hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar(style: .newBackground)
    }
}

extension RecruitPostViewController {
    private func bind() {
        viewModel.transform(with: inputSubject.eraseToAnyPublisher())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] output in
                guard let self else { return }
                switch output {
                case let .updateForm(data):
                    updateForm(data)
                    updateViews(data)
                case let .updateLoading(isLoading):
                    updateLoading(isLoading)
                case .postCompleted(let id):
                    handlePostCompleted(id: id)
                case .modifyCompleted(let id):
                    handleModifyCompleted(id: id)
                case let .showToast(message):
                    showToastMessage(message: message, bottomInset: 72)
                }
            }.store(in: &subscriptions)
    }
    
    private func bindSections() {
        categoryView.categoryButtonTappedPublisher.sink { [weak self] in
            guard let self else { return }
            presentDropdown(
                anchor: categoryView.dropdownAnchor,
                content: categoryDropdownContentView,
                configuration: .init(direction: .down(spacing: 4), shadow: .shadow2)
            )
        }.store(in: &subscriptions)
        
        titleView.textChangedPublisher.sink { [weak self] text in
            self?.request.title = text
        }.store(in: &subscriptions)
        
        meetingTypeView.meetingTypeChangedPublisher.sink { [weak self] meetingType in
            guard let self else {
                return
            }
            logEvent(post: .teamWriteTeamWriteMethodSelect, modify: .teamEditTeamEditMethodSelect, value: meetingType.logValue)
            request.meetingType = meetingType
            
            let rect = meetingTypeView.convert(
                meetingTypeView.bounds,
                to: self.scrollView
            )
            self.scrollView.scrollRectToVisible(rect.insetBy(dx: 0, dy: 12), animated: true)
        }.store(in: &subscriptions)
        
        scheduleView.startDateButtonTappedPublisher.sink { [weak self] in
            self?.openScheduleDropdown(.start)
        }.store(in: &subscriptions)
        
        scheduleView.endDateButtonTappedPublisher.sink { [weak self] in
            self?.openScheduleDropdown(.end)
        }.store(in: &subscriptions)
        
        scheduleView.deadlineDateButtonTappedPublisher.sink { [weak self] in
            self?.openScheduleDropdown(.deadline)
        }.store(in: &subscriptions)
        
        [RecruitPostSchedule.Field.start, .end, .deadline].forEach { field in
            scheduleView.dropdownContentView(for: field).datePublisher.sink { [weak self] date in
                guard let self else { return }
                schedule = schedule.updating(field, to: date)
            }.store(in: &subscriptions)
        }
        
        roleView.roleTypeChangedPublisher.sink { [weak self] roleType in
            self?.logEvent(post: .teamWriteTeamWriteRoleClick, modify: .teamEditTeamEditRoleClick, value: "역할 구분 없이 모집하기")
            self?.request.type = roleType
        }.store(in: &subscriptions)
        
        roleView.addRoleButtonTappedPublisher.sink { [weak self] in
            self?.logEvent(post: .teamWriteTeamWriteRoleClick, modify: .teamEditTeamEditRoleClick, value: "역할 추가")
        }.store(in: &subscriptions)
        
        roleView.rolesChangedPublisher.sink { [weak self] roles in
            self?.request.roles = roles
        }.store(in: &subscriptions)
        
        roleView.numberOfGeneralMembersChangedPublisher.sink { [weak self] numberOfGeneralMembers in
            self?.request.numberOfGeneralMembers = numberOfGeneralMembers
        }.store(in: &subscriptions)

        roleView.didChangeHeightPublisher.sink { [weak self] heightChanged in
            guard let self else {
                return
            }
            
            view.layoutIfNeeded()
            
            UIView.animate(
                springDuration: 0.25,
                options: [.beginFromCurrentState, .allowUserInteraction]
            ) { [weak self] in
                guard let self else {
                    return
                }
                roleView.applyPendingSizeChange()
                view.layoutIfNeeded()
                
                guard 0 < heightChanged else {
                    return
                }
                let bottomRect = roleView.convert(
                    CGRect(
                        x: 0,
                        y: roleView.bounds.maxY - 1,
                        width: roleView.bounds.width,
                        height: 1
                    ),
                    to: scrollView
                )
                scrollView.scrollRectToVisible(bottomRect, animated: false)
            }
        }.store(in: &subscriptions)
        
        descriptionView.textChangedPublisher.sink { [weak self] description in
            self?.request.description = description
        }.store(in: &subscriptions)
        
        relatedUrlView.textChangedPublisher.sink { [weak self] relatedUrl in
            self?.request.relatedUrl = relatedUrl
        }.store(in: &subscriptions)
        
        qualificationView.textChangedPublisher.sink { [weak self] qualification in
            self?.request.qualification = qualification
        }.store(in: &subscriptions)
    }

    /// 드롭다운형: 범위 적용 후 값 표시. 값이 없으면 보정된 picker.date를 즉시 반영(setDate는 이벤트 없음)
    private func openScheduleDropdown(_ field: RecruitPostSchedule.Field) {
        let picker = scheduleView.dropdownContentView(for: field)
        let range = schedule.range(for: field, today: today)
        picker.setRange(minimum: range.lowerBound, maximum: range.upperBound)
        if let date = schedule.date(for: field) {
            picker.setDate(date)
        } else {
            picker.setDate(Date())
            schedule = schedule.updating(field, to: picker.date)
        }
        presentDropdown(
            anchor: field == .deadline ? scheduleView.deadlineDateDropdownAnchor : scheduleView.activityPeriodDropdownAnchor,
            content: picker,
            configuration: .init(direction: .down(spacing: 4), shadow: .shadow2)
        )
    }
}

extension RecruitPostViewController {
    
    private func updateLoading(_ isLoading: Bool) {
        postButton.isUserInteractionEnabled = !isLoading
        if isLoading {
            IndicatorView.show()
            postButton.backgroundColor = .appColor(.neutral400)
        } else {
            IndicatorView.dismiss()
            validate()
        }
    }
    
    private func handlePostCompleted(id: Int) {
        let repository = DefaultRecruitRepository(service: DefaultRecruitService())
        let fetchUseCase = DefaultFetchRecruitDataUseCase(repository: repository)
        let deleteUseCase = DefaultDeleteRecruitDataUseCase(repository: repository)
        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
        let viewModel = RecruitDataViewModel(
            fetchRecruitDataUseCase: fetchUseCase,
            deleteRecruitDataUseCase: deleteUseCase,
            logAnalyticsEventUseCase: logAnalyticsEventUseCase,
            recruitId: id
        )
        let viewController = RecruitDataHostingController(
            rootView: RecruitDataView(viewModel: viewModel),
            delegate: nil
        )
        replaceTopViewController(viewController, animated: true)
        showToastMessage(message: completionMessage, bottomInset: 60)
    }
    
    private func handleModifyCompleted(id: Int) {
        guard var viewControllers = navigationController?.viewControllers else {
            return
        }
        
        let repository = DefaultRecruitRepository(service: DefaultRecruitService())
        let fetchUseCase = DefaultFetchRecruitDataUseCase(repository: repository)
        let deleteUseCase = DefaultDeleteRecruitDataUseCase(repository: repository)
        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
        let viewModel = RecruitDataViewModel(
            fetchRecruitDataUseCase: fetchUseCase,
            deleteRecruitDataUseCase: deleteUseCase,
            logAnalyticsEventUseCase: logAnalyticsEventUseCase,
            recruitId: id
        )
        let viewController = RecruitDataHostingController(
            rootView: RecruitDataView(viewModel: viewModel),
            delegate: nil
        )
        viewControllers[viewControllers.count - 2] = viewController
        navigationController?.viewControllers = viewControllers
        navigationController?.popToViewController(viewController, animated: true)
        showToastMessage(message: completionMessage, bottomInset: 60)
    }
    
    private func validate() {
        postButton.isEnabled = request.isValid
        postButton.backgroundColor = request.isValid ? UIColor.appColor(.new500) : UIColor.appColor(.neutral400)
    }
    
    private func updateForm(_ data: RecruitData) {
        request = .init(from: data)
    }
    
    private func updateViews(_ data: RecruitData) {
        categoryView.configure(category: data.category)
        titleView.configure(text: data.title)
        meetingTypeView.configure(meetingType: data.meetingType)
        // 서버 값은 보정하지 않고 그대로 표시
        scheduleView.configure(schedule: RecruitPostSchedule(
            start: data.startDate,
            end: data.endDate,
            deadline: data.deadlineDate
        ))
        roleView.configure(
            roleType: data.type,
            roles: data.roles.map { RecruitRoleRequest(from: $0) },
            numberOfGeneralMembers: data.maximumParticipants,
        )
        descriptionView.configure(text: data.description)
        relatedUrlView.configure(text: data.relatedUrl?.absoluteString)
        qualificationView.configure(text: data.qualification)
    }
}

extension RecruitPostViewController {
    
    private func setAddTargets() {
        postButton.addTarget(self, action: #selector(postButtonTapped), for: .touchUpInside)
    }
    
    @objc private func postButtonTapped() {
        view.endEditing(true)
        logEvent(post: .teamWriteTeamWriteOpenClick, modify: .teamEditTeamEditOpenClick, value: submitLogValue)
        showSubmitModal()
    }
    
    private func submit() {
        postButton.isUserInteractionEnabled = false
        inputSubject.send(.submit(request))
    }
    
    private func logEvent(
        post postLabel: EventParameter.EventLabel.Recruit,
        modify modifyLabel: EventParameter.EventLabel.Recruit,
        value: Any
    ) {
        switch viewModel.mode {
        case .post:
            inputSubject.send(.logEvent(postLabel, value))
        case .modify:
            inputSubject.send(.logEvent(modifyLabel, value))
        }
    }
    
    private func showSubmitModal() {
        let onCancelButtonTapped: ()->Void = { [weak self] in
            self?.logEvent(post: .teamWriteTeamWriteCancelClick, modify: .teamEditTeamEditCancelClick, value: "취소하기")
        }
        let onSubmitButtonTapped: ()->Void = { [weak self] in
            guard let self else { return }
            logEvent(post: .teamWriteTeamWriteConfirmClick, modify: .teamEditTeamEditConfirmClick, value: submitButtonTitle)
            submit()
        }
        let modalViewController = KoinModalViewController(
            configuration: .init(
                appearance: .new,
                content: .singleTitle(text: submitModalMessage),
                button: .buttons(
                    leftButtonTitle: "취소하기",
                    leftButtonAction: onCancelButtonTapped,
                    rightButtonTitle: submitButtonTitle,
                    rightButtonAction: onSubmitButtonTapped
                )
            )
        )
        present(modalViewController, animated: true)
    }
}

extension RecruitPostViewController {
    private func observeEditing() {
        NotificationCenter.default.publisher(for: UITextField.textDidBeginEditingNotification)
            .merge(with: NotificationCenter.default.publisher(for: UITextView.textDidBeginEditingNotification))
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notification in
                guard let self,
                      let inputView = notification.object as? UIView,
                      inputView.isDescendant(of: scrollView) else { return }
                focusedInputView = inputView
                scrollFocusedInputIntoView()
            }
            .store(in: &subscriptions)
    }

    private func scrollFocusedInputIntoView() {
        guard let focusedInputView,
              focusedInputView.isFirstResponder,
              focusedInputView.isDescendant(of: scrollView) else { return }
        let rect = focusedInputView.convert(focusedInputView.bounds, to: scrollView)
        scrollView.scrollRectToVisible(rect.insetBy(dx: 0, dy: -12), animated: true)
    }

    private func observeKeyboard() {
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notification in
                guard let self else { return }
                let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
                let keyboardMinY = keyboardFrame.map { [weak self] in
                    self?.view.convert($0, from: nil).minY ?? 0
                } ?? scrollView.frame.maxY
                let overlap = max(0, scrollView.frame.maxY - keyboardMinY)
                scrollView.contentInset.bottom = overlap + 16
                scrollFocusedInputIntoView()
            }
            .store(in: &subscriptions)
        
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notification in
                self?.scrollView.contentInset.bottom = 16
            }
            .store(in: &subscriptions)
    }
}

extension RecruitPostViewController {
    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }
    
    private func setUpStyles() {
        view.backgroundColor = UIColor.appColor(.newBackground)
        
        scrollView.do {
            $0.backgroundColor = .clear
            $0.keyboardDismissMode = .interactive
            $0.alwaysBounceVertical = true
            $0.contentInset = UIEdgeInsets(top: 32, left: 0, bottom: 16, right: 0)
            $0.showsVerticalScrollIndicator = false
        }
        contentStackView.do {
            $0.spacing = 24
            $0.axis = .vertical
        }
        postButton.do {
            $0.setAttributedTitle(NSAttributedString(
                string: submitButtonTitle,
                attributes: [
                    .font: UIFont.appFont(.pretendardSemiBold, size: 15),
                    .foregroundColor: UIColor.appColor(.neutral0)
                ]), for: .normal)
            $0.isEnabled = false
            $0.backgroundColor = .appColor(.neutral400)
            $0.layer.cornerRadius = 16
        }
    }
    
    private func setUpLayouts() {
        [categoryView, titleView, meetingTypeView, scheduleView, roleView, descriptionView, relatedUrlView, qualificationView].forEach {
            contentStackView.addArrangedSubview($0)
        }
            
        [contentStackView].forEach {
            scrollView.addSubview($0)
        }
        
        [scrollView, postButton].forEach {
            view.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        scrollView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.bottom.equalTo(postButton.snp.top).offset(-16)
        }
        contentStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }
        postButton.snp.makeConstraints {
            $0.height.equalTo(48)
            $0.leading.trailing.equalToSuperview().inset(32)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
        }
    }
}
