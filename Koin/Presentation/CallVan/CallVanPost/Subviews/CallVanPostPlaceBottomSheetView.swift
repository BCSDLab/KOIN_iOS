//
//  CallVanPostPlaceBottomSheetView.swift
//  koin
//
//  Created by 홍기정 on 3/8/26.
//

import UIKit
import Combine
import SnapKit
import Then

final class CallVanPostPlaceBottomSheetView: UIView {
    
    enum Title: String {
        case departure = "출발지가 어디인가요?"
        case arrival = "도착지가 어디인가요?"
    }
    
    // MARK: - State
    private var selectedPlace: CallVanPlace? {
        didSet {
            updateSelection(selectedPlace)
            updateTextField(isEditing: selectedPlace == .custom)
            validate()
        }
    }
    private var customPlace: String? {
        didSet {
            validate()
        }
    }
    
    // MARK: - Properties
    weak var delegate: BottomSheetViewControllerBDelegate?
    private var onApplyButtonTapped: ((CallVanPlace, String?)->Void)?
    private var filterGroup = FilterGroupModel(
        title: "",
        hasAllButton: false,
        items: [
            CallVanPlace.frontGate.rawValue,
            CallVanPlace.backGate.rawValue,
            CallVanPlace.dormitoryMain.rawValue,
            CallVanPlace.dormitorySub.rawValue,
            CallVanPlace.terminal.rawValue,
            CallVanPlace.station.rawValue,
            CallVanPlace.asanStation.rawValue,
            CallVanPlace.custom.rawValue
        ],
        behavior: .single,
        allowEmptySelection: true
    )
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    private let titleLabel = UILabel()
    private let closeButton = UIButton()
    private let topSeparatorView = UIView()
    
    private lazy var filterGroupCollectionView = FilterGroupCollectionView(filterGroup: filterGroup)
    
    private let separatorView = UIView()
    private let customPlaceTextField = DefaultTextField(
        placeholder: "",
        placeholderColor: UIColor.appColor(.neutral800),
        font: UIFont.appFont(.pretendardMedium, size: 15)
    )
    private let applyButton = UIButton()
    private let bottomSeparatorView = UIView()
    
    // MARK: - Initialzier
    init() {
        super.init(frame: .zero)
        configureView()
        setAddTargets()
        setDelegate()
        bind()
    }
    
    // MARK: - Public
    func configure(
        title: Title,
        selectedPlace: CallVanPlace?,
        customPlace: String?,
        onApplyButtonTapped: @escaping (CallVanPlace, String?)->Void
    ) {
        self.selectedPlace = selectedPlace
        self.customPlace = customPlace
        self.onApplyButtonTapped = onApplyButtonTapped
        titleLabel.text = title.rawValue
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Bind
    private func bind() {
        filterGroupCollectionView.itemTappedPublisher
            .sink { [weak self] selectedIndex in
                guard let self,
                      let selectedPlace = CallVanPlace(rawValue: filterGroup.items[selectedIndex].title) else {
                    return
                }
                self.selectedPlace = selectedPlace
            }
            .store(in: &subscriptions)
    }
}

extension CallVanPostPlaceBottomSheetView {
    // MARK: - Set Delegate
    private func setDelegate() {
        customPlaceTextField.delegate = self
    }
    
