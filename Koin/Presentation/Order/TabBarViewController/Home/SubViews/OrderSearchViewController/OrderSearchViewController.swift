//
//  OrderSearchViewController.swift
//  koin
//
//  Created by 이은지 on 6/20/25.
//

import UIKit

final class OrderSearchViewController: UIViewController {
    
    // MARK: - UI Components
    
    // MARK: - Initialization
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "검색"
        configureView()
        setupBackButton()
        setupRightButton()
    }
    
    // MARK: - Bind
    private func bind() {

    }

    private func setupBackButton() {
        let backButton = UIBarButtonItem(image: UIImage.appImage(asset: .arrowBack)?.withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(backButtonTapped))
        backButton.tintColor = .black
        navigationItem.leftBarButtonItem = backButton
    }

    @objc private func backButtonTapped() {
        dismiss(animated: true, completion: nil)
    }

    private func setupRightButton() {
        let cartButton = UIBarButtonItem(image: UIImage.appImage(asset: .shoppingCart)?.withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(cartButtonTapped))
        cartButton.tintColor = .black
        navigationItem.rightBarButtonItem = cartButton
    }

    @objc private func cartButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
}

extension OrderSearchViewController {
    
    private func setUpLayOuts() {
//        view.addSubview(searchTextField)
    }
    
    private func setUpConstraints() {
//        searchTextField.snp.makeConstraints {
//            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
//            $0.leading.trailing.equalToSuperview().inset(16)
//            $0.height.equalTo(44)
//        }
    }
    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
        view.backgroundColor = UIColor.appColor(.newBackground)
    }
}

