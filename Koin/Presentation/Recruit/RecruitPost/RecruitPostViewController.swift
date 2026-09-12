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
        switch viewModel.postType {
        case .post:
            return "모집글 작성"
        case .modify:
            return "모집글 수정"
        }
    }
    private var submitButtonTitle: String {
        switch viewModel.postType {
        case .post:
            return "등록하기"
        case .modify:
            return "수정하기"
        }
    }
    private var completionMessage: String {
        switch viewModel.postType {
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
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentStackView = UIStackView()
    
    private let categoryView = RecruitPostCategoryView()
    private let titleView = RecruitPostTextFieldView(
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
    private let relatedUrlView = RecruitPostTextFieldView(
        title: "관련 Url",
        isRequired: false,
        limit: nil,
        placeholder: "공모전/대외활동 등 모집글 관련 Url을 작성해주세요.",
    )
    private let qualificationView = RecruitPostTextViewView(
        title: "지원 자격",
        isRequired: false,
        limit: 500,
        placeholder: "지원 자격 또는 우대사항을 작성해주세요."
    )
    
    private let postButton = UIButton()
    
    // MARK: - Dropdown
    private lazy var dropdownHost = KoinDropdownHost(scrollView: scrollView)
    
    private lazy var categoryDropdown = dropdownHost.makeDropdown(
        anchor: categoryView.dropdownAnchor,
        contentView: RecruitPostCategoryDropdownView { [weak self] category in
            self?.request.category = category
            self?.categoryView.configure(category: category)
        },
        configuration: .init(topPadding: 4, shadow: .shadow2)
    )
    private lazy var startDateDropdown = dropdownHost.makeDropdown(
        anchor: scheduleView.activityPeriodDropdownAnchor,
        contentView: scheduleView.startDateDropdownContentView,
        configuration: .init(topPadding: 4, shadow: .shadow2)
    )
    private lazy var endDateDropdown = dropdownHost.makeDropdown(
        anchor: scheduleView.activityPeriodDropdownAnchor,
        contentView: scheduleView.endDateDropdownContentView,
        configuration: .init(topPadding: 4, shadow: .shadow2)
    )
    private lazy var deadlineDateDropdown = dropdownHost.makeDropdown(
        anchor: scheduleView.deadlineDateDropdownAnchor,
        contentView: scheduleView.deadlineDateDropdownContentView,
        configuration: .init(topPadding: 4, shadow: .shadow2)
    )
    
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
            view.endEditing(true)
            categoryDropdown.toggle()
        }.store(in: &subscriptions)
        
        titleView.textChangedPublisher.sink { [weak self] text in
            self?.request.title = text
        }.store(in: &subscriptions)
        
        meetingTypeView.meetingTypeChangedPublisher.sink { [weak self] meetingType in
            self?.request.meetingType = meetingType
        }.store(in: &subscriptions)
        
        scheduleView.startDateButtonTappedPublisher.sink { [weak self] in
            guard let self else { return }
            view.endEditing(true)
            scheduleView.startDateDropdownContentView.reset(initialDate: request.startDate ?? Date())
            startDateDropdown.toggle()
        }.store(in: &subscriptions)
        
        scheduleView.endDateButtonTappedPublisher.sink { [weak self] in
            guard let self else { return }
            view.endEditing(true)
            scheduleView.endDateDropdownContentView.reset(initialDate: request.endDate ?? Date())
            endDateDropdown.toggle()
        }.store(in: &subscriptions)
        
        scheduleView.deadlineDateButtonTappedPublisher.sink { [weak self] in
            guard let self else { return }
            view.endEditing(true)
            scheduleView.deadlineDateDropdownContentView.reset(initialDate: request.deadline ?? Date())
            deadlineDateDropdown.toggle()
        }.store(in: &subscriptions)
        
        scheduleView.startDateDropdownContentView.selectedItemPublisher.sink { [weak self] selectedItems in
            let startDate = self?.date(from: selectedItems)
            if self?.request.startDate != startDate {
                self?.request.startDate = startDate
                self?.scheduleView.configure(startDate: startDate)
            }
        }.store(in: &subscriptions)
        
        scheduleView.endDateDropdownContentView.selectedItemPublisher.sink { [weak self] selectedItems in
            let endDate = self?.date(from: selectedItems)
            if self?.request.endDate != endDate {
                self?.request.endDate = endDate
                self?.scheduleView.configure(endDate: endDate)
            }
        }.store(in: &subscriptions)
        
        scheduleView.deadlineDateDropdownContentView.selectedItemPublisher.sink { [weak self] selectedItems in
            let deadline = self?.date(from: selectedItems)
            if self?.request.deadline != deadline {
                self?.request.deadline = deadline
                self?.scheduleView.configure(deadlineDate: deadline)
            }
        }.store(in: &subscriptions)
        
        roleView.roleTypeChangedPublisher.sink { [weak self] roleType in
            self?.request.type = roleType
        }.store(in: &subscriptions)
        
        roleView.rolesChangedPublisher.sink { [weak self] roles in
            self?.request.roles = roles
        }.store(in: &subscriptions)
        
        roleView.numberOfGeneralMembersChangedPublisher.sink { [weak self] numberOfGeneralMembers in
            self?.request.numberOfGeneralMembers = numberOfGeneralMembers
        }.store(in: &subscriptions)

        roleView.didChangeHeightPublisher.sink { [weak self] in
            guard let self else { return }
            view.layoutIfNeeded()
            UIView.animate(
                springDuration: 0.25,
                options: [.beginFromCurrentState, .allowUserInteraction]
            ) {
                self.roleView.applyPendingSizeChange()
                self.view.layoutIfNeeded()
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

    private func date(from selectedItems: [String]) -> Date? {
        guard selectedItems.count == 3,
              let year = Int(selectedItems[0].filter { $0.isNumber }),
              let month = Int(selectedItems[1].filter { $0.isNumber }),
              let day = Int(selectedItems[2].filter { $0.isNumber }) else {
            return nil
        }
        var components = DateComponents()
        components.calendar = Calendar(identifier: .gregorian)
        components.timeZone = TimeZone.current
        components.year = year
        components.month = month
        components.day = day
        return components.date
    }
}

extension RecruitPostViewController {
    
    private func updateLoading(_ isLoading: Bool) {
        guard var configuration = postButton.configuration else {
            return
        }
        configuration.showsActivityIndicator = isLoading
        postButton.configuration = configuration
        postButton.isUserInteractionEnabled = !isLoading
    }
    
    private func handlePostCompleted(id: Int) {
        let repository = MockRecruitRepository()
        let fetchUseCase = DefaultFetchRecruitDataUseCase(repository: repository)
        let deleteUseCase = DefaultDeleteRecruitDataUseCase(repository: repository)
        let viewModel = RecruitDataViewModel(fetchRecruitDataUseCase: fetchUseCase, deleteRecruitDataUseCase: deleteUseCase, recruitId: id)
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
        
        let repository = MockRecruitRepository()
        let fetchUseCase = DefaultFetchRecruitDataUseCase(repository: repository)
        let deleteUseCase = DefaultDeleteRecruitDataUseCase(repository: repository)
        let viewModel = RecruitDataViewModel(fetchRecruitDataUseCase: fetchUseCase, deleteRecruitDataUseCase: deleteUseCase, recruitId: id)
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
        scheduleView.configure(
            startDate: data.startDate,
            endDate: data.endDate,
            deadlineDate: data.deadlineDate
        )
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
        guard !dropdownHost.isPresenting else { return }
        postButton.isUserInteractionEnabled = false
        view.endEditing(true)
        inputSubject.send(.submit(request))
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
                let keyboardMinY = keyboardFrame.map { self.view.convert($0, from: nil).minY } ?? scrollView.frame.maxY
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
