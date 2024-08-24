//
//  ManageNoticeKeyWordViewController.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/23/24.
//

import Combine
import SnapKit
import Then
import UIKit

final class ManageNoticeKeyWordViewController: UIViewController {
    // MARK: - Properties
    
    private let viewModel: ManageNoticeKeyWordViewModel
    private let inputSubject: PassthroughSubject<ManageNoticeKeyWordViewModel.Input, Never> = .init()
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
   
    private let navigationTitle = UILabel().then {
        $0.text = "키워드 관리"
        $0.font = UIFont.appFont(.pretendardMedium, size: 18)
    }
    
    private let backButton = UIButton().then {
        $0.setImage(UIImage.appImage(asset: .arrowBack), for: .normal)
        $0.tintColor = .appColor(.neutral800)
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        configureView()
    }
    
    // MARK: - Initialization
    
    init(viewModel: ManageNoticeKeyWordViewModel) {
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

extension ManageNoticeKeyWordViewController {
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}

extension ManageNoticeKeyWordViewController {
    private func setUpLayouts() {
        [backButton, navigationTitle].forEach {
            view.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        navigationTitle.snp.makeConstraints {
            $0.centerY.equalTo(backButton.snp.centerY)
            $0.centerX.equalTo(view.snp.centerX)
        }
        
        backButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.equalToSuperview().offset(24)
            $0.width.equalTo(24)
            $0.height.equalTo(24)
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
        self.view.backgroundColor = .white
    }
}

