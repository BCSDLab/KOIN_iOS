//
//  ChatViewController.swift
//  koin
//
//  Created by 김나훈 on 2/16/25.
//

import Combine
import UIKit

final class ChatViewController: UIViewController {
    
    // MARK: - Properties
    
    
    private let viewModel: ChatViewModel
    private let inputSubject: PassthroughSubject<ChatViewModel.Input, Never> = .init()
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    
    private let scrollView = UIScrollView().then { _ in
    }
    
    
    init(viewModel: ChatViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        navigationItem.title = "채팅"
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        configureNavigationBar(style: .empty)
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

extension ChatViewController{
    
  
}

extension ChatViewController {
    
    private func setUpLayOuts() {
        [].forEach {
            view.addSubview($0)
        }
        
        [].forEach {
            scrollView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
    }
    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
        self.view.backgroundColor = .systemBackground
    }
}
