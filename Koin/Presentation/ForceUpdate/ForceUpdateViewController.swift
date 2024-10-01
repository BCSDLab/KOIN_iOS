//
//  ForceUpdateViewController.swift
//  koin
//
//  Created by 김나훈 on 10/1/24.
//

import Combine
import UIKit

final class ForceUpdateViewController: UIViewController {
    // MARK: - Properties
    
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    
    private let scrollView = UIScrollView().then { scrollView in
    }
    
    private let closeButton = UIButton().then { button in
        button.setImage(UIImage.appImage(asset: .power), for: .normal)
    }
    
    private let logoImageView = UIImageView().then { imageView in
        imageView.image = UIImage.appImage(asset: .koinBigLogo)
    }
    
    private let titleLabel = UILabel().then { label in
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 10
        
        let attributedText = NSMutableAttributedString(
            string: "코인을 사용하기 위해\n업데이트가 꼭 필요해요.",
            attributes: [
                .font: UIFont.appFont(.pretendardBold, size: 20),
                .paragraphStyle: paragraphStyle,
                .foregroundColor: UIColor.appColor(.neutral0)
            ]
        )
        label.attributedText = attributedText
        label.textAlignment = .center
        label.numberOfLines = 2
    }
    
    private let descriptionLabel = UILabel().then { label in
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        let attributedText = NSMutableAttributedString(
            string: "코인 앱을 실행해 주셔서 감사합니다!\n코인을 사용하기 위해 아래 버튼을 눌러\n스토어에서 업데이트를 진행해 주세요.",
            attributes: [
                .font: UIFont.appFont(.pretendardRegular, size: 14),
                .paragraphStyle: paragraphStyle,
                .foregroundColor: UIColor.appColor(.neutral0)
            ]
        )
        label.attributedText = attributedText
        label.textAlignment = .center
        label.numberOfLines = 3
    }
    
    
    private let updateButton = UIButton().then { button in
        button.setTitle("업데이트하기", for: .normal)
        button.backgroundColor = UIColor.appColor(.sub500)
        button.setTitleColor(UIColor.appColor(.neutral0), for: .normal)
        button.titleLabel?.font = UIFont.appFont(.pretendardMedium, size: 18)
    }
    
    private let errorCheckButton = UIButton().then { button in
        let attributedTitle = NSAttributedString(
            string: "이미 업데이트를 하셨나요?",
            attributes: [
                .font: UIFont.appFont(.pretendardMedium, size: 12),
                .foregroundColor: UIColor.appColor(.neutral0),
                .underlineStyle: NSUnderlineStyle.single.rawValue // 여기에 'none' 값을 주어도 기본 설정은 밑줄 없음
            ]
        )
        
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.backgroundColor = .clear
    }
    
    private let companyLabel = UILabel().then { label in
        label.text = "Copyright 2024. BCSD Lab. All right reserved."
        label.textColor = UIColor.appColor(.neutral0)
        label.font = UIFont.appFont(.pretendardMedium, size: 12)
    }
    
    private let updateModalViewController: UpdateModelViewController = {
        let viewController = UpdateModelViewController()
        viewController.modalPresentationStyle = .overFullScreen
        viewController.modalTransitionStyle = .crossDissolve
        return viewController
    }()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        bind()
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        updateButton.addTarget(self, action: #selector(updateButtonTapped), for: .touchUpInside)
        errorCheckButton.addTarget(self, action: #selector(errorCheckButtonTapped), for: .touchUpInside)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        navigationController?.navigationBar.isHidden = false
    }
    
    private func bind() {
        updateModalViewController.openStoreButtonPublisher.sink { [weak self] in
            self?.openStore()
        }.store(in: &subscriptions)
        
    }
    
}

extension ForceUpdateViewController {
    @objc private func closeButtonTapped() {
        navigationController?.popViewController(animated: false)
    }
    
    @objc private func updateButtonTapped() {
        openStore()
    }
    
    private func openStore() {
        if let url = URL(string: "https://itunes.apple.com/app/id1500848622"),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @objc private func errorCheckButtonTapped() {
        present(updateModalViewController, animated: true, completion: nil)
    }
    
}

extension ForceUpdateViewController {
    
    private func setUpLayOuts() {
        view.addSubview(scrollView)
        [closeButton, logoImageView, titleLabel, descriptionLabel, updateButton, errorCheckButton, companyLabel].forEach {
            scrollView.addSubview($0)
        }
    }
    private func setUpConstraints() {
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        closeButton.snp.makeConstraints { make in
            make.top.equalTo(scrollView.snp.top).offset(18)
            make.trailing.equalTo(view.snp.trailing).offset(-29)
            make.width.equalTo(24)
            make.height.equalTo(24)
        }
        logoImageView.snp.makeConstraints { make in
            make.top.equalTo(closeButton.snp.bottom).offset(7)
            make.centerX.equalTo(view.snp.centerX)
            make.width.equalTo(150)
            make.height.equalTo(200)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(logoImageView.snp.bottom).offset(72)
            make.centerX.equalTo(view.snp.centerX)
        }
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(48)
            make.centerX.equalTo(view.snp.centerX)
        }
        updateButton.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(72)
            make.centerX.equalTo(view.snp.centerX)
            make.width.equalTo(191)
            make.height.equalTo(48)
        }
        errorCheckButton.snp.makeConstraints { make in
            make.top.equalTo(updateButton.snp.bottom).offset(16)
            make.centerX.equalTo(view.snp.centerX)
            make.width.equalTo(191)
            make.height.equalTo(48)
        }
        companyLabel.snp.makeConstraints { make in
            make.top.equalTo(errorCheckButton.snp.bottom).offset(103)
            make.centerX.equalTo(view.snp.centerX)
            make.bottom.equalTo(scrollView.snp.bottom)
        }
        
    }
    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
        self.view.backgroundColor = UIColor.appColor(.primary600)
    }
}
