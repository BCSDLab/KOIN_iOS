//
//  FindPasswordChangeViewController.swift
//  koin
//
//  Created by 김나훈 on 6/19/25.
//

import Combine
import UIKit

final class FindPasswordChangeViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: FindPasswordViewModel
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    
    private let stepTextLabel = UILabel().then {
        $0.text = "2. 비밀번호 변경"
        $0.textColor = UIColor.appColor(.primary500)
        $0.font = UIFont.appFont(.pretendardMedium, size: 16)
    }
    
    private let stepLabel = UILabel().then {
        $0.text = "2 / 2"
        $0.textColor = UIColor.appColor(.primary500)
        $0.font = UIFont.appFont(.pretendardMedium, size: 16)
    }
    
    private let progressView = UIProgressView().then {
        $0.trackTintColor = UIColor.appColor(.neutral200)
        $0.progressTintColor = UIColor.appColor(.primary500)
        $0.layer.cornerRadius = 4
        $0.clipsToBounds = true
        $0.progress = 1

        NSLayoutConstraint.activate([
            $0.heightAnchor.constraint(equalToConstant: 3)
        ])
    }
    
    init(viewModel: FindPasswordViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        navigationItem.title = "비밀번호 찾기"
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

extension FindPasswordChangeViewController {
    

}

extension FindPasswordChangeViewController {
    
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
