//
//  BusSearchResultViewController.swift
//  koin
//
//  Created by JOOMINKYUNG on 11/10/24.
//

import Combine
import SnapKit
import UIKit

final class BusSearchResultViewController: UIViewController, UIGestureRecognizerDelegate {
    // MARK: - Properties
    private let viewModel: BusSearchResultViewModel
    private let inputSubject: PassthroughSubject<BusSearchResultViewModel.Input, Never> = .init()
    private var subscriptions: Set<AnyCancellable> = []
    private var datePickerSubTitle = ""
    
    // MARK: - UI Components
    
    private let tableView = BusSearchResultTableView(frame: .zero, style: .plain)
    private let refreshControl = UIRefreshControl()
    
    // MARK: - Initialization
    
    init(viewModel: BusSearchResultViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        bind()
        inputSubject.send(.getSearchedResult(viewModel.departDate, nil))
        let backButton = UIBarButtonItem(image: .appImage(asset: .arrowBack), style: .done, target: self, action: #selector(tapLeftBarButton))
       navigationItem.leftBarButtonItem = backButton
        
        
        let deleteButton = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(tapRightBarButton))
        navigationItem.rightBarButtonItem = deleteButton
        
        inputSubject.send(.getSemesterInfo)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar(style: .empty)
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(false)
    }
    
    
    // MARK: - Bind
    
    private func bind() {
        let outputSubject = viewModel.transform(with: inputSubject.eraseToAnyPublisher())
        
        outputSubject.receive(on: DispatchQueue.main).sink { [weak self] output in
            switch output {
            case let .updateDepartDate(departDate, now):
                self?.tableView.setBusSearchTime(departTime: departDate.relativeDayTimeString(today: now))
            case let .udpatesSearchedResult(busSearchedResult):
                self?.tableView.setBusSearchResult(busSearchResult: busSearchedResult)
            case .clearSearchedResult:
                self?.tableView.clearBusSearchResult()
            case .searchCompleted:
                self?.refreshControl.endRefreshing()
            case let .updateSemesterInfo(semesterInfo):
                self?.updateSemesterInfo(semesterInfo: semesterInfo)
            }
        }.store(in: &subscriptions)

        tableView.tapDepartTimeButtonPublisher
            .sink { [weak self] in
                guard let self = self else { return }
                self.inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.Bus.searchResultDepartureTime, .click, "출발 시간 설정"))
                self.presentBusSearchDatePickerViewController()
        }.store(in: &subscriptions)
        
        tableView.tapDepartBusTypeButtonPublisher.sink { [weak self] busType in
            self?.inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.Bus.searchResultBusType, .click, busType.koreanDescription))
            self?.inputSubject.send(.getSearchedResult(nil, busType))
        }.store(in: &subscriptions)
    }
}

extension BusSearchResultViewController {
    @objc private func tapLeftBarButton() {
        inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.Bus.searchResultBack, .click, "뒤로가기"))
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func tapRightBarButton() {
        inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.Bus.searchResultClose, .click, "뒤로가기"))
        navigationController?.popViewController(animated: true)
    }
    
    /// 당겨서 새로고침 = 지금 출발
    @objc private func didPullToRefresh() {
        inputSubject.send(.departNow)
    }
    
    private func updateSemesterInfo(semesterInfo: SemesterInfo) {
        datePickerSubTitle = "현재는 \(semesterInfo.name)(\(semesterInfo.to)까지)의 시간표를 제공하고 있어요."
    }

    /// 모달형: 열 때 현재 departDate 표시, 완료 시에만 적용, 닫기는 미적용
    private func presentBusSearchDatePickerViewController() {
        // Input은 동기 처리라 아래에서 갱신된 now를 읽음
        inputSubject.send(.refreshNowIfDayChanged)
        let busSearchDatePickerViewController = BusSearchDatePickerViewController(
            subTitle: datePickerSubTitle,
            now: viewModel.now,
            departDate: viewModel.departDate,
            onCompleted: { [weak self] departDate, isDateChanged in
                self?.inputSubject.send(.getSearchedResult(departDate, nil))
                self?.inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.Bus.departureTimeSettingDone, .click, isDateChanged ? "Y" : "N"))
            },
            onDepartureNowTapped: { [weak self] in
                self?.inputSubject.send(.departNow)
                self?.inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.Bus.departureNow, .click, "지금 출발"))
            }
        )
        present(busSearchDatePickerViewController, animated: true)
    }
}

extension BusSearchResultViewController {
    private func setUpLayOuts() {
        [tableView].forEach {
            view.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        tableView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
    }
    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
        self.view.backgroundColor = .systemBackground
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
    }
}
