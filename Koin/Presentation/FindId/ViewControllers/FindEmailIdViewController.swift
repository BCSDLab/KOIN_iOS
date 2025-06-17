//
//  FindEmailIdViewController.swift
//  koin
//
//  Created by 김나훈 on 6/17/25.
//

import Combine
import UIKit

final class FindEmailIdViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: FindIdViewModel
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    
    init(viewModel: FindIdViewModel) {
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
        setupUI()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar(style: .empty)
    }
    
    // MARK: - Bind
    
    private func bind() {
        
    }
}

extension FindEmailIdViewController {
   
}

extension FindEmailIdViewController {
    
    private func setupLayOuts() {
        [].forEach {
            view.addSubview($0)
        }
        
    }
    
    private func setupConstraints() {
   
    }
    
    private func setupComponents() {
      
    }
    
    private func setupUI() {
        setupLayOuts()
        setupConstraints()
        setupComponents()
        self.view.backgroundColor = .systemBackground
    }
}
