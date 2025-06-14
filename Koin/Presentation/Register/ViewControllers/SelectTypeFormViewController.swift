//
//  SelectTypeFormViewController.swift
//  koin
//
//  Created by 김나훈 on 4/10/25.
//

import UIKit
import SnapKit

final class SelectTypeFormViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: RegisterFormViewModel

    enum UserType {
        case student
        case general
    }
    
    // MARK: - UI Components
    private let stepTextLabel = UILabel().then {
        $0.text = "3. 회원 유형 선택"
        $0.textColor = UIColor.appColor(.primary500)
        $0.font = UIFont.appFont(.pretendardMedium, size: 16)
    }
    
    private let stepLabel = UILabel().then {
        $0.text = "3 / 4"
        $0.textColor = UIColor.appColor(.primary500)
        $0.font = UIFont.appFont(.pretendardMedium, size: 16)
    }
    
    private let progressView = UIProgressView().then {
        $0.trackTintColor = UIColor.appColor(.neutral200)
        $0.progressTintColor = UIColor.appColor(.primary500)
        $0.layer.cornerRadius = 4
        $0.clipsToBounds = true
        $0.progress = 0.75

        NSLayoutConstraint.activate([
            $0.heightAnchor.constraint(equalToConstant: 3)
        ])
    }
    
    private let logoImageView = UIImageView().then {
        $0.image = UIImage.appImage(asset: .koinLogo)
    }
    
    private let studentButton = UIButton().then {
        $0.backgroundColor = .appColor(.sub500)
        $0.setTitle("한국기술교육대학교 학생", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = UIFont.appFont(.pretendardMedium, size: 16)
        $0.layer.cornerRadius = 8
    }
    
    private let generalButton = UIButton().then {
        $0.backgroundColor = .appColor(.primary500)
        $0.setTitle("외부인", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = UIFont.appFont(.pretendardMedium, size: 16)
        $0.layer.cornerRadius = 8
    }
    
    // MARK: - Init
    init(viewModel: RegisterFormViewModel) {
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
        setUpButtonTargets()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar(style: .empty)
    }

    private func setUpButtonTargets() {
        studentButton.addTarget(self, action: #selector(studentButtonTapped), for: .touchUpInside)
        generalButton.addTarget(self, action: #selector(generalButtonTapped), for: .touchUpInside)
    }
}

extension SelectTypeFormViewController {
    @objc private func studentButtonTapped() {
        viewModel.selectUserType(.student)
        userTypeButtonTapped()
    }

    @objc private func generalButtonTapped() {
        viewModel.selectUserType(.general)
        userTypeButtonTapped()
    }
    
    private func userTypeButtonTapped() {
        let viewController = EnterFormViewController(viewModel: viewModel)
        viewController.title = "회원가입"
        navigationController?.pushViewController(viewController, animated: true)
    }
}

// MARK: UI Settings
extension SelectTypeFormViewController {
    private func setUpLayouts() {
        [stepTextLabel, stepLabel, progressView, logoImageView, studentButton, generalButton].forEach {
            view.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        stepTextLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            $0.leading.equalToSuperview().offset(24)
        }

        stepLabel.snp.makeConstraints {
            $0.top.equalTo(stepTextLabel)
            $0.trailing.equalToSuperview().offset(-24)
        }

        progressView.snp.makeConstraints {
            $0.top.equalTo(stepTextLabel.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview().inset(24)
            $0.height.equalTo(3)
        }
        
        logoImageView.snp.makeConstraints {
            $0.top.equalTo(progressView.snp.bottom).offset(100)
            $0.centerX.equalToSuperview()
            $0.width.greaterThanOrEqualTo(96)
            $0.height.greaterThanOrEqualTo(56)
        }
        
        studentButton.snp.makeConstraints {
            $0.top.equalTo(logoImageView.snp.bottom).offset(80)
            $0.leading.equalToSuperview().offset(48)
            $0.trailing.equalToSuperview().offset(-48)
            $0.height.equalTo(48)
        }
        
        generalButton.snp.makeConstraints {
            $0.top.equalTo(studentButton.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(48)
            $0.trailing.equalToSuperview().offset(-48)
            $0.height.equalTo(48)
        }
    }
    
    private func configureView() {
        view.backgroundColor = .white
        setUpLayouts()
        setUpConstraints()
    }
}
