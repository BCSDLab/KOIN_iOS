//
//  LostItemDataButtonsView.swift
//  koin
//
//  Created by 홍기정 on 1/24/26.
//

import UIKit
import Combine

final class LostItemDataButtonsView: UIView {
    
    // MARK: - Properties
    let listButtonTappedPublisher = PassthroughSubject<Void, Never>()
    let deleteButtonTappedPublisher = PassthroughSubject<Void, Never>()
    let editButtonTappedPublisher = PassthroughSubject<Void, Never>()
    let changeStateButtonTappedPublisher = PassthroughSubject<Void, Never>()
    let chatButtonTappedPublisher = PassthroughSubject<Void, Never>()
    let reportButtonTappedPublisher = PassthroughSubject<Void, Never>()
    
    // MARK: - UI Components
    private let buttonsStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 16
    }
    private let changeStateView = UIView()
    
    private let changeStateLabel = UILabel().then {
        $0.text = "물건을 찾았나요?"
        $0.font = .appFont(.pretendardRegular, size: 12)
        $0.textColor = .appColor(.neutral500)
    }
    private let changeStateButton = UIButton().then {
        $0.backgroundColor = .appColor(.neutral400)
        $0.layer.cornerRadius = 11
        $0.clipsToBounds = true
    }
    private let changeStateCircleView = UIView().then {
        $0.backgroundColor = .appColor(.neutral0)
        $0.layer.applySketchShadow(color: .appColor(.neutral800), alpha: 0.04, x: 0, y: 1, blur: 4, spread: 0)
        $0.layer.cornerRadius = 8
        $0.clipsToBounds = true
        $0.isUserInteractionEnabled = false
    }
    
    private let buttonsView = UIView()
    
    private let listButton = DebouncedButton().then {
        var configuration = UIButton.Configuration.plain()
        configuration.attributedTitle = AttributedString("목록", attributes: AttributeContainer([
            .font : UIFont.appFont(.pretendardMedium, size: 12),
            .foregroundColor : UIColor.appColor(.neutral600)
        ]))
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12)
        $0.configuration = configuration
    }
    private let editButton = DebouncedButton().then {
        var configuration = UIButton.Configuration.plain()
        configuration.attributedTitle = AttributedString("수정", attributes: AttributeContainer([
            .font : UIFont.appFont(.pretendardMedium, size: 12),
            .foregroundColor : UIColor.appColor(.neutral600)
        ]))
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12)
        $0.configuration = configuration
    }
    private let deleteButton = DebouncedButton().then {
        var configuration = UIButton.Configuration.plain()
        configuration.attributedTitle = AttributedString("삭제", attributes: AttributeContainer([
            .font : UIFont.appFont(.pretendardMedium, size: 12),
            .foregroundColor : UIColor.appColor(.neutral600)
        ]))
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12)
        $0.configuration = configuration
    }
    private let chatButton = DebouncedButton().then {
        var configuration = UIButton.Configuration.plain()
        configuration.attributedTitle = AttributedString("쪽지 보내기", attributes: AttributeContainer([
            .font : UIFont.appFont(.pretendardMedium, size: 12),
            .foregroundColor : UIColor.appColor(.neutral600)
        ]))
        configuration.image = .appImage(asset: .chat)
        configuration.imagePadding = 4
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
        $0.configuration = configuration
    }
    private let reportButton = DebouncedButton().then {
        var configuration = UIButton.Configuration.plain()
        configuration.image = .appImage(asset: .siren)
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
        $0.configuration = configuration
    }
    private let separatorView = UIView().then {
        $0.backgroundColor = .appColor(.neutral100)
    }
    
    // MARK: - Initializer
    init() {
        super.init(frame: .zero)
        setAddTargets()
        configureView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension LostItemDataButtonsView {
    
    private func setAddTargets() {
        listButton.addTarget(self, action: #selector(listButtonTapped), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        changeStateButton.addTarget(self, action: #selector(changeStateButtonTapped), for: .touchUpInside)
        chatButton.addTarget(self, action: #selector(chatButtonTapped), for: .touchUpInside)
        reportButton.addTarget(self, action: #selector(reportButtonTapped), for: .touchUpInside)
    }
    
    @objc private func listButtonTapped() {
        listButtonTappedPublisher.send()
    }
    @objc private func deleteButtonTapped() {
        deleteButtonTappedPublisher.send()
    }
    @objc private func editButtonTapped() {
        editButtonTappedPublisher.send()
    }
    @objc private func changeStateButtonTapped() {
        if changeStateButton.backgroundColor != UIColor.appColor(.primary500) {
            changeStateButtonTappedPublisher.send()
        }
    }
    @objc private func chatButtonTapped() {
        chatButtonTappedPublisher.send()
    }
    @objc private func reportButtonTapped() {
        reportButtonTappedPublisher.send()
    }
}

extension LostItemDataButtonsView {
    
    func changeState() {
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.changeStateButton.backgroundColor = .appColor(.primary500)
            self?.changeStateCircleView.transform = CGAffineTransform(translationX: 24, y: 0)
            self?.changeStateCircleView.layer.shadowColor = UIColor.clear.cgColor
            
            self?.editButton.isHidden = true
        }
    }
    
    func configure(isMine: Bool, isOrganization: Bool, isFound: Bool, type: LostItemType) {
        
        changeStateLabel.text = type == .lost ? "물건을 찾았나요?" : "주인을 찾았나요?"
        
        changeStateView.isHidden = !(isMine && !isFound)
    
        editButton.isHidden = !isMine || isFound
        deleteButton.isHidden = !isMine
        
        chatButton.isHidden = isMine
        reportButton.isHidden = isMine || isOrganization
        
        if isOrganization {
            chatButton.snp.remakeConstraints {
                $0.trailing.equalToSuperview()
            }
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
}

extension LostItemDataButtonsView {
    
    private func configureButtons() {
        [listButton, editButton, deleteButton, chatButton, reportButton].forEach {
            $0.layer.masksToBounds = true
            $0.layer.cornerRadius = 4
            $0.backgroundColor = .appColor(.neutral300)
            $0.tintColor = .appColor(.neutral600)
        }
    }
    
    private func setUpLayouts() {
        [changeStateLabel, changeStateButton, changeStateCircleView].forEach {
            changeStateView.addSubview($0)
        }
        [listButton, editButton, deleteButton, chatButton, reportButton].forEach {
            buttonsView.addSubview($0)
        }
        [changeStateView, buttonsView].forEach {
            buttonsStackView.addArrangedSubview($0)
        }
        [buttonsStackView, separatorView].forEach {
            addSubview($0)
        }
    }
    private func setUpConstraints() {
        buttonsStackView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.bottom.equalToSuperview().offset(-22)
        }
        separatorView.snp.makeConstraints {
            $0.height.equalTo(6)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        changeStateButton.snp.makeConstraints {
            $0.width.equalTo(46)
            $0.height.equalTo(22)
            $0.top.trailing.bottom.equalTo(changeStateView)
        }
        changeStateCircleView.snp.makeConstraints {
            $0.width.height.equalTo(16)
            $0.centerY.equalTo(changeStateButton)
            $0.leading.equalTo(changeStateButton.snp.leading).offset(3)
        }
        changeStateLabel.snp.makeConstraints {
            $0.centerY.equalTo(changeStateButton)
            $0.trailing.equalTo(changeStateButton.snp.leading).offset(-4)
        }
        
        listButton.snp.makeConstraints {
            $0.height.equalTo(31)
            $0.top.leading.bottom.equalTo(buttonsView)
        }
        
        deleteButton.snp.makeConstraints {
            $0.height.equalTo(31)
            $0.top.trailing.bottom.equalTo(buttonsView)
        }
        editButton.snp.makeConstraints {
            $0.height.equalTo(31)
            $0.trailing.equalTo(deleteButton.snp.leading).offset(-8)
            $0.top.bottom.equalTo(buttonsView)
        }
        
        reportButton.snp.makeConstraints {
            $0.height.equalTo(31)
            $0.top.trailing.bottom.equalTo(buttonsView)
        }
        chatButton.snp.makeConstraints {
            $0.height.equalTo(31)
            $0.trailing.equalTo(reportButton.snp.leading).offset(-8)
            $0.top.bottom.equalTo(buttonsView)
        }
    }
    
    
    private func configureView() {
        configureButtons()
        setUpLayouts()
        setUpConstraints()
    }
}
