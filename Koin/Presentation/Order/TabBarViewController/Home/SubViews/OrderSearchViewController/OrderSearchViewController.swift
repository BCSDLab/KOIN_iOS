//
//  OrderSearchViewController.swift
//  koin
//
//  Created by 이은지 on 6/20/25.
//

import UIKit
import SnapKit

final class OrderSearchViewController: UIViewController {
    
    // MARK: - UI Components
    private let searchTextField = UITextField().then {
        let placeholder = NSAttributedString(
            string: "검색어를 입력해주세요.",
            attributes: [
                .font: UIFont.appFont(.pretendardRegular, size: 14),
                .foregroundColor: UIColor.appColor(.neutral400)
            ]
        )
        $0.attributedPlaceholder = placeholder

        $0.font = UIFont.appFont(.pretendardRegular, size: 14)
        $0.textColor = UIColor.appColor(.neutral500)
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 12

        let icon = UIImage.appImage(asset: .search)?
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 8, weight: .regular))
            .withRenderingMode(.alwaysTemplate)
        let leftImageView = UIImageView(image: icon)
        leftImageView.contentMode = .center
        leftImageView.tintColor = .appColor(.neutral500) 
        leftImageView.frame = CGRect(x: 0, y: 0, width: 24, height: 24)

        let leftContainer = UIView(frame: CGRect(x: 0, y: 0, width: 32, height: 40))
        leftImageView.center = CGPoint(x: 16, y: 20)
        leftContainer.addSubview(leftImageView)
        $0.leftView = leftContainer
        $0.leftViewMode = .always

        let rightContainer = UIView(frame: CGRect(x: 0, y: 0, width: 160, height: 40))
        $0.rightView = rightContainer
        $0.rightViewMode = .always

        $0.clearButtonMode = .whileEditing

        $0.layer.shadowColor   = UIColor.black.cgColor
        $0.layer.shadowOffset  = CGSize(width: 0, height: 2)
        $0.layer.shadowRadius  = 4
        $0.layer.shadowOpacity = 0.04
        $0.layer.masksToBounds = false
    }
    
    // MARK: - Initialization
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "검색"
        configureView()
        bind()
        setAddTarget()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchTextField.becomeFirstResponder()
    }

    
    // MARK: - Bind
    private func bind() {

    }

    private func setAddTarget() {
    }
}

extension OrderSearchViewController {
    
    @objc private func backButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func cartButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
}

extension OrderSearchViewController {
    
    private func setUpLayOuts() {
        [searchTextField].forEach {
            view.addSubview($0)
        }

    }
    
    private func setUpConstraints() {
        searchTextField.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            $0.horizontalEdges.equalToSuperview().inset(24)
            $0.height.equalTo(40)
        }
    }
    
    private func setupBackButton() {
        let backButton = UIBarButtonItem(image: UIImage.appImage(asset: .arrowBack)?.withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(backButtonTapped))
        backButton.tintColor = .black
        navigationItem.leftBarButtonItem = backButton
    }

    private func setupRightButton() {
        let cartButton = UIBarButtonItem(image: UIImage.appImage(asset: .shoppingCart)?.withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(cartButtonTapped))
        cartButton.tintColor = .black
        navigationItem.rightBarButtonItem = cartButton
    }
    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
        setupBackButton()
        setupRightButton()
        view.backgroundColor = UIColor.appColor(.newBackground)
    }
}

