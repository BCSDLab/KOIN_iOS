//
//  DiningReportModalView.swift
//  koin
//
//  Created by 홍기정 on 10/18/26.
//

import UIKit
import SnapKit
import Then

final class DiningReportModalView: UIView {

    // MARK: - Closures
    private let onDismissButtonTapped: ()->Void
    private let onPlaceSelected: (DiningItem)->Void
    private let onSelectImageButtonTapped: ()->Void
    private let onCompleteButtonTapped: (
        _ selectedItem: DiningItem,
        _ evidenceImage: UIImage
    ) -> Void

    // MARK: - Properties
    private let diningItems: [DiningItem]
    private let evidenceImageDescriptions: [String] = [
        "• 배식대의 품절 안내판 촬영",
        "• 학식당 앞 품절 식판 안내",
        "• 품절 상태 확인 가능한 사진",
        "• 품절 미확인 시 제보 반려",
        "• 앱 내 직접 촬영 사진만 가능"
    ]

    // MARK: - State
    private(set) var selectedItem: DiningItem? {
        didSet {
            updatePlaceButtons()
            updateCompleteButton()
        }
    }
    private(set) var evidenceImage: UIImage? {
        didSet {
            updateEvidenceImage()
            updateCompleteButton()
        }
    }
    private var isButtonEnabled: Bool {
        selectedItem != nil && evidenceImage != nil
    }

    // MARK: - UI Components
    private let stackView = UIStackView()

    private let headerView = UIView()
    private let headerLabel = UILabel()
    private let dismissButton = UIButton()

    private let placeView = UIStackView()
    private let placeTitleLabel = UILabel()
    private let placeButtonStackView = UIStackView()
    private var placeButtons: [UIButton] = []

    private let evidenceView = UIStackView()
    private let evidenceTitleLabel = UILabel()
    private let evidenceContentView = UIView()
    private let selectImageButton = UIButton()
    private let uploadedImageView = UIImageView()
    private let removeImageButton = UIButton()
    private let descriptionView = UIView()
    private let descriptionStackView = UIStackView()
    private var descriptionLabels: [UILabel] = []

    private let completeButtonContainerView = UIView()
    private let completeButton = UIButton()

    // MARK: - Initializer
    init(
        diningItems: [DiningItem],
        onDismissButtonTapped: @escaping ()->Void,
        onPlaceSelected: @escaping (DiningItem)->Void,
        onSelectImageButtonTapped: @escaping ()->Void,
        onCompleteButtonTapped: @escaping (
            _ selectedItem: DiningItem,
            _ evidenceImage: UIImage
        ) -> Void
    ) {
        self.diningItems = diningItems
        self.onDismissButtonTapped = onDismissButtonTapped
        self.onPlaceSelected = onPlaceSelected
        self.onSelectImageButtonTapped = onSelectImageButtonTapped
        self.onCompleteButtonTapped = onCompleteButtonTapped
        super.init(frame: .zero)
        configureView()
        setAddTargets()
        updatePlaceButtons()
        updateEvidenceImage()
        updateCompleteButton()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public
    func configure(evidenceImage: UIImage) {
        self.evidenceImage = evidenceImage
    }
}

extension DiningReportModalView {
    // MARK: - Update
    private func updatePlaceButtons() {
        zip(diningItems, placeButtons).forEach { diningItem, button in
            let isSelected = diningItem == selectedItem
            let textColor: ColorAsset = isSelected ? .new500 : .neutral500
            let borderColor: ColorAsset = isSelected ? .new500 : .neutral300
            button.configuration?.attributedTitle?.foregroundColor = UIColor.appColor(textColor)
            button.configuration?.background.strokeColor = .appColor(borderColor)
        }
    }

    private func updateEvidenceImage() {
        uploadedImageView.image = evidenceImage
        uploadedImageView.isHidden = evidenceImage == nil
        removeImageButton.isHidden = evidenceImage == nil
        selectImageButton.isHidden = evidenceImage != nil
    }