    // MARK: - Set AddTargets
    private func setAddTargets() {
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        customPlaceTextField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        applyButton.addTarget(self, action: #selector(applyButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Objc
    @objc private func closeButtonTapped() {
        customPlaceTextField.resignFirstResponder()
        delegate?.dismiss()
    }
    
    @objc private func applyButtonTapped() {
        guard let selectedPlace else { return }
        customPlaceTextField.resignFirstResponder()
        
        switch selectedPlace {
        case .custom:
            onApplyButtonTapped?(.custom, customPlace)
        default:
            onApplyButtonTapped?(selectedPlace, nil)
        }
        
        delegate?.dismiss()
    }
    
    @objc private func editingChanged() {
        customPlace = customPlaceTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

extension CallVanPostPlaceBottomSheetView: UITextFieldDelegate {
    // MARK: - Handle Textfield
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        customPlace = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.endEditing(true)
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        customPlace = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func updateTextField(isEditing: Bool) {
        updateTextField(isVisible: isEditing)
        updateApplyButton(isCustomSelected: isEditing)
    }
    
    private func updateTextField(isVisible: Bool) {
        customPlaceTextField.snp.remakeConstraints {
            $0.height.equalTo(isVisible ? 47 : 0)
            $0.top.equalTo(separatorView.snp.bottom).offset(isVisible ? 24 : 0)
            $0.leading.trailing.equalToSuperview().inset(32)
        }
        
        if isVisible {
            customPlaceTextField.isHidden = false
        }
        
        UIView.animate(springDuration: 0.2) { [weak self] in
            self?.superview?.layoutIfNeeded()
            self?.layoutIfNeeded()
            self?.customPlaceTextField.alpha = isVisible ? 1 : 0
        } completion: { [weak self] _ in
            self?.customPlaceTextField.isHidden = !isVisible
        }
        
        if isVisible {
            customPlaceTextField.becomeFirstResponder()
        } else {
            customPlaceTextField.resignFirstResponder()
        }
    }
    
    private func updateApplyButton(isCustomSelected: Bool) {
        let title = isCustomSelected ? "입력완료" : "선택하기"
        applyButton.setAttributedTitle(NSAttributedString(
            string: title,
            attributes: [
                .font : UIFont.appFont(.pretendardSemiBold, size: 16),
                .foregroundColor : UIColor.appColor(.neutral0)
            ]), for: .normal
        )
    }
}

extension CallVanPostPlaceBottomSheetView {
    // MARK: - Update CollecitonView
    private func updateSelection(_ selectedPlace: CallVanPlace?) {
        let before = filterGroup.items.map(\.isSelected)
        
        filterGroup.reset(true)
        if let selectedPlace,
           let selectedIndex = filterGroup.items.firstIndex(where: { $0.title == selectedPlace.rawValue }) {
            filterGroup.didTap(itemAt: selectedIndex)
        }
        
        let after = filterGroup.items.map(\.isSelected)
        
        filterGroupCollectionView.update(
            filterGroup: filterGroup,
            changed: Self.changedIndexPaths(before: before, after: after)
        )
    }
    
    private static func changedIndexPaths(before: [Bool], after: [Bool]) -> [IndexPath] {
        zip(before, after).enumerated().compactMap { index, pair in
            pair.0 != pair.1 ? IndexPath(row: index, section: 0) : nil
        }
    }
}

extension CallVanPostPlaceBottomSheetView {
    // MARK: - Validate
    private func validate() {
        applyButton.backgroundColor = isValid ? UIColor.appColor(.new500) : UIColor.appColor(.neutral400)
        applyButton.isEnabled = isValid
    }
    
    private var isValid: Bool {
        guard let selectedPlace else { return false }
        switch selectedPlace {
        case .custom:
            let isEmpty = customPlace?.isEmpty ?? true
            return !isEmpty
        default:
            return true
        }
    }
}

extension CallVanPostPlaceBottomSheetView {
    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }
    
    private func setUpStyles() {
        self.do {
            $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            $0.layer.cornerRadius = 32
            $0.backgroundColor = UIColor.appColor(.neutral0)
        }
        
        titleLabel.do {
            $0.font = UIFont.appFont(.pretendardSemiBold, size: 18)
            $0.textColor = UIColor.appColor(.new500)
        }
        closeButton.do {
            $0.setImage(UIImage.appImage(asset: .newCancel)?.withRenderingMode(.alwaysTemplate), for: .normal)
            $0.tintColor = UIColor.appColor(.neutral800)
        }
        [topSeparatorView, separatorView, bottomSeparatorView].forEach {
            $0.backgroundColor = UIColor.appColor(.neutral300)
        }
        customPlaceTextField.do {
            $0.layer.cornerRadius = 12
            $0.layer.borderColor = UIColor.ColorSystem.Neutral.gray400.cgColor
            $0.layer.borderWidth = 1
        }
        applyButton.do {
            $0.setAttributedTitle(NSAttributedString(
                string: "선택하기",
                attributes: [
                    .font : UIFont.appFont(.pretendardSemiBold, size: 16),
                    .foregroundColor : UIColor.appColor(.neutral0)
                ]), for: .normal)
            $0.backgroundColor = UIColor.appColor(.new500)
            $0.layer.cornerRadius = 12
        }
        customPlaceTextField.do {
            $0.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 0))
            $0.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 0))
            $0.leftViewMode = .always
            $0.rightViewMode = .always
        }
    }
    
    private func setUpLayouts() {
        [titleLabel, closeButton, topSeparatorView,
         filterGroupCollectionView,
         separatorView, customPlaceTextField,
         applyButton, bottomSeparatorView].forEach {
            addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        titleLabel.snp.makeConstraints {
            $0.height.equalTo(29)
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalToSuperview().offset(32)
        }
        closeButton.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.trailing.equalToSuperview().offset(-24)
        }
        topSeparatorView.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
        }
        filterGroupCollectionView.snp.makeConstraints {
            $0.top.equalTo(topSeparatorView.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(32)
        }
        separatorView.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.top.equalTo(filterGroupCollectionView.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(32)
        }
        customPlaceTextField.snp.makeConstraints {
            $0.height.equalTo(0)
            $0.top.equalTo(separatorView.snp.bottom).offset(0)
            $0.leading.trailing.equalToSuperview().inset(32)
        }
        applyButton.snp.makeConstraints {
            $0.height.equalTo(48)
            $0.top.equalTo(customPlaceTextField.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(32)
        }
        bottomSeparatorView.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.top.equalTo(applyButton.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().priority(999)
        }
    }
}
