//
//  FindPasswordViewController.swift
//  koin
//
//  Created by 김나훈 on 3/24/24.
//

import Combine
import UIKit

final class FindPasswordViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel: FindPasswordViewModel
    private let inputSubject: PassthroughSubject<FindPasswordViewModel.Input, Never> = .init()
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    
    private let logoImageView = UIImageView().then {
        $0.image = UIImage.appImage(asset: .koinLogo)
    }
    
    private let emailGuideLabel = UILabel().then {
        $0.text = "@koreatech.ac.kr은 입력하지 않으셔도 됩니다."
        $0.font = UIFont.appFont(.pretendardRegular, size: 12)
        $0.textColor = UIColor.appColor(.neutral400)
    }
    
    private let emailTextField = UITextField().then {
        $0.autocapitalizationType = .none
        $0.font = UIFont.appFont(.pretendardRegular, size: 13)
        $0.layer.borderWidth = 1.0
        $0.layer.borderColor = UIColor.appColor(.neutral500).cgColor
        $0.layer.cornerRadius = 2.0
        let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: $0.frame.height))
        $0.leftView = leftPaddingView
        $0.placeholder = "아우누리 아이디를 입력하세요"
        $0.leftViewMode = .always
    }
    
    private let findButton = UIButton().then {
        $0.setTitle("비밀번호 찾기", for: .normal)
        $0.setTitleColor(UIColor.appColor(.neutral0), for: .normal)
        $0.backgroundColor = UIColor.appColor(.primary500)
        $0.titleLabel?.font = UIFont.appFont(.pretendardMedium, size: 15)
    }
    
    private let serviceLabel = UILabel().then {
        $0.text = "학교메일로 비밀번호 초기화 메일이 발송됩니다."
        $0.font = UIFont.appFont(.pretendardRegular, size: 12)
        $0.textColor = UIColor.appColor(.neutral400)
    }
    
    private let responseLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardRegular, size: 14)
        $0.textColor = .red
        $0.numberOfLines = 0
    }
    
    // MARK: - Initialization
    
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
        bind()
        configureView()
        emailTextField.delegate = self
        hideKeyboardWhenTappedAround()
        findButton.addTarget(self, action: #selector(findButtonTapped), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar(style: .fill)
    }

    // MARK: - Bind
    
    private func bind() {
        let outputSubject = viewModel.transform(with: inputSubject.eraseToAnyPublisher())
      
        outputSubject.receive(on: DispatchQueue.main).sink { [weak self] output in
            switch output {
            case let .showHttpErrorMessage(message):
                self?.responseLabel.text = message
            case .sendEmailSuccess:
                self?.dissMissView()
            }
        }.store(in: &subscriptions)
      
    }
    
}

extension FindPasswordViewController {
    
    private func dissMissView() {
        let alertController = UIAlertController(title: nil, message: "아우누리 이메일로 인증 메일을 보냈습니다. 확인 부탁드립니다.", preferredStyle: .alert)
           let confirmAction = UIAlertAction(title: "확인", style: .default) { [weak self] _ in
               self?.navigationController?.popViewController(animated: true)
           }
           alertController.addAction(confirmAction)
           present(alertController, animated: true, completion: nil)
    }
    
    @objc private func findButtonTapped() {
        responseLabel.text = ""
        inputSubject.send(.findPassword(emailTextField.text ?? ""))
    }
}

extension FindPasswordViewController {
    private func setUpLayOuts() {
        [logoImageView, emailGuideLabel, emailTextField, findButton, serviceLabel, responseLabel].forEach {
            view.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        logoImageView.snp.makeConstraints { make in
            make.centerX.equalTo(view.snp.centerX)
            make.centerY.equalTo(view.snp.centerY).offset(-100)
            make.height.equalTo(70)
            make.width.equalTo(100)
        }
        emailTextField.snp.makeConstraints { make in
            make.top.equalTo(logoImageView.snp.bottom).offset(10)
            make.leading.equalTo(view.snp.leading).offset(30)
            make.trailing.equalTo(view.snp.trailing).offset(-30)
            make.height.equalTo(45)
        }
        emailGuideLabel.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(5)
            make.leading.equalTo(emailTextField.snp.leading)
        }
        findButton.snp.makeConstraints { make in
            make.top.equalTo(emailGuideLabel.snp.bottom).offset(10)
            make.leading.equalTo(view.snp.leading).offset(30)
            make.trailing.equalTo(view.snp.trailing).offset(-30)
            make.height.equalTo(45)
        }
        serviceLabel.snp.makeConstraints { make in
            make.top.equalTo(findButton.snp.bottom).offset(10)
            make.leading.equalTo(findButton.snp.leading)
        }
        responseLabel.snp.makeConstraints { make in
            make.top.equalTo(serviceLabel.snp.bottom).offset(10)
            make.leading.equalTo(serviceLabel.snp.leading)
            make.trailing.equalTo(findButton.snp.trailing)
        }
    }
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
        self.view.backgroundColor = .systemBackground
    }
}

