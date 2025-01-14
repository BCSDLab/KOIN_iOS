//
//  LostArticleReportViewController.swift
//  koin
//
//  Created by 김나훈 on 1/9/25.
//

import Combine
import PhotosUI
import UIKit

final class LostArticleReportViewController: UIViewController {
    
    // MARK: - Properties
    
    
    private let viewModel: LostArticleReportViewModel
    private let inputSubject: PassthroughSubject<LostArticleReportViewModel.Input, Never> = .init()
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    
    private let scrollView = UIScrollView().then { _ in
    }
    
    private let mainMessageLabel = UILabel().then {
        $0.text = "주인을 찾아요"
        $0.font = UIFont.appFont(.pretendardMedium, size: 18)
    }
    
    private let messageImageView = UIImageView().then {
        $0.image = UIImage.appImage(asset: .findPerson)
    }
    
    private let subMessageLabel = UILabel().then {
        $0.text = "습득한 물건을 자세히 설명해주세요!"
        $0.font = UIFont.appFont(.pretendardMedium, size: 12)
        $0.textColor = UIColor.appColor(.neutral500)
    }
    
    private let addLostArticleCollectionView: AddLostArticleCollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = AddLostArticleCollectionView(frame: .zero, collectionViewLayout: layout)
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
    
    init(viewModel: LostArticleReportViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        navigationItem.title = "습득물 신고"
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
                self?.addLostArticleCollectionView.addImageUrl(url: url, index: index)
            }
        }.store(in: &subscriptions)
    
        // TODO: 수정
        addLostArticleCollectionView.snp.updateConstraints { make in
            make.height.equalTo(addLostArticleCollectionView.calculateDynamicHeight())
        }
        
        addLostArticleCollectionView.heightChangedPublisher.sink { [weak self] in
            guard let self = self else { return }
            self.addLostArticleCollectionView.snp.updateConstraints { make in
                make.height.equalTo(self.addLostArticleCollectionView.calculateDynamicHeight())
            }
        }.store(in: &subscriptions)
        
        addLostArticleCollectionView.uploadImageButtonPublisher.sink { [weak self] index in
            self?.viewModel.selectedIndex = index
            self?.addImageButtonTapped()
        }.store(in: &subscriptions)
    }
    
}

extension LostArticleReportViewController: UITextViewDelegate, PHPickerViewControllerDelegate {
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
}

extension LostArticleReportViewController {
    
    private func setUpLayOuts() {
        [scrollView, writeButton, separateView].forEach {
            view.addSubview($0)
        }
        
        [mainMessageLabel, messageImageView, subMessageLabel, addLostArticleCollectionView].forEach {
            scrollView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(separateView.snp.top)
        }
        mainMessageLabel.snp.makeConstraints { make in
            make.top.equalTo(scrollView.snp.top).offset(9)
            make.leading.equalTo(view.snp.leading).offset(24)
            make.height.equalTo(29)
        }
        messageImageView.snp.makeConstraints { make in
            make.top.equalTo(mainMessageLabel.snp.top)
            make.leading.equalTo(mainMessageLabel.snp.trailing).offset(8)
            make.width.height.equalTo(24)
        }
        subMessageLabel.snp.makeConstraints { make in
            make.top.equalTo(mainMessageLabel.snp.bottom)
            make.leading.equalTo(mainMessageLabel.snp.leading)
            make.height.equalTo(19)
        }
        addLostArticleCollectionView.snp.makeConstraints { make in
            make.top.equalTo(subMessageLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview()
            make.width.equalTo(view.snp.width)
            make.height.equalTo(1)
            make.bottom.equalTo(scrollView.snp.bottom)
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
