//
//  CallVanChatViewController.swift
//  koin
//
//  Created by 홍기정 on 3/9/26.
//

import UIKit
import PhotosUI
import Combine
import SnapKit
import Then

final class CallVanChatViewController: UIViewController {
    
    // MARK: - Properties
    private let inputSubject = PassthroughSubject<CallVanChatViewModel.Input, Never>()
    private let viewModel: CallVanChatViewModel
    private var subscriptions: Set<AnyCancellable> = []
    private let textViewPlaceHolder = "메시지 보내기"
    
    // MARK: - TitleView
    private lazy var titleLabel = UILabel()
    private lazy var peopleImageView = UIImageView()
    private lazy var paritipantsLabel = UILabel()
    private lazy var layoutGuide = UILayoutGuide()
    private lazy var titleView = UIView()
    
    // MARK: - UI Components
    private let callVanChatTableView = CallVanChatTableView()
    private let wrapperView = UIView()
    private let sendImageButton = UIButton()
    private let messageTextView = UITextView()
    private let sendMessageButton = UIButton()
    
    // MARK: - Initializer
    init(viewModel: CallVanChatViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        setDelegate()
        setAddTargets()
        bind()
        configureNavigationBar(style: .empty)
        inputSubject.send(.viewDidLoad)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        inputSubject.send(.viewWillAppear)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        inputSubject.send(.viewWillDisappear)
    }
    
    private func bind() {
        viewModel.transform(with: inputSubject.eraseToAnyPublisher()).sink { [weak self] output in
            guard let self else { return }
            switch output {
            case let .showToast(message):
                showToastMessage(message: message)
            case let .update(callVanChat):
                callVanChatTableView.configure(callVanChat: callVanChat)
            case let .updateData(callVanData):
                configureNavigationBar(callVanData)
            }
        }.store(in: &subscriptions)
        
        callVanChatTableView.imageTappedPublisher.sink { [weak self] imageUrl in
            let zoomedImageViewController = ZoomedImageViewControllerB(shouldShowTitle: false)
            zoomedImageViewController.configure(url: imageUrl)
            zoomedImageViewController.modalTransitionStyle = .crossDissolve
            zoomedImageViewController.modalPresentationStyle = .overFullScreen
            self?.present(zoomedImageViewController, animated: true)
        }.store(in: &subscriptions)
    }
}

extension CallVanChatViewController {
    
    private func setAddTargets() {
        sendImageButton.addTarget(self, action: #selector(sendImageButtonTapped), for: .touchUpInside)
        sendMessageButton.addTarget(self, action: #selector(sendMessageButtonTapped), for: .touchUpInside)
    }
    
    @objc private func sendMessageButtonTapped() {
        guard messageTextView.textColor == UIColor.appColor(.neutral800) else {
            return
        }
        let text = messageTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if !text.isEmpty {
            inputSubject.send(.sendMessage(text))
            messageTextView.text = ""
        }
    }
}

extension CallVanChatViewController: PHPickerViewControllerDelegate {
    
    @objc private func sendImageButtonTapped() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let provider = results.first?.itemProvider else { return }
        
        if provider.canLoadObject(ofClass: UIImage.self) {
            provider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                DispatchQueue.main.async {
                    if let selectedImage = image as? UIImage {
                        self?.handleSelectedImage(image: selectedImage)
                    }
                }
            }
        }
    }
    
    private func handleSelectedImage(image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            return
        }
        inputSubject.send(.sendImage(imageData))
    }
}

extension CallVanChatViewController: UITextViewDelegate {
    
    private func setDelegate() {
        messageTextView.delegate = self
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.appColor(.neutral500) {
            textView.text = ""
            textView.textColor = UIColor.appColor(.neutral800)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 {
            textView.text = textViewPlaceHolder
            textView.textColor = UIColor.appColor(.neutral500)
        }
    }
}

extension CallVanChatViewController {
    
