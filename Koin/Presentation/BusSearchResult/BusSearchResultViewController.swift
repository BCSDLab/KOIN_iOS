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
    
    private let tableView = BusSearchResultTableView(frame: .zero, style: .grouped)
    
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
        setNavigationTitle(title: "\(viewModel.busPlaces.0.koreanDescription) -> \(viewModel.busPlaces.1.koreanDescription)")
        bind()
        inputSubject.send(.getDatePickerData)
    }
    
    
    // MARK: - Bind
    
    private func bind() {
        let outputSubject = viewModel.transform(with: inputSubject.eraseToAnyPublisher())
        
        outputSubject.receive(on: DispatchQueue.main).sink { [weak self] output in
            switch output {
            case let .updateDatePickerData((dates, selectedDate)):
                self?.busSearchDatePickerViewController.setPickerItems(items: dates, selectedItems: selectedDate)
            case let .udpatesSearchedResult(busSearchedResult):
                self?.updateSearchedResult(departInfo: busSearchedResult)
            }
        }.store(in: &subscriptions)
        
        
        tableView.tapDepartTimeButtonPublisher
            .sink { [weak self] in
                guard let self = self else { return }
                busSearchDatePickerViewController.modalPresentationStyle = .overFullScreen
                present(busSearchDatePickerViewController, animated: true)
        }.store(in: &subscriptions)
        
        busSearchDatePickerViewController.pickerSelectedItemsPublisher.sink { [weak self] selectedItem in
            if selectedItem.count > 3 {
                let time = "\(selectedItem[0]) \(selectedItem[1]) \(selectedItem[2]) : \(selectedItem[3])"
                self?.tableView.setBusSearchTime(departTime: time)
            }
        }.store(in: &subscriptions)
    }
}

extension BusSearchResultViewController {
    private func updateSearchedResult(departInfo: SearchBusInfoResult) {
        tableView.setBusSearchDate(busSearchResult: departInfo.schedule)
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
