//
//  LostItemChatViewController.swift
//  koin
//
//  Created by 김나훈 on 2/16/25.
//

import Combine
import PhotosUI
import UIKit

final class LostItemChatViewController: UIViewController, PHPickerViewControllerDelegate {

    // MARK: - Properties
    private let viewModel: LostItemChatViewModel
    private let inputSubject: PassthroughSubject<LostItemChatViewModel.Input, Never> = .init()
    private var subscriptions: Set<AnyCancellable> = []
    var chatRoomId: Int { viewModel.chatRoomId }

    // MARK: - UI Components
    private let chatListView = ChatListView()

    init(viewModel: LostItemChatViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        let rightButton = UIBarButtonItem(image: UIImage.appImage(asset: .threeCircle), style: .plain, target: self, action: #selector(rightButtonTapped))
        navigationItem.rightBarButtonItem = rightButton
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        bind()
        inputSubject.send(.viewDidLoad)
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
            case .showChatHistory(let chatHistory): chatListView.update(model: ChatListModel(from: chatHistory))
            case .showToast(let message, let success):
                showToastMessage(message: message, intent: success ? .positive : .negative)
                if success { navigationController?.popViewController(animated: true) }
            case .updateTitle(let title):
                self.title = title
            }
        }.store(in: &subscriptions)

        chatListView.messageSendPublisher
            .sink { [weak self] message in
                self?.inputSubject.send(.sendMessage(message, false))
            }
            .store(in: &subscriptions)

        chatListView.imageSendTappedPublisher
            .sink { [weak self] in
                self?.leftButtonTapped()
            }
            .store(in: &subscriptions)

        chatListView.imageTappedPublisher.sink { [weak self] imageUrl in
            self?.dismissKeyboard()

            let zoomedImageViewController = ZoomedImageViewControllerB(shouldShowTitle: false)
            zoomedImageViewController.configure(urls: [imageUrl], initialIndexPath: IndexPath(row: 0, section: 0))
            self?.present(zoomedImageViewController, animated: true, completion: nil)
        }.store(in: &subscriptions)
    }
}

extension LostItemChatViewController {

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

        let blockCheckModalViewController = LostItemBlockCheckModalViewController(onBlockButtonTapped: { [weak self] in
            self?.presentBlockUserConfirmationModal()
        })
        blockCheckModalViewController.modalPresentationStyle = .overFullScreen
        present(blockCheckModalViewController, animated: false)
    }

    private func presentBlockUserConfirmationModal() {
        let modalViewController = KoinModalViewController(configuration: .init(
            appearance: .new,
            content: .titles(
                mainTitleText: "이 사용자를 차단하시겠습니까?",
                subTitleText: "쪽지 수신 및 발신이 모두 차단됩니다."
            ),
            button: .buttons(
                leftButtonTitle: "닫기",
                rightButtonTitle: "차단하기",
                rightButtonAction: { [weak self] in
                    self?.inputSubject.send(.blockUser)
                }
            )
        ))
        present(modalViewController, animated: true)
    }

}

private extension LostItemChatViewController {
    func configureView() {
        view.backgroundColor = .appColor(.neutral0)
        view.addSubview(chatListView)
        chatListView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
}
