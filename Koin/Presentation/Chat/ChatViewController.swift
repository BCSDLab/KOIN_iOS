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
    
    private let blockModalViewController = ModalViewController(width: 301, height: 179, paddingBetweenLabels: 12, title: "이 사용자를 차단하시겠습니까?", subTitle: "쪽지 수신 및 발신이 모두 차단됩니다.", titleColor: UIColor.appColor(.neutral700), subTitleColor: UIColor.appColor(.gray), rightButtonText: "차단하기").then {
        $0.modalPresentationStyle = .overFullScreen
        $0.modalTransitionStyle = .crossDissolve
    }
    
    
    init(viewModel: ChatViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        navigationItem.title = viewModel.articleTitle
        
        let rightButton = UIBarButtonItem(image: UIImage.appImage(asset: .threeCircle), style: .plain, target: self, action: #selector(rightButtonTapped))
        navigationItem.rightBarButtonItem = rightButton
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
        inputSubject.send(.fetchChatDetail)
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
            case .showChatList: print(1)
            }
        }.store(in: &subscriptions)
        
        
        blockModalViewController.rightButtonPublisher.sink { [weak self] _ in
            self?.inputSubject.send(.blockUser)
        }.store(in: &subscriptions)
    }
}

extension ChatViewController{
    @objc private func rightButtonTapped() {
        present(blockModalViewController, animated: true)
    }
  
}

extension ChatViewController {
    
    private func setUpLayOuts() {
        [].forEach {
            view.addSubview($0)
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
