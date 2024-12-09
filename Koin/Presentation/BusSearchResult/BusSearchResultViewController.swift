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

final class BusSearchResultViewController: CustomViewController {
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
        setUpNavigationBar()
        setNavigationTitle(title: "한기대 -> 천안터미널")
        bind()
    }
    
    
    // MARK: - Bind
    
    private func bind() {
        let outputSubject = viewModel.transform(with: inputSubject.eraseToAnyPublisher())
        
        tableView.tapDepartTimeButtonPublisher
            .sink { [weak self] in
            self?.showBusSearchAlertViewController()
        }.store(in: &subscriptions)
        
        busSearchDatePickerViewController.pickerSelectedItemsPublisher.sink { [weak self] selectedItem in
            if selectedItem.count > 3 {
                let time = "\(selectedItem[0]) \(selectedItem[1]) \(selectedItem[2]) : \(selectedItem[3])"
                self?.tableView.setBusSearchDate(searchDate: time)
            }
        }.store(in: &subscriptions)
    }
}

extension BusSearchResultViewController {
    //추후 유스케이스로 빼야 함.
    private func setUpDatePickerView() -> ([[String]], [String]) {
        let formatter = DateFormatter()
        formatter.dateFormat = "M월 d일(EEE)"
        formatter.locale = Locale(identifier: "ko_KR")
        
        let sequence = Array(2..<90)
        let dateArray = Date().generateDateArray(formatter: formatter, sequence: sequence)
        let amPmArray = ["오전", "오후"]
        let calendar = Calendar.current
        let currentDate = Date()
        let currentHour = calendar.component(.hour, from: currentDate)
        let currentMinute = calendar.component(.minute, from: currentDate)
        let hourArray: [String] = Array(0..<12).map { String($0) }
        let minuteArray: [String] = Array(0..<60).map { String(format: "%02d", $0) }
      
        let amPmIndex = currentHour < 12 ? 0 : 1 
        let selectedAmPm = amPmArray[amPmIndex]
      
        let adjustedHour = currentHour % 12
        let selectedHour = String(adjustedHour == 0 ? 12 : adjustedHour)
        
        let selectedMinute = String(format: "%02d", currentMinute)
       
        let selectedItems = [dateArray[0], selectedAmPm, selectedHour, selectedMinute]
        
        return ([dateArray, amPmArray, hourArray, minuteArray], selectedItems)
    }
    
    private func showBusSearchAlertViewController() {
        let items = setUpDatePickerView().0
        let selectedItems = setUpDatePickerView().1
        busSearchDatePickerViewController.setPickerItems(items: items, selectedItems: selectedItems)
        self.present(busSearchDatePickerViewController, animated: true)
    }
}


extension BusSearchResultViewController {
    private func setUpLayOuts() {
        [navigationBarWrappedView, tableView].forEach {
            view.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        navigationBarWrappedView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(45)
        }
        tableView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.top.equalTo(navigationBarWrappedView.snp.bottom)
        }
    }
    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
        self.view.backgroundColor = .systemBackground
    }
}

