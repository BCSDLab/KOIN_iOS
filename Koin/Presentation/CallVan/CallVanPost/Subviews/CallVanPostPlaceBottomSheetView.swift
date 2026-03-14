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
    
    // MARK: - Properties
    weak var delegate: BottomSheetViewControllerBDelegate?
    private let onApplyButtonTapped: (CallVanPlace, String?)->Void
    
    // MARK: - UI Components
    private let containerView = UIView()
    
    private let titleLabel = UILabel()
    private let closeButton = UIButton()
    private let topSeparatorView = UIView()
    
    private let buttonsStackView1 = UIStackView()
    private let buttons1 = [
        CallVanFilterButton(filterState: CallVanPlace.frontGate),
        CallVanFilterButton(filterState: CallVanPlace.backGate),
        CallVanFilterButton(filterState: CallVanPlace.dormitoryMain),
        CallVanFilterButton(filterState: CallVanPlace.dormitorySub)
    ]
    
    private let buttonsStackView2 = UIStackView()
    private let buttons2 = [
        CallVanFilterButton(filterState: CallVanPlace.terminal),
        CallVanFilterButton(filterState: CallVanPlace.station),
        CallVanFilterButton(filterState: CallVanPlace.asanStation)
    ]
    private let customButton = CallVanFilterButton(filterState: CallVanPlace.custom)
    
    private let separatorView = UIView()
    private let customPlaceTextField = DefaultTextField(placeholder: "", placeholderColor: UIColor.appColor(.neutral800), font: UIFont.appFont(.pretendardMedium, size: 15))
    private let applyButton = UIButton()
    private let bottomSeparatorView = UIView()
    
    // MARK: - Initialzier
    init(title: Title, place: CallVanPlace?, customPlace: String?, onApplyButtonTapped: @escaping (CallVanPlace, String?)->Void) {
        self.onApplyButtonTapped = onApplyButtonTapped
        super.init(frame: .zero)
        
        configureView()
        setAddTargets()
        setDelegate()
        
        titleLabel.text = title.rawValue
        
        if place == .custom {
            customButton.isSelected = true
            customPlaceTextField.text = customPlace
            customPlaceTextField.snp.remakeConstraints {
                $0.height.equalTo(47)
                $0.top.equalTo(separatorView.snp.bottom).offset(24)
                $0.leading.trailing.equalToSuperview().inset(32)
            }
            UIView.animate(
                withDuration: 0.2,
                animations: { [weak self] in
                    self?.superview?.layoutIfNeeded()
                    self?.layoutIfNeeded()
                    self?.applyButton.do {
                        $0.setAttributedTitle(NSAttributedString(
                            string: "입력완료",
                            attributes: [
                                .font : UIFont.appFont(.pretendardBold, size: 16),
                                .foregroundColor : UIColor.appColor(.neutral0)
                            ]), for: .normal)
                    }

                }
            )
        } else {
            let place = place ?? CallVanPlace.frontGate
            (buttons1 + buttons2).forEach {
                $0.isSelected = $0.filterState as! CallVanPlace == place
            }
            customButton.isSelected = false
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CallVanPostPlaceBottomSheetView {
    
    private func setAddTargets() {
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        
        (buttons1 + buttons2).forEach {
            $0.addTarget(self, action: #selector(placeButtonTapped(_:)), for: .touchUpInside)
        }
        customButton.addTarget(self, action: #selector(customButtonTapped(_:)), for: .touchUpInside)
        
        applyButton.addTarget(self, action: #selector(applyButtonTapped), for: .touchUpInside)
    }
    
    @objc private func closeButtonTapped() {
        delegate?.dismiss()
    }
    
    @objc private func placeButtonTapped(_ sender: UIButton) {
        if let placeButton = sender as? CallVanFilterButton {
            (buttons1 + buttons2).forEach {
                $0.isSelected = $0.filterState.rawValue == placeButton.filterState.rawValue
            }
        }
        if let placeButton = sender as? CallVanFilterButton {
            
        }
        customButton.isSelected = false
        
        customPlaceTextField.snp.remakeConstraints {
            $0.height.equalTo(0)
            $0.top.equalTo(separatorView.snp.bottom).offset(0)
            $0.leading.trailing.equalToSuperview().inset(32)
        }
        UIView.animate(
            withDuration: 0.2,
            animations: { [weak self] in
                self?.superview?.layoutIfNeeded()
                self?.layoutIfNeeded()
                self?.applyButton.do {
                    $0.setAttributedTitle(NSAttributedString(
                        string: "선택하기",
                        attributes: [
                            .font : UIFont.appFont(.pretendardBold, size: 16),
                            .foregroundColor : UIColor.appColor(.neutral0)
                        ]), for: .normal)
                }
            },
            completion: { [weak self] _ in
                self?.customPlaceTextField.resignFirstResponder()
            }
        )
    }
    
    @objc private func customButtonTapped(_ sender: UIButton) {
        (buttons1 + buttons2).forEach {
            $0.isSelected = false
        }
        sender.isSelected = true
        
        customPlaceTextField.snp.remakeConstraints {
            $0.height.equalTo(47)
            $0.top.equalTo(separatorView.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(32)
        }
        UIView.animate(
            withDuration: 0.2,
            animations: { [weak self] in
                self?.superview?.layoutIfNeeded()
                self?.layoutIfNeeded()
                self?.applyButton.do {
                    $0.setAttributedTitle(NSAttributedString(
                        string: "입력완료",
                        attributes: [
                            .font : UIFont.appFont(.pretendardBold, size: 16),
                            .foregroundColor : UIColor.appColor(.neutral0)
                        ]), for: .normal)
                }

            },
            completion: { [weak self] _ in
                self?.customPlaceTextField.becomeFirstResponder()
            }
        )
    }
    
    @objc private func applyButtonTapped() {
        if let selectedButton = (buttons1 + buttons2).first(where: { $0.isSelected }),
           let selectedPlace = selectedButton.filterState as? CallVanPlace {
            onApplyButtonTapped(selectedPlace, nil)
            delegate?.dismiss()
        }
        else if customButton.isSelected,
                let customPlace = customPlaceTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                !customPlace.isEmpty {
            onApplyButtonTapped(.custom, customPlace)
            delegate?.dismiss()
        }
    }
}

extension CallVanPostPlaceBottomSheetView: UITextFieldDelegate {
    
    private func setDelegate() {
        customPlaceTextField.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.endEditing(true)
        return true
    }
}

extension CallVanPostPlaceBottomSheetView {
    
    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }
    
    private func setUpStyles() {
        containerView.do {
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
        [buttonsStackView1, buttonsStackView2].forEach {
            $0.axis = .horizontal
            $0.spacing = 12
            $0.distribution = .fillProportionally
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
                    .font : UIFont.appFont(.pretendardBold, size: 16),
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
        buttons1.forEach {
            buttonsStackView1.addArrangedSubview($0)
        }
        buttons2.forEach {
            buttonsStackView2.addArrangedSubview($0)
        }
        buttonsStackView2.addArrangedSubview(customButton)
        
        [titleLabel, closeButton, topSeparatorView,
         buttonsStackView1, buttonsStackView2,
         separatorView, customPlaceTextField,
         applyButton, bottomSeparatorView].forEach {
            containerView.addSubview($0)
        }
        
        [containerView].forEach {
            addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        titleLabel.snp.makeConstraints {
            $0.height.equalTo(29)
            $0.top.equalTo(containerView).offset(12)
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
        
        buttonsStackView1.snp.makeConstraints {
            $0.height.equalTo(34)
            $0.top.equalTo(topSeparatorView.snp.bottom).offset(12)
            $0.leading.equalToSuperview().offset(32)
        }
        buttonsStackView2.snp.makeConstraints {
            $0.height.equalTo(34)
            $0.top.equalTo(buttonsStackView1.snp.bottom).offset(8)
            $0.leading.equalTo(buttonsStackView1)
        }
        
        separatorView.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.top.equalTo(buttonsStackView2.snp.bottom).offset(12)
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
            $0.bottom.equalToSuperview()
        }
    }
}
