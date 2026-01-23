//
//  EditLostItemViewController.swift
//  koin
//
//  Created by 홍기정 on 1/22/26.
//

import Combine
import PhotosUI
import UIKit

final class EditLostItemViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: EditLostItemViewModel
    private let inputSubject = PassthroughSubject<EditLostItemViewModel.Input, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    
    private let scrollContentView = UIView()
    
    private lazy var headerView = EditLostItemHeaderView(type: viewModel.lostItemData.type)
    
    private let topSeparateView = UIView().then {
        $0.backgroundColor = UIColor.appColor(.neutral100)
    }
    
    private lazy var imagesView = EditLostItemImagesView(type: viewModel.lostItemData.type, images: viewModel.lostItemData.images)
    
    private lazy var categoryView = EditLostItemCategoryView(selectedCategory: viewModel.lostItemData.category)
    
    private lazy var foundDateView = EditLostItemFoundDateView(type: viewModel.lostItemData.type, foundDate: viewModel.lostItemData.foundDate)
    
    private lazy var foundPlaceView = EditLostItemFoundPlaceView(type: viewModel.lostItemData.type, foundPlace: viewModel.lostItemData.foundPlace)
    
    private lazy var contentView = EditLostItemContentView(type: viewModel.lostItemData.type, content: viewModel.lostItemData.content)
    
    private let bottomSeparateView = UIView().then {
        $0.backgroundColor = UIColor.appColor(.neutral100)
    }
    
    private let editButton = DebouncedButton().then {
        $0.setTitle("수정 완료", for: .normal)
        $0.titleLabel?.font = UIFont.appFont(.pretendardBold, size: 14)
        $0.backgroundColor = UIColor.appColor(.primary600)
        $0.layer.cornerRadius = 8
        $0.layer.masksToBounds = true
    }
    
    // MARK: - Initializer
    init(viewModel: EditLostItemViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = (viewModel.lostItemData.type == .lost ? "분실물 신고" : "습득물 신고" )
        configureView()
        bind()
        setAddTarget()
        hideKeyboardWhenTappedAround()
        addObserver()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        configureNavigationBar(style: .empty)
    }
    
    private func bind() {
        viewModel.transform(with: inputSubject.eraseToAnyPublisher()).sink { [weak self] output in
            guard let self else { return }
            switch output {
            case .addImageUrl(let url):
                imagesView.imageUploadCollectionView.addImageUrl(url)
            case .showToast(let message):
                showToast(message: message)
            }
        }.store(in: &subscriptions)
        
        imagesView.addImageButtonPublisher.sink { [weak self] in
            self?.addImageButtonTapped()
        }.store(in: &subscriptions)
        
        imagesView.dismissDropDownPublisher.sink { [weak self] in
            self?.foundDateView.dismissDropdown()
        }.store(in: &subscriptions)
        
        categoryView.dismissDropDownPublisher.sink { [weak self] in
            self?.foundDateView.dismissDropdown()
        }.store(in: &subscriptions)
        
        foundPlaceView.shouldDismissDropDownPublisher.sink { [weak self] in
            self?.foundDateView.dismissDropdown()
        }.store(in: &subscriptions)
        
        contentView.shouldDismissDropDownPublisher.sink { [weak self] in
            self?.foundDateView.dismissDropdown()
        }.store(in: &subscriptions)
    }
}

extension EditLostItemViewController {
    
    private func setAddTarget() {
        editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
    }
    
    @objc private func editButtonTapped() {
        if categoryView.isValid && foundDateView.isValid && foundPlaceView.isValid {
            // TODO: ViewModel 호출
        }
    }
}

extension EditLostItemViewController {
    
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
            bottom: keyBoardSize.size.height - (view.frame.height - scrollView.frame.maxY),
            right: 0
        )
        scrollView.contentInset = contentInset
        scrollView.scrollIndicatorInsets = contentInset
        

        guard let targetView = [foundPlaceView.locationTextField,
                                contentView.contentTextView].first(where: { $0.isFirstResponder }) else {
            return
        }
        
        var rect = targetView.convert(targetView.bounds, to: scrollView)
        rect.size.height += 16
        scrollView.scrollRectToVisible(rect, animated: true)
    }
    
    @objc private func keyBoardWillHide(_ notification: NSNotification) {
        let contentInset = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
        scrollView.scrollIndicatorInsets = contentInset
    }
}

extension EditLostItemViewController: PHPickerViewControllerDelegate {
    
    private func addImageButtonTapped() {
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
        inputSubject.send(.uploadFile([imageData]))
    }
}

extension EditLostItemViewController {
    
    private func setUpLayOuts() {
        [headerView, topSeparateView, imagesView, categoryView, foundPlaceView, contentView, foundDateView].forEach {
            scrollContentView.addSubview($0)
        }
        [scrollContentView].forEach {
            scrollView.addSubview($0)
        }
        [bottomSeparateView, editButton, scrollView].forEach {
            view.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        scrollView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(bottomSeparateView.snp.top)
        }
        scrollContentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }
        
        headerView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
        topSeparateView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(6)
        }
        imagesView.snp.makeConstraints {
            $0.top.equalTo(topSeparateView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(24)
        }
        categoryView.snp.makeConstraints {
            $0.top.equalTo(imagesView.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(24)
        }
        foundDateView.snp.makeConstraints {
            $0.top.equalTo(categoryView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(24)
        }
        foundPlaceView.snp.makeConstraints {
            $0.top.equalTo(foundDateView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(24)
        }
        contentView.snp.makeConstraints {
            $0.top.equalTo(foundPlaceView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.bottom.equalToSuperview().offset(-16)
        }
        
        bottomSeparateView.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(editButton.snp.top).offset(-24)
        }
        editButton.snp.makeConstraints {
            $0.width.equalTo(160)
            $0.height.equalTo(38)
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
        }
    }
    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
        self.view.backgroundColor = .appColor(.neutral0)
    }
}
