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
    
    // MARK: - TitleView
    private lazy var titleLabel = UILabel()
    private lazy var peopleImageView = UIImageView()
    private lazy var paritipantsLabel = UILabel()
    private lazy var layoutGuide = UILayoutGuide()
    private lazy var titleView = UIView()
    
    // MARK: - UI Components
    private let chatListView = ChatListView()
    
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
        viewModel.transform(with: inputSubject.eraseToAnyPublisher()).receive(on: DispatchQueue.main).sink { [weak self] output in
            guard let self else { return }
            switch output {
            case let .showToast(message):
                showToastMessage(message: message)
            case let .update(callVanChat):
                chatListView.update(model: ChatListModel(from: callVanChat))
            case let .updateData(callVanData):
                configureNavigationBar(callVanData)
            }
        }.store(in: &subscriptions)

        chatListView.messageSendPublisher
            .sink { [weak self] message in
                self?.inputSubject.send(.sendMessage(message))
                self?.inputSubject.send(
                    .logEvent(
                        label: EventParameter.EventLabel.Campus.callvanChatSend,
                        category: .click,
                        value: ""
                    )
                )
            }
            .store(in: &subscriptions)

        chatListView.imageSendTappedPublisher
            .sink { [weak self] in
                self?.presentImagePicker()
            }
            .store(in: &subscriptions)

        chatListView.imageTappedPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] imageUrl in
                let zoomedImageViewController = ZoomedImageViewControllerB(shouldShowTitle: false)
                zoomedImageViewController.configure(url: imageUrl)
                zoomedImageViewController.modalTransitionStyle = .crossDissolve
                zoomedImageViewController.modalPresentationStyle = .overFullScreen
                self?.present(zoomedImageViewController, animated: true)
            }
            .store(in: &subscriptions)
    }
}

extension CallVanChatViewController: PHPickerViewControllerDelegate {
    
    private func presentImagePicker() {
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
        view.addSubview(chatListView)
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
        chatListView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
}
