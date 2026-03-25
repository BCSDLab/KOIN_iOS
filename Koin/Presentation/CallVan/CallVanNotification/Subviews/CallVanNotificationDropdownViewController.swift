//
//  CallVanNotificationDropdownViewController.swift
//  koin
//
//  Created by 홍기정 on 3/5/26.
//

import UIKit
import SnapKit
import Then

final class CallVanNotificationDropdownViewController: UIViewController {
    
    // MARK: - Properties
    private let onReadButtonTapped: ()->Void
    private let onDeleteButtonTapped: ()->Void
    
    // MARK: - UI Components
    private let dropDownView = UIView()
    private let readButton = UIButton()
    private let dropDownSeparatorView = UIView()
    private let deleteButton = UIButton()
    
    // MARK: - Initializer
    init(onReadButtonTapped: @escaping () -> Void, onDeleteButtonTapped: @escaping () -> Void) {
        self.onReadButtonTapped = onReadButtonTapped
        self.onDeleteButtonTapped = onDeleteButtonTapped
        super.init(nibName: nil, bundle: nil)
        configureView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
}

extension CallVanNotificationDropdownViewController {
    
    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
        setAddTargets()
        setUpGesture()
    }
    
    private func setUpStyles() {
        dropDownView.do {
            $0.backgroundColor = UIColor.appColor(.neutral50)
            $0.layer.cornerRadius = 8
            $0.layer.applySketchShadow(color: .black, alpha: 0.04, x: 0, y: 2, blur: 4, spread: 0)
        }
        readButton.do {
            var configuration = UIButton.Configuration.plain()
            configuration.attributedTitle = AttributedString("모두 읽음으로 표시", attributes: AttributeContainer([
                .font : UIFont.appFont(.pretendardRegular, size: 12),
                .foregroundColor : UIColor.appColor(.neutral800)
            ]))
            configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12)
            $0.configuration = configuration
            $0.backgroundColor = .clear
        }
        dropDownSeparatorView.do {
            $0.backgroundColor = UIColor.appColor(.neutral200)
        }
        deleteButton.do {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .left
            var configuration = UIButton.Configuration.plain()
            configuration.attributedTitle = AttributedString("알림 전체 삭제", attributes: AttributeContainer([
                .font : UIFont.appFont(.pretendardRegular, size: 12),
                .foregroundColor : UIColor.appColor(.danger700),
                .paragraphStyle : paragraphStyle
            ]))
            configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12)
            $0.configuration = configuration
            $0.backgroundColor = .clear
        }
    }
    
    private func setUpLayouts() {
        [dropDownView, readButton, dropDownSeparatorView, deleteButton].forEach {
            view.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        dropDownView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(40)
            $0.trailing.equalToSuperview().offset(-24)
        }
        readButton.snp.makeConstraints {
            $0.height.equalTo(35)
            $0.top.equalTo(dropDownView)
            $0.leading.trailing.equalTo(dropDownView).inset(4)
        }
        dropDownSeparatorView.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.top.equalTo(readButton.snp.bottom)
            $0.leading.trailing.equalTo(dropDownView).inset(12)
        }
        deleteButton.snp.makeConstraints {
            $0.height.equalTo(35)
            $0.top.equalTo(dropDownSeparatorView.snp.bottom)
            $0.leading.equalTo(readButton)
            $0.bottom.equalTo(dropDownView)
        }
    }
}

extension CallVanNotificationDropdownViewController {
    
    private func setAddTargets() {
        readButton.addTarget(self, action: #selector(readButtonTapped), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
    }
    
    @objc private func readButtonTapped() {
        dismiss(animated: true) { [weak self] in
            self?.onReadButtonTapped()
        }
    }
    
    @objc private func deleteButtonTapped() {
        dismiss(animated: true) { [weak self] in
            self?.onDeleteButtonTapped()
        }
    }
}

extension CallVanNotificationDropdownViewController {
    
    private func setUpGesture() {
        let tapAroundGesture = UITapGestureRecognizer(target: self, action: #selector(didTapAround))
        view.addGestureRecognizer(tapAroundGesture)
    }
    
    @objc private func didTapAround() {
        dismiss(animated: true)
    }
}
