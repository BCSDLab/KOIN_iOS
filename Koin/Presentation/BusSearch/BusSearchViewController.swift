//
//  BusSearchViewController.swift
//  koin
//
//  Created by JOOMINKYUNG on 11/10/24.
//

import Combine
import DropDown
import UIKit

final class BusSearchViewController: CustomViewController {
    
    private let viewModel: BusSearchViewModel
    private let inputSubject: PassthroughSubject<BusSearchViewModel.Input, Never> = .init()
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components

   
    // MARK: - Initialization
    
    init(viewModel: BusSearchViewModel) {
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
        setNavigationTitle(title: "교통편 조회하기")
    }
    
    
    // MARK: - Bind
    
    private func bind() {
        let outputSubject = viewModel.transform(with: inputSubject.eraseToAnyPublisher())
        
    }
}

extension BusSearchViewController {
    
   
    
}


extension BusSearchViewController {
    
    private func setUpLayOuts() {
        self.view.addSubview(navigationBarWrappedView)
    }
    
    private func setUpConstraints() {
        navigationBarWrappedView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(85)
        }
    }
    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
        self.view.backgroundColor = .systemBackground
    }
}