    private func configureNavigationBar(_ callVanData: CallVanData) {
        titleLabel.do {
            $0.text = "\(callVanData.departure) - \(callVanData.arrival)"
            $0.textColor = UIColor.appColor(.neutral800)
            $0.font = UIFont.appFont(.pretendardMedium, size: 15)
        }
        peopleImageView.do {
            $0.image = UIImage.appImage(asset: .callVanListPeople)?.withRenderingMode(.alwaysTemplate)
            $0.tintColor = UIColor.appColor(.neutral600)
        }
        paritipantsLabel.do {
            $0.text = "\(callVanData.currentParticipants)/\(callVanData.maxParticipants)"
            $0.textColor = UIColor.appColor(.neutral600)
            $0.font = UIFont.appFont(.pretendardRegular, size: 12)
        }
        
        navigationItem.titleView = titleView
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor.appColor(.neutral0)
        navigationItem.backButtonTitle = ""
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.compactAppearance = appearance
    }
}
extension CallVanChatViewController {
    
    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }
    
    private func setUpStyles() {
        view.backgroundColor = UIColor.appColor(.neutral100)
        
        // MARK: - UI Components
        callVanChatTableView.do {
            $0.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
            $0.backgroundColor = .white
            $0.separatorStyle = .none
            $0.showsVerticalScrollIndicator = false
        }
        wrapperView.do {
            $0.backgroundColor = UIColor.appColor(.neutral100)
        }
        sendImageButton.do {
            $0.setImage(UIImage.appImage(asset: .callVanSendImage), for: .normal)
            $0.backgroundColor = UIColor.appColor(.neutral0)
            $0.layer.cornerRadius = 12
            $0.clipsToBounds = true
        }
        messageTextView.do {
            let font = UIFont.appFont(.pretendardRegular, size: 12)
            let height: CGFloat = 32
            let topBottomInset = (height - font.lineHeight) / 2
            
            $0.isScrollEnabled = false
            $0.font = font
            $0.backgroundColor = UIColor.appColor(.neutral0)
            $0.textContainerInset = UIEdgeInsets(top: topBottomInset, left: 16, bottom: topBottomInset, right: 16)
            $0.layer.cornerRadius = 12
            $0.text = textViewPlaceHolder
            $0.textColor = UIColor.appColor(.neutral500)
        }
        sendMessageButton.do {
            $0.setImage(UIImage.appImage(asset: .callVanSendMessage), for: .normal)
            $0.layer.cornerRadius = 12
            $0.clipsToBounds = true
        }
    }
    
    private func setUpLayouts() {
        // MARK: - TitleView
        [titleLabel, peopleImageView, paritipantsLabel].forEach {
            titleView.addSubview($0)
        }
        [layoutGuide].forEach {
            titleView.addLayoutGuide($0)
        }
        
        // MARK: - UI Components
        [sendImageButton, messageTextView, sendMessageButton].forEach {
            wrapperView.addSubview($0)
        }
        [callVanChatTableView, wrapperView].forEach {
            view.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        // MARK: - TitleView
        layoutGuide.snp.makeConstraints {
            $0.center.equalTo(titleView)
        }
        titleLabel.snp.makeConstraints {
            $0.leading.centerY.equalTo(layoutGuide)
        }
        peopleImageView.snp.makeConstraints {
            $0.leading.equalTo(titleLabel.snp.trailing).offset(8)
            $0.centerY.equalTo(layoutGuide)
        }
        paritipantsLabel.snp.makeConstraints {
            $0.leading.equalTo(peopleImageView.snp.trailing).offset(4)
            $0.centerY.trailing.equalTo(layoutGuide)
        }
        
        // MARK: - UI Components
        callVanChatTableView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(wrapperView.snp.top)
        }
        wrapperView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.keyboardLayoutGuide.snp.top)
        }
        sendImageButton.snp.makeConstraints {
            $0.size.equalTo(32)
            $0.top.equalTo(wrapperView).offset(8)
            $0.leading.equalTo(wrapperView).offset(24)
        }
        sendMessageButton.snp.makeConstraints {
            $0.size.equalTo(32)
            $0.top.equalTo(wrapperView).offset(8)
            $0.trailing.equalTo(wrapperView).offset(-24)
        }
        messageTextView.snp.makeConstraints {
            $0.top.bottom.equalTo(wrapperView).inset(8)
            $0.leading.equalTo(sendImageButton.snp.trailing).offset(8)
            $0.trailing.equalTo(sendMessageButton.snp.leading).offset(-8)
            $0.bottom.greaterThanOrEqualTo(sendImageButton)
        }
    }
}
