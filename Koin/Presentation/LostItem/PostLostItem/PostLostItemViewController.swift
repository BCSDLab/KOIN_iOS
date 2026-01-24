//
//  LostArticleReportViewController.swift
//  koin
//
//  Created by 김나훈 on 1/9/25.
//

import Combine
import PhotosUI
import UIKit

protocol PostLostItemViewControllerDelegate: AnyObject {
    
    func appendData(_ lostItemData: LostItemData)
}

final class PostLostItemViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: PostLostItemViewModel
    private let inputSubject: PassthroughSubject<PostLostItemViewModel.Input, Never> = .init()
    private var subscriptions: Set<AnyCancellable> = []
    weak var delegate: PostLostItemViewControllerDelegate?
    
    
    // MARK: - UI Components
    private let addLostItemCollectionView: AddLostItemCollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = AddLostItemCollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()
    
    private let separateView = UIScrollView().then {
        $0.backgroundColor = UIColor.appColor(.neutral100)
    }
    
    private let writeButton = DebouncedButton().then {
        $0.setTitle("작성 완료", for: .normal)
        $0.titleLabel?.font = UIFont.appFont(.pretendardBold, size: 14)
        $0.backgroundColor = UIColor.appColor(.primary600)
        $0.layer.cornerRadius = 8
        $0.layer.masksToBounds = true
    }
    
    // MARK: - Initializer
    init(viewModel: PostLostItemViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
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
        addObserver()
        writeButton.throttle(interval: .seconds(3)) { [weak self] in
            self?.writeButtonTapped()
        }
        title = "\(viewModel.type.description)물 신고"
        
        addLostItemCollectionView.setType(type: viewModel.type)
        configureTapGestureToDismissKeyboardDropdown()
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
            case let .showToast(message):
                self?.showToast(message: message, success: true)
            case let .addImageUrl(url, index):
                self?.addLostItemCollectionView.addImageUrl(url: url, index: index)
            case let .navigateToLostItemData(lostItemData):
                self?.delegate?.appendData(lostItemData)
                self?.navigateToLostItemData(lostItemData.id)
            }
        }.store(in: &subscriptions)
        
        addLostItemCollectionView.uploadImageButtonPublisher.sink { [weak self] index in
            self?.viewModel.selectedIndex = index
            self?.addImageButtonTapped()
        }.store(in: &subscriptions)
        
        addLostItemCollectionView.logPublisher.sink { [weak self] value in
            self?.inputSubject.send(.logEvent(value.0, value.1, value.2))
        }.store(in: &subscriptions)

    }
}

extension PostLostItemViewController {
    
    private func addObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyBoardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyBoardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
    }
    
    @objc private func keyBoardWillShow(_ notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let keyBoardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        
        let contentInset = UIEdgeInsets(
            top: 0,
            left: 0,
            bottom: keyBoardSize.size.height - (view.frame.height - addLostItemCollectionView.frame.maxY),
            right: 0
        )
        addLostItemCollectionView.contentInset = contentInset

        guard let targetView = addLostItemCollectionView.firstResponder() else {
            return
        }
        
        var rect = targetView.convert(targetView.bounds, to: addLostItemCollectionView)
        rect.size.height += 16
        addLostItemCollectionView.scrollRectToVisible(rect, animated: true)
    }
    
    @objc private func keyBoardWillHide(_ notification: NSNotification) {
        let contentInset = UIEdgeInsets.zero
        addLostItemCollectionView.contentInset = contentInset
    }
}

extension PostLostItemViewController: UITextViewDelegate, PHPickerViewControllerDelegate {
    
    func collectAllCellData() -> [PostLostItemRequest] {
        var allCellData: [PostLostItemRequest] = []
        
        for index in 0..<addLostItemCollectionView.numberOfItems(inSection: 0) {
            let indexPath = IndexPath(item: index, section: 0)
            
            guard let cell = addLostItemCollectionView.cellForItem(at: indexPath) as? AddLostItemCollectionViewCell else {
                continue
            }
            
            let cellData = cell.getCellData()
            allCellData.append(cellData)
        }
        return allCellData
    }
    private func writeButtonTapped() {
        var isAllValid = true
        for index in 0..<addLostItemCollectionView.numberOfItems(inSection: 0) {
            let indexPath = IndexPath(item: index, section: 0)
            if let articleCell = addLostItemCollectionView.cellForItem(at: indexPath) as? AddLostItemCollectionViewCell {
                let isValid = articleCell.validateInputs()
                if !isValid {
                    isAllValid = false
                }
            }
        }
        if isAllValid {
            let allCellData = collectAllCellData()
            inputSubject.send(.postLostItem(allCellData))
            switch viewModel.type {
            case .lost: inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.lostItemWriteConfirm, .click, "작성완료"))
            case .found: inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.findUserWriteConfirm, .click, "작성완료"))
            }
        }
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
        inputSubject.send(.uploadFile([imageData]))
        
    }
    private func addImageButtonTapped() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    private func navigateToLostItemData(_ id: Int) {
        let userRepository = DefaultUserRepository(service: DefaultUserService())
        let lostItemRepository = DefaultLostItemRepository(service: DefaultLostItemService())
        let chatRepository = DefaultChatRepository(service: DefaultChatService())
        let checkLoginUseCase = DefaultCheckLoginUseCase(userRepository: userRepository)
        let fetchLostItemDataUseCase = DefaultFetchLostItemDataUseCase(repository: lostItemRepository)
        let fetchLostItemListUseCase = DefaultFetchLostItemListUseCase(repository: lostItemRepository)
        let changeLostItemStateUseCase = DefaultChangeLostItemStateUseCase(repository: lostItemRepository)
        let deleteLostItemUseCase = DefaultDeleteLostItemUseCase(repository: lostItemRepository)
        let createChatRoomUseCase = DefaultCreateChatRoomUseCase(chatRepository: chatRepository)
        let viewModel = LostItemDataViewModel(
            checkLoginUseCase: checkLoginUseCase,
            fetchLostItemDataUseCase: fetchLostItemDataUseCase,
            fetchLostItemListUseCase: fetchLostItemListUseCase,
            changeLostItemStateUseCase: changeLostItemStateUseCase,
            deleteLostItemUseCase: deleteLostItemUseCase,
            createChatRoomUseCase: createChatRoomUseCase,
            id: id)
        let viewController = LostItemDataViewController(viewModel: viewModel)
        viewController.delegate = (delegate as? LostItemDataViewControllerDelegate)
        replaceTopViewController(viewController, animated: true)
    }
}

extension PostLostItemViewController {
    
    private func configureTapGestureToDismissKeyboardDropdown() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboardDropdown))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboardDropdown() {
        addLostItemCollectionView.dismissDatePicker()
        dismissKeyboard()
    }
}

extension PostLostItemViewController {
    
    private func setUpLayOuts() {
        [addLostItemCollectionView, separateView, writeButton].forEach {
            view.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        addLostItemCollectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(separateView.snp.top)
        }
        separateView.snp.makeConstraints { make in
            make.bottom.equalTo(writeButton.snp.top).offset(-24)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(1)
        }
        writeButton.snp.makeConstraints { make in
            make.centerX.equalTo(view.snp.centerX)
            make.width.equalTo(160)
            make.height.equalTo(38)
            make.bottom.equalTo(view.snp.bottom).offset(-50)
        }
    }
    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
        self.view.backgroundColor = .systemBackground
    }
}
