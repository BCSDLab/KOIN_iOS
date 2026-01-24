//
//  EditLostItemImagesView.swift
//  koin
//
//  Created by 홍기정 on 1/22/26.
//

import UIKit
import Combine

final class EditLostItemImagesView: UIView {
    
    // MARK: - Properties
    private var type: LostItemType
    private var images: [Image]
    let dismissDropDownPublisher = PassthroughSubject<Void, Never>()
    let addImageButtonPublisher = PassthroughSubject<Void, Never>()
    private var subscriptions: Set<AnyCancellable> = []
    
    
    // MARK: - UI Components
    private let pictureLabel = UILabel().then {
        $0.font = .appFont(.pretendardMedium, size: 14)
        $0.textColor = .appColor(.neutral800)
        $0.text = "사진"
    }
    private lazy var pictureMessageLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardRegular, size: 12)
        $0.textColor = UIColor.appColor(.gray)
        $0.text = "\(type.description)물 사진을 업로드해주세요."
    }
    private lazy var pictureCountLabel = UILabel().then {
        $0.text = "\(images.count)/10"
        $0.font = UIFont.appFont(.pretendardRegular, size: 12)
        $0.textColor = UIColor.appColor(.gray)
    }
    let imageUploadCollectionView: LostItemImageCollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = LostItemImageCollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.appColor(.neutral100)
        return collectionView
    }()
    private let addPictureButton = UIButton().then {
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage.appImage(asset: .picture)
        var text = AttributedString("사진 추가하기")
        text.font = UIFont.appFont(.pretendardMedium, size: 14)
        configuration.attributedTitle = text
        configuration.imagePadding = 4
        configuration.baseForegroundColor = UIColor.appColor(.primary600)
        $0.backgroundColor = UIColor.appColor(.info200)
        $0.configuration = configuration
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 8
        $0.layer.applySketchShadow(color: UIColor.appColor(.neutral800), alpha: 0.04, x: 0, y: 2, blur: 4, spread: 0)
    }
    
    // MARK: - Initializer
    init(type: LostItemType,
         images: [Image]
    ) {
        self.type = type
        self.images = images
        imageUploadCollectionView.updateImageUrls(images.map { $0.imageUrl })
        super.init(frame: .zero)
        configureView()
        bind()
        setAddTargets()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func bind() {
        imageUploadCollectionView.imageCountPublisher.sink { [weak self] urls in
            self?.addPictureButton.isEnabled = urls.count < 10
            self?.pictureCountLabel.text = "\(urls.count)/10"
        }.store(in: &subscriptions)
        
        imageUploadCollectionView.shouldDismissDropDownKeyBoardPublisher.sink { [weak self] in
            self?.dismissDropDownPublisher.send()
            self?.endEditing(true)
        }.store(in: &subscriptions)
        
    }
    
    private func setAddTargets() {
        addPictureButton.addTarget(self, action: #selector(addImageButtonTapped), for: .touchUpInside)
    }
    
    @objc private func addImageButtonTapped() {
        dismissDropDownPublisher.send()
        addImageButtonPublisher.send()
        endEditing(true)
    }
}

extension EditLostItemImagesView {
    
    private func setUpLayouts() {
        [pictureLabel, pictureMessageLabel, pictureCountLabel, imageUploadCollectionView, addPictureButton].forEach {
            addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        pictureLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
            $0.height.equalTo(22)
        }
        pictureMessageLabel.snp.makeConstraints {
            $0.top.equalTo(pictureLabel.snp.bottom)
            $0.leading.equalToSuperview()
            $0.height.equalTo(19)
        }
        pictureCountLabel.snp.makeConstraints {
            $0.top.equalTo(pictureMessageLabel)
            $0.trailing.equalToSuperview()
            $0.height.equalTo(pictureMessageLabel)
        }
        imageUploadCollectionView.snp.makeConstraints {
            $0.top.equalTo(pictureMessageLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(123)
        }
        addPictureButton.snp.makeConstraints {
            $0.top.equalTo(imageUploadCollectionView.snp.bottom).offset(12)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
    }
}
