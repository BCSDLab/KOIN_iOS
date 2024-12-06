//
//  SelectDeptModalViewController.swift
//  koin
//
//  Created by 김나훈 on 12/6/24.
//

import Combine
import UIKit

final class SelectDeptModalViewController: UIViewController {
    
    let selectedDeptPublisher = PassthroughSubject<String?, Never>()
    private var departmentButtons: [UIButton] = []
    private let departments = [
        "디자인ㆍ건축공학부",
        "고용서비스정책학과",
        "기계공학부",
        "메카트로닉스공학부",
        "산업경영학부",
        "전기ㆍ전자ㆍ통신공학부",
        "컴퓨터공학부",
        "에너지신소재화학공학부",
        "HRD학과",
        "교양학부",
        "안전공학과",
        "융합학과"
    ]
    private var selectedDepartment: String? = nil
    private var selectedButton: UIButton? = nil
    
    private let messageLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardMedium, size: 18)
        $0.textColor = UIColor.appColor(.primary500)
        $0.text = "전공선택"
    }
    
    private let completeButton = UIButton().then {
        $0.backgroundColor = UIColor.appColor(.primary500)
        $0.setTitle("완료", for: .normal)
        $0.setTitleColor(UIColor.appColor(.neutral0), for: .normal)
        $0.titleLabel?.font = UIFont.appFont(.pretendardMedium, size: 15)
        $0.layer.cornerRadius = 4
        $0.layer.masksToBounds = true
    }
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 4
        view.layer.masksToBounds = true
        return view
    }()
    
    private let gridStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 4.8
        $0.distribution = .fillEqually
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
        completeButton.addTarget(self, action: #selector(completeButtonTapped), for: .touchUpInside)
        setupDepartments()
    }
    
    @objc private func completeButtonTapped() {
        selectedDeptPublisher.send(selectedDepartment)
        dismiss(animated: true, completion: nil)
    }

    private func setupDepartments() {
        departmentButtons.forEach { $0.removeFromSuperview() }
        departmentButtons.removeAll()
        
        let buttonsPerRow = 2
        var currentRow: UIStackView? = nil
        gridStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for (index, department) in departments.enumerated() {
            let button = createDepartmentButton(title: department)
            departmentButtons.append(button)
            if index % buttonsPerRow == 0 {
                currentRow = UIStackView()
                currentRow?.axis = .horizontal
                currentRow?.spacing = 4.8
                currentRow?.distribution = .fillEqually
                gridStackView.addArrangedSubview(currentRow!)
            }
            
            currentRow?.addArrangedSubview(button)
        }
        
        view.layoutIfNeeded()
    }
    
    private func createDepartmentButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(UIColor.appColor(.neutral800), for: .normal)
        button.titleLabel?.font = UIFont.appFont(.pretendardMedium, size: 14)
        button.layer.cornerRadius = 4
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.appColor(.neutral300).cgColor
        button.backgroundColor = .white
        button.addTarget(self, action: #selector(departmentButtonTapped(_:)), for: .touchUpInside)
        return button
    }
    
    @objc private func departmentButtonTapped(_ sender: UIButton) {
        guard let department = sender.title(for: .normal) else { return }
        
        if selectedButton == sender {
            sender.backgroundColor = .white
            sender.setTitleColor(UIColor.appColor(.neutral800), for: .normal)
            selectedButton = nil
            selectedDepartment = nil
        } else {
            departmentButtons.forEach { button in
                button.backgroundColor = .white
                button.setTitleColor(UIColor.appColor(.neutral800), for: .normal)
            }
            sender.backgroundColor = UIColor.appColor(.primary500)
            sender.setTitleColor(.white, for: .normal)
            selectedButton = sender
            selectedDepartment = department
        }
    }
}

extension SelectDeptModalViewController {
    
    private func setUpLayOuts() {
        [containerView].forEach {
            view.addSubview($0)
        }
        [messageLabel, gridStackView, completeButton].forEach {
            containerView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        containerView.snp.makeConstraints { make in
            make.centerX.equalTo(view.snp.centerX)
            make.centerY.equalTo(view.snp.centerY)
            make.width.equalTo(327)
            make.height.equalTo(323)
        }
        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.top).offset(18)
            make.leading.equalTo(containerView.snp.leading).offset(12)
        }
        gridStackView.snp.makeConstraints { make in
            make.top.equalTo(messageLabel.snp.bottom).offset(10)
            make.leading.equalTo(containerView.snp.leading).offset(12)
            make.trailing.equalTo(containerView.snp.trailing).offset(-12)
            make.height.equalTo(216)
        }
        completeButton.snp.makeConstraints { make in
            make.trailing.equalTo(containerView.snp.trailing).offset(-12)
            make.bottom.equalTo(containerView.snp.bottom).offset(-18)
            make.width.equalTo(60)
            make.height.equalTo(30)
        }
    }
    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
        view.backgroundColor = UIColor.appColor(.neutral800).withAlphaComponent(0.7)
    }
}
