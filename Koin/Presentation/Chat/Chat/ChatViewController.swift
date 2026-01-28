//
//  ChatViewController.swift
//  koin
//
//  Created by 김나훈 on 2/16/25.
//

import Combine
import PhotosUI
import UIKit

final class ChatViewController: UIViewController, UITextViewDelegate, PHPickerViewControllerDelegate {
    //
    // MARK: - Properties
    private let viewModel: ChatViewModel
    private let inputSubject: PassthroughSubject<ChatViewModel.Input, Never> = .init()
    private var subscriptions: Set<AnyCancellable> = []
    private var messageInputBottomConstraint: NSLayoutConstraint!
    private var textViewHeightConstraint: NSLayoutConstraint!
    
    // MARK: - UI Components
    private let bottomBackgrounView = UIView().then {
        $0.backgroundColor = .appColor(.neutral100)
    }
    private let messageInputView = UIView().then {
        $0.backgroundColor = .appColor(.neutral100)
    }
    
    private let leftButton = UIButton().then {
        $0.setImage(UIImage.appImage(asset: .gallery), for: .normal)
    }
    
    private let textView = UITextView().then {
        $0.isScrollEnabled = false
        $0.font = UIFont.systemFont(ofSize: 16)
        $0.backgroundColor = .appColor(.neutral0)
        $0.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        $0.layer.cornerRadius = 12
        $0.text = "메세지 보내기"
        $0.textColor = .appColor(.neutral500)
    }
    
    private let sendButton = UIButton().then {
        $0.setImage(UIImage.appImage(asset: .send), for: .normal)
    }
    
    private let blockCheckModalViewController = BlockCheckModalViewController().then {
        $0.modalPresentationStyle = .overFullScreen
        $0.modalTransitionStyle = .crossDissolve
    }
    
    private let chatHistoryTableView = ChatHistoryTableView().then {
        $0.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 16, right: 0)
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
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        leftButton.addTarget(self, action: #selector(leftButtonTapped), for: .touchUpInside)
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        textView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        inputSubject.send(.fetchChatDetail)
        configureNavigationBar(style: .empty)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        inputSubject.send(.viewWillDisappear)
    }
    
    // MARK: - Bind
    
    private func bind() {
        let outputSubject = viewModel.transform(with: inputSubject.eraseToAnyPublisher())
        outputSubject.receive(on: DispatchQueue.main).sink { [weak self] output in
            guard let self else { return }
            switch output {
            case .showChatHistory(let chatHistory): chatHistoryTableView.setChatHistory(item: chatHistory)
            case .showToast(let message, let success):
                showToast(message: message)
                if success { navigationController?.popViewController(animated: true) }
            }
        }.store(in: &subscriptions)
        
        blockCheckModalViewController.buttonPublihser.sink { [weak self] in
            guard let self else { return }
            print("buttonPublihser tapped")
            let onRightButtonTapped: ()->Void = { [weak self] in
                self?.inputSubject.send(.blockUser)
            }
            let modalViewController = ModalViewControllerB(onRightButtonTapped: onRightButtonTapped, width: 301, height: 179, paddingBetweenLabels: 8, title: "이 사용자를 차단하시겠습니까?", subTitle: "쪽지 수신 및 발신이 모두 차단됩니다.", titleColor: .appColor(.neutral700), subTitleColor: .appColor(.gray), rightButtonText: "차단하기")
            modalViewController.modalTransitionStyle = .crossDissolve
            modalViewController.modalPresentationStyle = .overFullScreen
            dismiss(animated: true) { [weak self] in
                self?.present(modalViewController, animated: true)
            }
        }.store(in: &subscriptions)
        
        chatHistoryTableView.imageTapPublisher.sink { [weak self] imageUrl in
            self?.dismissKeyboard()
            
            let zoomedImageViewController = ZoomedImageViewControllerB(shouldShowTitle: false)
            zoomedImageViewController.configure(urls: [imageUrl], initialIndexPath: IndexPath(row: 0, section: 0))
            self?.present(zoomedImageViewController, animated: true, completion: nil)
        }.store(in: &subscriptions)
    }
}

extension ChatViewController{
    
    @objc private func sendButtonTapped() {
        if textView.text.isEmpty || textView.textColor == .appColor(.neutral500) { return }
        inputSubject.send(.sendMessage(textView.text, false))
        textView.text = ""
        textViewHeightConstraint.constant = 36
        UIView.animate(withDuration: 0.1) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func leftButtonTapped() {
        dismissKeyboard()
        presentImagePicker()
    }

    private func presentImagePicker() {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    // ✅ 사용자가 사진을 선택했을 때 실행되는 함수
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let provider = results.first?.itemProvider else { return }
        
        if provider.canLoadObject(ofClass: UIImage.self) {
            provider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                DispatchQueue.main.async {
                    if let selectedImage = image as? UIImage {
                        guard let imageData = selectedImage.jpegData(compressionQuality: 0.5) else { return }
                        self?.inputSubject.send(.uploadFile([imageData]))
                    }
                }
            }
        }
    }
    
    @objc private func rightButtonTapped() {
        dismissKeyboard()
        
        present(blockCheckModalViewController, animated: true)
    }
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let keyboardHeight = keyboardFrame.height
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.chatHistoryTableView.contentOffset.y += (keyboardHeight - UIApplication.bottomSafeAreaHeight())
        }
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
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .appColor(.neutral500) {
            textView.text = ""
            textView.textColor = .appColor(.neutral800)
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let size = CGSize(width: textView.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        
        let maxHeight: CGFloat = 120
        let minHeight: CGFloat = 36
        if estimatedSize.height >= maxHeight {
            textViewHeightConstraint.constant = maxHeight
            textView.isScrollEnabled = true
        } else if estimatedSize.height <= minHeight{
            textViewHeightConstraint.constant = minHeight
        } else {
            textViewHeightConstraint.constant = estimatedSize.height
        }
        
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = "메시지 보내기"
            textView.textColor = .appColor(.neutral500)
        }
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        if textView.text == "" {
            textView.text = "메시지 보내기"
            textView.textColor = .appColor(.neutral500)
        }
        return true
    }
}

extension ChatViewController {
    
    private func setUpLayOuts() {
        [bottomBackgrounView, chatHistoryTableView, messageInputView].forEach {
            view.addSubview($0)
        }
        [leftButton, textView, sendButton].forEach {
            messageInputView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        chatHistoryTableView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(messageInputView.snp.top)
        }
        messageInputView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.greaterThanOrEqualTo(50)
            make.bottom.equalTo(view.keyboardLayoutGuide.snp.top)
        }
        leftButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.bottom.equalTo(messageInputView.snp.bottom).offset(-8)
            make.size.equalTo(32)
        }
        sendButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-24)
            make.bottom.equalTo(messageInputView.snp.bottom).offset(-8)
            make.size.equalTo(32)
        }
        textView.snp.makeConstraints { make in
            make.leading.equalTo(leftButton.snp.trailing).offset(8)
            make.trailing.equalTo(sendButton.snp.leading).offset(-8)
            make.top.equalTo(messageInputView).offset(8)
            make.bottom.equalTo(messageInputView).offset(-8)
            textViewHeightConstraint = make.height.equalTo(36).priority(.high).constraint.layoutConstraints.first
        }
        bottomBackgrounView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.top.equalTo(messageInputView.snp.bottom)
        }
    }
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
        self.view.backgroundColor = .systemBackground
    }
}
