//
//  LandSearchViewController.swift
//  koin
//
//  Created by 홍기정 on 11/24/26.
//

import UIKit
import Combine
import SnapKit

final class LandSearchViewController: UIViewController {

    // MARK: - Properties
    private let viewModel: LandSearchViewModel
    private let inputSubject = PassthroughSubject<LandSearchViewModel.Input, Never>()
    private var subscriptions: Set<AnyCancellable> = []

    // MARK: - UI Components
    private let navigationBarView = UIView()
    private let navigationTitleLabel = UILabel()
    private let backButton = UIButton(type: .system)
    private let searchBarView = LandSearchBarView()
    private let countLabel = UILabel()
    private let tableView = LandListTableView()
    private let emptyView = LandSearchEmptyView()
    private let suggestionView = LandSearchSuggestionView()

    // MARK: - Initializer
    init(viewModel: LandSearchViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        bind()
        hideKeyboardWhenTappedAround()
        inputSubject.send(.viewDidLoad)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}

extension LandSearchViewController {
    private func bind() {
        viewModel.transform(with: inputSubject.eraseToAnyPublisher())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] output in
                guard let self else { return }
                switch output {
                case let .updateSuggestions(query, rows):
                    configureSuggestions(query: query, rows: rows)
                case let .updateLandList(landList):
                    configure(landList: landList)
                case let .showToastMessage(message):
                    showToastMessage(message: message)
                }
            }
            .store(in: &subscriptions)

        searchBarView.textChangedPublisher
            .sink { [weak self] text in
                self?.suggestionView.isHidden = true
                self?.inputSubject.send(.searchTextChanged(text))
            }
            .store(in: &subscriptions)

        searchBarView.editingBeganPublisher
            .sink { [weak self] in
                self?.inputSubject.send(.logEvent(EventParameter.EventLabel.RealEstate.roomListSearchInputClick, "검색창"))
            }
            .store(in: &subscriptions)

        searchBarView.searchSubmittedPublisher
            .sink { [weak self] text in
                if !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    self?.inputSubject.send(.logEvent(EventParameter.EventLabel.RealEstate.roomListSearchSubmit, "검색"))
                }
                self?.search(text: text)
            }
            .store(in: &subscriptions)

        searchBarView.editingEndedPublisher
            .sink { [weak self] in
                self?.suggestionView.isHidden = true
            }
            .store(in: &subscriptions)

        suggestionView.suggestionTappedPublisher
            .sink { [weak self] landRow in
                self?.inputSubject.send(.logEvent(EventParameter.EventLabel.RealEstate.roomListSearchSuggestionSelectClick, landRow.name))
                self?.searchBarView.setText(landRow.name)
                self?.view.endEditing(true)
                self?.search(text: landRow.name)
            }
            .store(in: &subscriptions)

        tableView.rowTappedPublisher
            .sink { [weak self] landRow in
                self?.pushLandDetailViewController(landRow: landRow)
            }
            .store(in: &subscriptions)
    }
}

extension LandSearchViewController: PopLoggable {
    func sendPopLog(category: EventParameter.EventCategory) {
        let label: EventLabelType = category == .swipe
            ? EventParameter.EventLabel.RealEstate.roomCommonNavigationBackSwipe
            : EventParameter.EventLabel.RealEstate.roomCommonNavigationBackClick
        inputSubject.send(.logEvent(label, "뒤로가기", parameters: ["source_screen": "room_list"]))
    }
}

extension LandSearchViewController {
    private func search(text: String) {
        suggestionView.isHidden = true
        inputSubject.send(.search(text))
    }

    private func configureSuggestions(query: String, rows: [LandRow]) {
        guard query == searchBarView.text.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
        suggestionView.configure(query: query, rows: rows)
        suggestionView.isHidden = rows.isEmpty || !searchBarView.isEditing
    }

    private func configure(landList: LandList) {
        let isEmpty = landList.rows.isEmpty
        countLabel.text = "\(LandListFilter.all.displayName)(\(landList.rows.count))"
        countLabel.isHidden = isEmpty
        tableView.isHidden = isEmpty
        emptyView.isHidden = !isEmpty
        tableView.configure(rows: landList.rows)
    }

    private func pushLandDetailViewController(landRow: LandRow) {
        let landService = DefaultLandService()
        let landRepository = DefaultLandRepository(service: landService)
        let fetchLandDetailUseCase = DefaultFetchLandDetailUseCase(landRepository: landRepository)
        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
        let viewModel = LandDetailViewModel(
            landRow: landRow,
            fetchLandDetailUseCase: fetchLandDetailUseCase,
            logAnalyticsEventUseCase: logAnalyticsEventUseCase
        )
        let viewController = LandDetailViewController(viewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }

    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}

extension LandSearchViewController {
    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }

    private func setUpStyles() {
        view.backgroundColor = .appColor(.neutral0)
        additionalSafeAreaInsets.top = 44
        view.keyboardLayoutGuide.usesBottomSafeArea = false
        navigationBarView.backgroundColor = .appColor(.neutral0)
        navigationTitleLabel.do {
            $0.text = "복덕방"
            $0.font = .appFont(.pretendardMedium, size: 18)
            $0.textColor = .appColor(.neutral800)
        }
        backButton.do {
            $0.setImage(
                UIImage.appImage(symbol: .chevronLeft)?
                    .withConfiguration(UIImage.SymbolConfiguration(pointSize: 17, weight: .semibold, scale: .large)),
                for: .normal
            )
            $0.tintColor = .appColor(.neutral800)
            $0.accessibilityLabel = "뒤로가기"
            $0.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        }
        countLabel.do {
            $0.font = .appFont(.pretendardMedium, size: 12)
            $0.textColor = UIColor.ColorSystem.Neutral.gray500
            $0.isHidden = true
        }
        tableView.do {
            $0.keyboardDismissMode = .interactive
            $0.isHidden = true
        }
        emptyView.isHidden = true
        suggestionView.isHidden = true
    }

    private func setUpLayouts() {
        [navigationBarView, searchBarView, countLabel, tableView, emptyView, suggestionView].forEach {
            view.addSubview($0)
        }
        [navigationTitleLabel, backButton].forEach {
            navigationBarView.addSubview($0)
        }
    }

    private func setUpConstraints() {
        navigationBarView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
        backButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(8)
            $0.bottom.equalToSuperview()
            $0.size.equalTo(44)
        }
        navigationTitleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(backButton)
        }
        searchBarView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(24)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(36)
        }
        countLabel.snp.makeConstraints {
            $0.top.equalTo(searchBarView.snp.bottom).offset(12)
            $0.leading.equalToSuperview().offset(24)
            $0.height.equalTo(19)
        }
        tableView.snp.makeConstraints {
            $0.top.equalTo(countLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.keyboardLayoutGuide.snp.top)
        }
        emptyView.snp.makeConstraints {
            $0.top.equalTo(searchBarView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.keyboardLayoutGuide.snp.top)
        }
        suggestionView.snp.makeConstraints {
            $0.top.equalTo(searchBarView.snp.bottom).offset(8)
            $0.leading.trailing.equalTo(searchBarView)
        }
    }
}
