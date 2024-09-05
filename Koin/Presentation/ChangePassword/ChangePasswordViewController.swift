//
//  ChangePasswordViewController.swift
//  koin
//
//  Created by 김나훈 on 9/5/24.
//

import Combine
import UIKit

final class ChangePasswordViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel: ChangePasswordViewModel
    private let inputSubject: PassthroughSubject<ChangePasswordViewModel.Input, Never> = .init()
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    
    // MARK: - Initialization
    
    init(viewModel: ChangePasswordViewModel) {
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
        bind()
        configureView()
    }
    
    
    // MARK: - Bind
    
    private func bind() {
        let outputSubject = viewModel.transform(with: inputSubject.eraseToAnyPublisher())
        
        outputSubject.receive(on: DispatchQueue.main).sink { [weak self] output in
            switch output {
            }
        }.store(in: &subscriptions)
    }
    
}

extension ChangePasswordViewController {
    
    
}

extension ChangePasswordViewController {
    
   
    private func setUpLayOuts() {
        
       
    }
    
    private func setUpConstraints() {
        
    }
    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
        self.view.backgroundColor = .systemBackground
    }
}
