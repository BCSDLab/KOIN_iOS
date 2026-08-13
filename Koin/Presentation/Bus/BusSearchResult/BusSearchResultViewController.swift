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
        inputSubject.send(.getDatePickerData)
        getTodayData()
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
            case let .udpatesSearchedResult(departTime, busSearchedResult):
                self?.updateSearchedResult(departTime: departTime, departInfo: busSearchedResult)
            case let .updateSemesterInfo(semesterInfo):
                self?.updateSemesterInfo(semesterInfo: semesterInfo)
            }
        }.store(in: &subscriptions)

        tableView.tapDepartTimeButtonPublisher
            .sink { [weak self] in
                guard let self = self else { return }
                self.inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.searchResultDepartureTime, .click, "출발 시간 설정"))
                self.presentBusSearchDatePickerViewController()
        }.store(in: &subscriptions)
        
        tableView.tapDepartBusTypeButtonPublisher.sink { [weak self] busType in
            self?.inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.searchResultBusType, .click, busType.koreanDescription))
            self?.inputSubject.send(.getSearchedResult(nil, busType))
        }.store(in: &subscriptions)
    }
}

extension BusSearchResultViewController {
    @objc private func tapLeftBarButton() {
        inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.searchResultBack, .click, "뒤로가기"))
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func tapRightBarButton() {
        inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.searchResultClose, .click, "뒤로가기"))
        navigationController?.popViewController(animated: true)
    }
    
    private func getTodayData() {
        let currentDate = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: currentDate)
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "h:mm"
    
        let amPm = hour < 12 ? "오전" : "오후"
        let formattedTime = formatter.string(from: currentDate)
       
        let today = "오늘 \(amPm) \(formattedTime)"
        inputSubject.send(.getSearchedResult(today, .noValue))
    }
    
    private func updateSearchedResult(departTime: String?, departInfo: SearchBusInfoResult) {
        if let time = departTime {
            tableView.setBusSearchTime(departTime: "\(time)")
        }
        tableView.setBusSearchResult(busSearchResult: departInfo)
    }
    
    private func updateSemesterInfo(semesterInfo: SemesterInfo) {
        datePickerSubTitle = "현재는 \(semesterInfo.name)(\(semesterInfo.to)까지)의 시간표를 제공하고 있어요."
    }

    private func presentBusSearchDatePickerViewController() {
        guard let datePickerData = viewModel.datePickerData else { return }

        let busSearchDatePickerViewController = BusSearchDatePickerViewController(
            onDepartureNowTapped: { [weak self] in
                self?.inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.departureNow, .click, "지금 출발"))
            },
            onPickerDateChanged: { [weak self] isChanged in
                let logValue = isChanged != nil ? "Y" : "N"
                self?.inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.departureTimeSettingDone, .click, logValue))
            },
            onPickerItemsSelected: { [weak self] selectedItems in
                guard selectedItems.count > 3 else { return }
                self?.inputSubject.send(.updateDatePickerSelectedItems(selectedItems))
                let time = "\(selectedItems[0]) \(selectedItems[1]) \(selectedItems[2]):\(selectedItems[3])"
                self?.inputSubject.send(.getSearchedResult(time, nil))
            },
            width: 301,
            height: 347,
            paddingBetweenLabels: 10,
            title: "출발 시각 설정",
            subTitle: datePickerSubTitle,
            titleColor: .appColor(.neutral700),
            subTitleColor: .gray
        )
        busSearchDatePickerViewController.setPickerItems(items: datePickerData.0, selectedItems: datePickerData.1)
        busSearchDatePickerViewController.modalPresentationStyle = .overFullScreen
        present(busSearchDatePickerViewController, animated: false)
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
    }
}
