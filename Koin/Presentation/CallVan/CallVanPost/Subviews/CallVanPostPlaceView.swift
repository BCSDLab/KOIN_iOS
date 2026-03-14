//
//  CallVanPostPlaceView.swift
//  koin
//
//  Created by 홍기정 on 3/5/26.
//

import UIKit
import Combine
import SnapKit
import Then

final class CallVanPostPlaceView: UIView {
    
    // MARK: - Properties
    let departureButtonTappedPublisher = PassthroughSubject<Void, Never>()
    let arrivalButtonTappedPublisher = PassthroughSubject<Void, Never>()
    let swapButtonTappedPublisher = PassthroughSubject<Void, Never>()
    let departureChangedPublisher = PassthroughSubject<(CallVanPlace?, String?), Never>()
    let arrivalChangedPublisher = PassthroughSubject<(CallVanPlace?, String?), Never>()
    
    // MARK: - UI Components
    private let departureLabel = UILabel()
    private let arrivalLabel = UILabel()
    private let departureButton = UIButton()
    private let arrivalButton = UIButton()
    private let swapButton = UIButton()
    
    // MARK: - Initializer
    init() {
        super.init(frame: .zero)
        configureView()
        setAddTargets()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    func updateDeparture(placeType: CallVanPlace?, customPlace: String?) {
        let backgroundColor = placeType != nil ? UIColor.clear : UIColor.appColor(.neutral100)
        let font = placeType != nil ? UIFont.appFont(.pretendardMedium, size: 18) : UIFont.appFont(.pretendardRegular, size: 12)
        let foregroundColor = placeType != nil ? UIColor.appColor(.neutral800) : UIColor.appColor(.neutral500)
        
        departureButton.backgroundColor = backgroundColor
        departureButton.setAttributedTitle(NSAttributedString(
            string: customPlace ?? placeType?.rawValue ?? "출발지 선택",
            attributes: [
                .font : font,
                .foregroundColor : foregroundColor
            ]
        ), for: .normal)
        departureChangedPublisher.send((placeType, customPlace))
    }
    
    func updateArrival(placeType: CallVanPlace?, customPlace: String?) {
        let backgroundColor = placeType != nil ? UIColor.clear : UIColor.appColor(.neutral100)
        let font = placeType != nil ? UIFont.appFont(.pretendardMedium, size: 18) : UIFont.appFont(.pretendardRegular, size: 12)
        let foregroundColor = placeType != nil ? UIColor.appColor(.neutral800) : UIColor.appColor(.neutral500)
        
        arrivalButton.backgroundColor = backgroundColor
        arrivalButton.setAttributedTitle(NSAttributedString(
            string: customPlace ?? placeType?.rawValue ?? "도착지 선택",
            attributes: [
                .font : font,
                .foregroundColor : foregroundColor
            ]
        ), for: .normal)
        arrivalChangedPublisher.send((placeType, customPlace))
    }
}

extension CallVanPostPlaceView {
    
    private func setAddTargets() {
        departureButton.addTarget(self, action: #selector(departureButtonTapped), for: .touchUpInside)
        arrivalButton.addTarget(self, action: #selector(arrivalButtonTapped), for: .touchUpInside)
        swapButton.addTarget(self, action: #selector(swapButtonTapped), for: .touchUpInside)
    }
    
    @objc private func departureButtonTapped() {
        departureButtonTappedPublisher.send()
    }
    
    @objc private func arrivalButtonTapped() {
        arrivalButtonTappedPublisher.send()
    }
    
    @objc private func swapButtonTapped() {
        swapButtonTappedPublisher.send()
    }
}

extension CallVanPostPlaceView {
    
    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }
    
    private func setUpStyles() {
        [departureLabel, arrivalLabel].forEach {
            $0.textAlignment = .center
            $0.font = UIFont.appFont(.pretendardMedium, size: 16)
            $0.textColor = UIColor.appColor(.new500)
        }
        departureLabel.text = "출발"
        arrivalLabel.text = "도착"
        
        [departureButton, arrivalButton].forEach {
            $0.backgroundColor = UIColor.appColor(.neutral100)
            $0.layer.cornerRadius = 8
        }
        
        departureButton.setAttributedTitle(NSAttributedString(
            string: "출발지 선택",
            attributes: [
                .font : UIFont.appFont(.pretendardRegular, size: 12),
                .foregroundColor : UIColor.appColor(.neutral500)
            ]
        ), for: .normal)
        
        arrivalButton.setAttributedTitle(NSAttributedString(
            string: "도착지 선택",
            attributes: [
                .font : UIFont.appFont(.pretendardRegular, size: 12),
                .foregroundColor : UIColor.appColor(.neutral500)
            ]
        ), for: .normal)
        
        swapButton.do {
            $0.setImage(UIImage.appImage(asset: .callVanSwapCircle), for: .normal)
        }
    }
    
    private func setUpLayouts() {
        [departureLabel, departureButton, swapButton, arrivalLabel, arrivalButton].forEach {
            addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        departureLabel.snp.makeConstraints {
            $0.height.equalTo(26)
            $0.width.equalTo(124)
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalToSuperview().offset(24)
        }
        departureButton.snp.makeConstraints {
            $0.height.equalTo(35)
            $0.top.equalTo(departureLabel.snp.bottom).offset(4)
            $0.leading.trailing.equalTo(departureLabel)
            $0.bottom.equalToSuperview().offset(-12)
        }
        arrivalLabel.snp.makeConstraints {
            $0.height.equalTo(26)
            $0.width.equalTo(124)
            $0.top.equalToSuperview().offset(12)
            $0.trailing.equalToSuperview().offset(-24)
        }
        arrivalButton.snp.makeConstraints {
            $0.height.equalTo(35)
            $0.top.equalTo(arrivalLabel.snp.bottom).offset(4)
            $0.leading.trailing.equalTo(arrivalLabel)
        }
        swapButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-12)
            $0.centerX.equalToSuperview()
        }
    }
}
