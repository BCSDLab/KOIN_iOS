//
//  NoticeSearchViewController.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/23/24.
//

import Combine
import SnapKit
import Then
import UIKit

final class NoticeSearchViewController: UIViewController {
    // MARK: - Properties
    
    private let viewModel: NoticeSearchViewModel
    private let inputSubject: PassthroughSubject<NoticeSearchViewModel.Input, Never> = .init()
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
   
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    // MARK: - Initialization
    
    init(viewModel: NoticeSearchViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func bind() {
        let outputSubject = viewModel.transform(with: inputSubject.eraseToAnyPublisher())
        outputSubject.receive(on: DispatchQueue.main).sink { [weak self] output in
     
        }.store(in: &subscriptions)
    }
}

extension NoticeListViewController {
    
}

extension NoticeSearchViewController {
    private func setUpLayouts() {
       
    }
    
    private func setUpConstraints() {
        
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
        self.view.backgroundColor = .white
    }
}
