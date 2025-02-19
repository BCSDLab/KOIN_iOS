//
//  ChatViewController.swift
//  koin
//
//  Created by 김나훈 on 2/16/25.
//

import Combine
import UIKit

final class ChatViewController: UIViewController, UITextViewDelegate {
    
    // MARK: - Properties
    private let viewModel: ChatViewModel
    private let inputSubject: PassthroughSubject<ChatViewModel.Input, Never> = .init()
    private var subscriptions: Set<AnyCancellable> = []
    private var messageInputBottomConstraint: NSLayoutConstraint!
    private var textViewHeightConstraint: NSLayoutConstraint!
    
    // MARK: - UI Components
    private let messageInputView = UIView().then {
        $0.backgroundColor = UIColor.systemGray6 // ✅ 회색 배경 설정
        $0.layer.cornerRadius = 16
        $0.layer.masksToBounds = true
    }
    
    private let leftButton = UIButton().then {
        $0.setImage(UIImage(systemName: "paperclip"), for: .normal)
        $0.tintColor = .darkGray
    }
    
    private let textView = UITextView().then {
        $0.isScrollEnabled = false
        $0.font = UIFont.systemFont(ofSize: 16)
        $0.backgroundColor = .clear // ✅ 배경 투명
        $0.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        $0.layer.cornerRadius = 8
    }
    
    private let sendButton = UIButton().then {
        $0.setImage(UIImage(systemName: "arrow.up.circle.fill"), for: .normal)
        $0.tintColor = .blue
    }
    
    private let blockModalViewController = ModalViewController(width: 301, height: 179, paddingBetweenLabels: 12, title: "이 사용자를 차단하시겠습니까?", subTitle: "쪽지 수신 및 발신이 모두 차단됩니다.", titleColor: UIColor.appColor(.neutral700), subTitleColor: UIColor.appColor(.gray), rightButtonText: "차단하기").then {
        $0.modalPresentationStyle = .overFullScreen
        $0.modalTransitionStyle = .crossDissolve
    }
    
    private let blockCheckModalViewController = BlockCheckModalViewController().then {
        $0.modalPresentationStyle = .overFullScreen
        $0.modalTransitionStyle = .crossDissolve
    }
    
    init(viewModel: ChatViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        navigationItem.title = viewModel.articleTitle
        
        let rightButton = UIBarButtonItem(image: UIImage.appImage(asset: .threeCircle), style: .plain, target: self, action: #selector(rightButtonTapped))
        navigationItem.rightBarButtonItem = rightButton
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        bind()
        inputSubject.send(.fetchChatDetail)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        textView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        configureNavigationBar(style: .empty)
    }
    
    // MARK: - Bind
    
    private func bind() {
        let outputSubject = viewModel.transform(with: inputSubject.eraseToAnyPublisher())
        outputSubject.receive(on: DispatchQueue.main).sink { [weak self] output in
            switch output {
            case .showChatList: print(1)
            case .showToast(let message, let success):
                self?.showToast(message: message)
                if success { self?.navigationController?.popViewController(animated: true) }
            }
        }.store(in: &subscriptions)
        blockModalViewController.rightButtonPublisher.sink { [weak self] _ in
            guard let self = self else { return }
            present(blockCheckModalViewController, animated: true)
        }.store(in: &subscriptions)
        
        blockCheckModalViewController.buttonPublihser.sink { [weak self] _ in
            self?.inputSubject.send(.blockUser)
        }.store(in: &subscriptions)
    }
}

extension ChatViewController{
    @objc private func rightButtonTapped() {
        present(blockCheckModalViewController, animated: true)
    }
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let keyboardHeight = keyboardFrame.height
        adjustInputViewPosition(up: true, height: keyboardHeight)
    }
    @objc private func keyboardWillHide(_ notification: Notification) {
        adjustInputViewPosition(up: false, height: 0)
    }
    private func adjustInputViewPosition(up: Bool, height: CGFloat) {
        messageInputBottomConstraint.constant = up ? -height : 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    @objc internal override func dismissKeyboard() {
        textView.resignFirstResponder()
    }
    func textViewDidChange(_ textView: UITextView) {
        let size = CGSize(width: textView.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        
        let maxHeight: CGFloat = 120
        if estimatedSize.height <= maxHeight {
            textViewHeightConstraint.constant = estimatedSize.height
        } else {
            textViewHeightConstraint.constant = maxHeight
            textView.isScrollEnabled = true
        }
        
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
}

extension ChatViewController {
    
    private func setUpLayOuts() {
        [messageInputView].forEach {
            view.addSubview($0)
        }
        [leftButton, textView, sendButton].forEach {
            messageInputView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        messageInputView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(8)
            make.height.greaterThanOrEqualTo(50)
            messageInputBottomConstraint = make.bottom.equalTo(view.safeAreaLayoutGuide).constraint.layoutConstraints.first
        }
        leftButton.snp.makeConstraints { make in
            make.leading.equalTo(messageInputView).offset(8)
            make.centerY.equalTo(messageInputView)
            make.size.equalTo(30)
        }
        sendButton.snp.makeConstraints { make in
            make.trailing.equalTo(messageInputView).offset(-8)
            make.centerY.equalTo(messageInputView)
            make.size.equalTo(30)
        }
        textView.snp.makeConstraints { make in
            make.leading.equalTo(leftButton.snp.trailing).offset(8)
            make.trailing.equalTo(sendButton.snp.leading).offset(-8)
            make.top.equalTo(messageInputView).offset(8)
            make.bottom.equalTo(messageInputView).offset(-8)
            textViewHeightConstraint = make.height.equalTo(40).priority(.high).constraint.layoutConstraints.first
        }
    }
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
        self.view.backgroundColor = .systemBackground
    }
}
