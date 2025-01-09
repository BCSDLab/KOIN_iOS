//
//  LostArticleReportViewController.swift
//  koin
//
//  Created by 김나훈 on 1/9/25.
//

import Combine
import UIKit


final class LostArticleReportViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel: LostArticleReportViewModel
    private let inputSubject: PassthroughSubject<LostArticleReportViewModel.Input, Never> = .init()
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    
 
    init(viewModel: LostArticleReportViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        navigationItem.title = "습득물 신고"
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

extension LostArticleReportViewController {
    
    
}

extension LostArticleReportViewController {
    
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
