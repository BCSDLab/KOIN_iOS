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
        
       
    }
}

extension BusSearchResultViewController {
   
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

