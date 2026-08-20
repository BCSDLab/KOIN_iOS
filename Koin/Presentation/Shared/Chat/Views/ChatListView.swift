//
//  ChatListView.swift
//  koin
//
//  Created by 홍기정 on 8/20/26.
//

import UIKit
import Combine
import SnapKit
import Then

final class ChatListView: UIView {
    
    // MARK: - Properties
    let messageSendPublisher = PassthroughSubject<String, Never>()
    let imageSendTappedPublisher = PassthroughSubject<Void, Never>()
    let imageTappedPublisher = PassthroughSubject<String, Never>()
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - UI Components
    private let tableView = ChatTableView()
    private let chatInputView = ChatInputView()
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        bind()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    func update(model: ChatListModel) {
        tableView.configure(model: model)
    }
}

// MARK: - Bind

private extension ChatListView {
    private func bind() {
        tableView.imageTappedPublisher
            .sink { [weak self] imageUrl in
                self?.imageTappedPublisher.send(imageUrl)
            }
            .store(in: &subscriptions)
        
        chatInputView.messageSendPublisher
            .sink { [weak self] message in
                self?.messageSendPublisher.send(message)
            }
            .store(in: &subscriptions)
        
        chatInputView.imageSendTappedPublisher
            .sink { [weak self] in
                self?.imageSendTappedPublisher.send()
            }
            .store(in: &subscriptions)
    }
}

// MARK: - Actions

private extension ChatListView {
    private func setGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapAround))
        tapGesture.cancelsTouchesInView = false
        tableView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func didTapAround() {
        endEditing(true)
    }
}

// MARK: - Configure

private extension ChatListView {
    private func configureView() {
        setGesture()
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }
    
    private func setUpStyles() {
        backgroundColor = UIColor.appColor(.neutral100)
        
        tableView.do {
            $0.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
            $0.backgroundColor = .white
            $0.separatorStyle = .none
            $0.showsVerticalScrollIndicator = false
        }
    }
    
    private func setUpLayouts() {
        [tableView, chatInputView].forEach {
            addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        tableView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(chatInputView.snp.top)
        }
        
        chatInputView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(keyboardLayoutGuide.snp.top)
        }
    }
}
