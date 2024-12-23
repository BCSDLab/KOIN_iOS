//
//  BusSearchResultViewController.swift
//  koin
//
//  Created by JOOMINKYUNG on 11/10/24.
//

import Combine
import DropDown
import SnapKit
import UIKit

final class BusSearchResultViewController: UIViewController, UIGestureRecognizerDelegate {
    // MARK: - Properties
    private let viewModel: BusSearchResultViewModel
    private let inputSubject: PassthroughSubject<BusSearchResultViewModel.Input, Never> = .init()
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    
    private let tableView = BusSearchResultTableView(frame: .zero, style: .plain)
    
    private var busSearchDatePickerViewController = BusSearchDatePickerViewController(width: 301, height: 347, paddingBetweenLabels: 10, title: "출발 시각 설정", subTitle: "현재는 정규학기(12월 20일까지)의\n시간표를 제공하고 있어요.", titleColor: .appColor(.neutral700), subTitleColor: .gray)
    
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
        inputSubject.send(.getSearchedResult("오늘 \(Date().formatDateToHHMM(isHH: false))", .noValue))
        let backButton = UIBarButtonItem(image: .appImage(asset: .arrowBack), style: .done, target: self, action: #selector(tapLeftBarButton))
       navigationItem.leftBarButtonItem = backButton
        
        
        let deleteButton = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(tapRightBarButton))
        navigationItem.rightBarButtonItem = deleteButton
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar(style: .empty)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(false)
    }
    
    
    // MARK: - Bind
    
    private func bind() {
        let outputSubject = viewModel.transform(with: inputSubject.eraseToAnyPublisher())
        
        outputSubject.receive(on: DispatchQueue.main).sink { [weak self] output in
            switch output {
            case let .updateDatePickerData((dates, selectedDate)):
                self?.busSearchDatePickerViewController.setPickerItems(items: dates, selectedItems: selectedDate)
            case let .udpatesSearchedResult(departTime, busSearchedResult):
                self?.updateSearchedResult(departTime: departTime, departInfo: busSearchedResult)
            }
        }.store(in: &subscriptions)
        
        busSearchDatePickerViewController.cancelButtonPublisher.sink { [weak self] in
            self?.inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.departureNow, .click, "지금 출발"))
        }.store(in: &subscriptions)
        
        busSearchDatePickerViewController.changePickerDate.sink { [weak self] isChanged in
            let logValue = isChanged != nil ? "Y" : "N"
            self?.inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.departureTimeSettingDone, .click, logValue))
        }.store(in: &subscriptions)
        
        tableView.tapDepartTimeButtonPublisher
            .sink { [weak self] in
                guard let self = self else { return }
                self.inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.searchResultDepartureTime, .click, "출발 시간 설정"))
                busSearchDatePickerViewController.modalPresentationStyle = .overFullScreen
                present(busSearchDatePickerViewController, animated: true)
        }.store(in: &subscriptions)
        
        tableView.tapDepartBusTypeButtonPublisher.sink { [weak self] busType in
            self?.inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.searchResultBusType, .click, busType.koreanDescription))
            self?.inputSubject.send(.getSearchedResult(nil, busType))
        }.store(in: &subscriptions)
        
        busSearchDatePickerViewController.pickerSelectedItemsPublisher.sink { [weak self] selectedItem in
            if selectedItem.count > 3 {
                let time = "\(selectedItem[0]) \(selectedItem[1]) \(selectedItem[2]):\(selectedItem[3])"
                self?.inputSubject.send(.getSearchedResult(time, nil))
            }
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
    
    private func updateSearchedResult(departTime: String?, departInfo: SearchBusInfoResult) {
        if let time = departTime {
            tableView.setBusSearchTime(departTime: "\(time)")
        }
        tableView.setBusSearchResult(busSearchResult: departInfo)
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
