//
//  RecruitChatViewController.swift
//  koin
//
//  Created by 홍기정 on 9/28/26.
//

import UIKit
import PhotosUI
import Combine
import SnapKit
import Then

final class RecruitChatViewController: UIViewController {

    // MARK: - Properties
    private let viewModel: RecruitChatViewModel
    private let inputSubject = PassthroughSubject<RecruitChatViewModel.Input, Never>()
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - UI Components
    private let chatListView = ChatListView()
    
    private let titleStackView = UIStackView()
    private let titleLabel = UILabel()
    private let peopleImageView = UIImageView()
    private let participantsLabel = UILabel()

    // MARK: - Initializer
    init(viewModel: RecruitChatViewModel) {
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
        setUpObservers()
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
}

extension RecruitChatViewController {

    private func bind() {
        viewModel.transform(with: inputSubject.eraseToAnyPublisher())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] output in
                guard let self else { return }
                
                switch output {
                case .updateData(let data):
                    configureNavigationTitle(data)
                case .updateMessages(let messages):
                    chatListView.update(model: ChatListModel(from: messages))
                case .showToast(let message):
                    showToastMessage(message: message, bottomInset: 60)
                }
            }
            .store(in: &subscriptions)
        
        chatListView.messageSendPublisher
            .sink { [weak self] message in
                self?.inputSubject.send(.sendText(text: message))
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
                self?.presentZoomedImageViewControllerB(imageUrl)
            }
            .store(in: &subscriptions)
    }
}

extension RecruitChatViewController {
    private func setUpObservers() {
        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
            .sink { [weak self] _ in
                self?.inputSubject.send(.viewWillAppear)
            }
            .store(in: &subscriptions)
        
        NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)
            .sink { [weak self] _ in
                self?.inputSubject.send(.viewWillDisappear)
            }
            .store(in: &subscriptions)
    }
}

extension RecruitChatViewController {
    private func configureNavigationTitle(_ data: RecruitChatData) {
        titleLabel.text = data.chatRoomName
        
        if data.chatRoomType == .team,
           let currentMemberCount = data.currentMemberCount,
           let maximumMemberCount = data.maximumMemberCount {
            participantsLabel.text = "\(currentMemberCount)/\(maximumMemberCount)"
        } else {
            peopleImageView.isHidden = true
            participantsLabel.isHidden = true
        }

        navigationItem.titleView = titleStackView
    }
}

extension RecruitChatViewController: PHPickerViewControllerDelegate {
    private func presentImagePicker() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }

    func picker(
        _ picker: PHPickerViewController,
        didFinishPicking results: [PHPickerResult]
    ) {
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
        inputSubject.send(.sendImage(image: imageData))
    }
}

extension RecruitChatViewController {
    private func presentZoomedImageViewControllerB(_ imageUrl: String) {
        let viewController = ZoomedImageViewControllerB(shouldShowTitle: false)
        viewController.configure(url: imageUrl)
        viewController.modalTransitionStyle = .crossDissolve
        viewController.modalPresentationStyle = .overFullScreen
        present(viewController, animated: true)
    }
}

extension RecruitChatViewController {
    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }

    private func setUpStyles() {
        view.backgroundColor = UIColor.appColor(.neutral100)

        titleStackView.do {
            $0.axis = .horizontal
            $0.alignment = .center
            $0.spacing = 4
        }

        titleLabel.do {
            $0.textColor = UIColor.appColor(.neutral800)
            $0.font = UIFont.appFont(.pretendardMedium, size: 15)
        }

        peopleImageView.do {
            $0.image = UIImage.appImage(asset: .callVanListPeople)?.withRenderingMode(.alwaysTemplate)
            $0.tintColor = UIColor.appColor(.neutral600)
            $0.isHidden = true
        }

        participantsLabel.do {
            $0.textColor = UIColor.appColor(.neutral600)
            $0.font = UIFont.appFont(.pretendardRegular, size: 12)
            $0.isHidden = true
        }
    }

    private func setUpLayouts() {
        [titleLabel, peopleImageView, participantsLabel].forEach {
            titleStackView.addArrangedSubview($0)
        }
        view.addSubview(chatListView)
    }

    private func setUpConstraints() {
        peopleImageView.snp.makeConstraints {
            $0.size.equalTo(16)
        }

        chatListView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
}