    private func updateCompleteButton() {
        completeButton.isEnabled = isButtonEnabled
        completeButton.backgroundColor = .appColor(isButtonEnabled ? .new500 : .neutral300)
    }
}

extension DiningReportModalView {
    // MARK: - Actions
    private func setAddTargets() {
        dismissButton.addTarget(self, action: #selector(didTapDismissButton), for: .touchUpInside)
        placeButtons.forEach {
            $0.addTarget(self, action: #selector(didTapPlaceButton(_:)), for: .touchUpInside)
        }
        selectImageButton.addTarget(self, action: #selector(didTapSelectImageButton), for: .touchUpInside)
        removeImageButton.addTarget(self, action: #selector(didTapRemoveImageButton), for: .touchUpInside)
        completeButton.addTarget(self, action: #selector(didTapCompleteButton), for: .touchUpInside)
    }

    @objc private func didTapDismissButton() {
        onDismissButtonTapped()
    }

    @objc private func didTapPlaceButton(_ sender: UIButton) {
        guard let index = placeButtons.firstIndex(of: sender) else {
            return
        }
        selectedItem = diningItems[index]
        onPlaceSelected(diningItems[index])
    }

    @objc private func didTapSelectImageButton() {
        onSelectImageButtonTapped()
    }

    @objc private func didTapRemoveImageButton() {
        evidenceImage = nil
    }

    @objc private func didTapCompleteButton() {
        guard let selectedItem, let evidenceImage else {
            return
        }
        onCompleteButtonTapped(
            selectedItem,
            evidenceImage
        )
    }
}

extension DiningReportModalView {
    // MARK: - Configure
    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }

    private func setUpStyles() {
        stackView.do {
            $0.axis = .vertical
            $0.spacing = 16
        }

        headerLabel.do {
            $0.text = "식단 품절 제보하기"
            $0.font = .appFont(.pretendardSemiBold, size: 18)
            $0.textColor = .appColor(.neutral700)
        }
        dismissButton.do {
            $0.setImage(.appImage(asset: .cancel)?.withRenderingMode(.alwaysTemplate), for: .normal)
            $0.tintColor = .appColor(.neutral800)
        }

        placeView.do {
            $0.axis = .vertical
            $0.alignment = .leading
            $0.spacing = 12
        }
        
        placeTitleLabel.do {
            $0.text = "품절 코스 선택"
            $0.font = .appFont(.pretendardSemiBold, size: 15)
            $0.textColor = .appColor(.neutral700)
        }
        
        placeButtonStackView.do {
            $0.axis = .horizontal
            $0.spacing = 12
        }
        placeButtons = diningItems.map { diningItem in
            UIButton().then {
                var configuration = UIButton.Configuration.plain()
                configuration.attributedTitle = AttributedString(
                    diningItem.place.name,
                    attributes: AttributeContainer([
                        .font: UIFont.appFont(.pretendardSemiBold, size: 14)
                    ])
                )
                configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12)
                configuration.cornerStyle = .capsule
                configuration.background.strokeWidth = 1
                $0.configuration = configuration
            }
        }

        evidenceView.do {
            $0.axis = .vertical
            $0.alignment = .fill
            $0.spacing = 12
        }
        evidenceTitleLabel.do {
            $0.text = "품절 사진 촬영"
            $0.font = .appFont(.pretendardSemiBold, size: 15)
            $0.textColor = .appColor(.neutral700)
        }
        
        selectImageButton.do {
            var configuration = UIButton.Configuration.plain()
            configuration.image = .appImage(asset: .diningReportImageEvidence)
            configuration.imagePlacement = .top
            configuration.imagePadding = 8
            configuration.attributedTitle = AttributedString(
                "사진 촬영하기",
                attributes: AttributeContainer([
                    .font: UIFont.appFont(.pretendardRegular, size: 14),
                    .foregroundColor: UIColor.appColor(.neutral500)
                ])
            )
            $0.configuration = configuration
            $0.backgroundColor = .appColor(.neutral200)
            $0.layer.cornerRadius = 8
        }
        uploadedImageView.do {
            $0.contentMode = .scaleAspectFill
            $0.clipsToBounds = true
            $0.layer.cornerRadius = 8
        }
        removeImageButton.do {
            $0.setImage(.appImage(asset: .diningDelete), for: .normal)
        }
        descriptionView.do {
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.appColor(.neutral300).cgColor
            $0.layer.cornerRadius = 8
        }
        descriptionStackView.axis = .vertical
        descriptionLabels = evidenceImageDescriptions.map { description in
            UILabel().then {
                $0.text = description
                $0.font = .appFont(.pretendardRegular, size: 12)
                $0.textColor = .appColor(.neutral500)
            }
        }

        completeButton.do {
            $0.setTitle("품절 제보하기", for: .normal)
            $0.setTitleColor(.appColor(.neutral0), for: .normal)
            $0.titleLabel?.font = .appFont(.pretendardSemiBold, size: 15)
            $0.layer.cornerRadius = 8
            $0.layer.applySketchShadow(
                color: .appColor(.neutral800),
                alpha: 0.04,
                x: 0,
                y: 2,
                blur: 4,
                spread: 0
            )
        }
    }

    private func setUpLayouts() {
        [headerLabel, dismissButton].forEach {
            headerView.addSubview($0)
        }
        
        placeButtons.forEach {
            placeButtonStackView.addArrangedSubview($0)
        }
        [placeTitleLabel, placeButtonStackView].forEach {
            placeView.addArrangedSubview($0)
        }

        descriptionLabels.forEach {
            descriptionStackView.addArrangedSubview($0)
        }
        [descriptionStackView].forEach {
            descriptionView.addSubview($0)
        }
        [selectImageButton, uploadedImageView, removeImageButton, descriptionView].forEach {
            evidenceContentView.addSubview($0)
        }
        [evidenceTitleLabel, evidenceContentView].forEach {
            evidenceView.addArrangedSubview($0)
        }

        [completeButton].forEach {
            completeButtonContainerView.addSubview($0)
        }

        [headerView, placeView, evidenceView, completeButtonContainerView].forEach {
            stackView.addArrangedSubview($0)
        }
        [stackView].forEach {
            addSubview($0)
        }
    }

    private func setUpConstraints() {
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        headerView.snp.makeConstraints {
            $0.height.equalTo(29)
        }
        headerLabel.snp.makeConstraints {
            $0.leading.centerY.equalToSuperview()
        }
        dismissButton.snp.makeConstraints {
            $0.trailing.centerY.equalToSuperview()
            $0.leading.greaterThanOrEqualTo(headerLabel.snp.trailing)
        }

        placeButtons.forEach {
            $0.snp.makeConstraints {
                $0.height.equalTo(34)
            }
        }

        descriptionLabels.forEach {
            $0.snp.makeConstraints {
                $0.height.equalTo(19)
            }
        }

        descriptionView.snp.makeConstraints {
            $0.top.trailing.bottom.equalToSuperview()
            $0.width.equalTo(150)
            $0.height.equalTo(180)
        }
        descriptionStackView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        selectImageButton.snp.makeConstraints {
            $0.top.leading.bottom.equalToSuperview()
            $0.trailing.equalTo(descriptionView.snp.leading).offset(-12)
        }
        uploadedImageView.snp.makeConstraints {
            $0.edges.equalTo(selectImageButton)
        }
        removeImageButton.snp.makeConstraints {
            $0.centerX.equalTo(uploadedImageView.snp.trailing).offset(-3)
            $0.centerY.equalTo(uploadedImageView.snp.top).offset(3)
        }

        completeButton.snp.makeConstraints {
            $0.top.bottom.centerX.equalToSuperview()
            $0.width.equalTo(200)
            $0.height.equalTo(46)
        }
    }
}
