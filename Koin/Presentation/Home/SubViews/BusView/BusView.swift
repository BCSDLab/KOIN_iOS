//
//  BusView.swift
//  koin
//
//  Created by JOOMINKYUNG on 12/10/24.
//

import Combine
import Foundation
import Then
import UIKit

final class BusView: UIView {
    //MARK: - Properties
    let moveBusTimetablePublisher = PassthroughSubject<Void, Never>()
    let moveBusSearchPublisher = PassthroughSubject<Void, Never>()
    
    //MARK: - UI Components
    private let busTimetableButton = UIView()
    private let busSearchButton = UIView()
    
    private let busTimetableLabel = UILabel().then {
        $0.text = "버스 시간표"
    }
    private let busSearchLabel = UILabel().then {
        $0.text = "가장 빠른 버스"
    }
    
    private let moveBusTimetableLabel = UILabel().then {
        $0.text = "바로가기"
    }
    private let moveBusSearchLabel = UILabel().then {
        $0.text = "조회하기"
    }
    
    private let busTimetableImageView = UIImageView()
    private let busSearchImageView = UIImageView()
    
    //MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: .zero)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureView()
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func tapBusTimetableButton() {
        moveBusTimetablePublisher.send()
    }
    
    @objc private func tapBusSearchButton() {
        moveBusSearchPublisher.send()
    }
}

extension BusView {
    private func configureUIComponents() {
        [busTimetableButton, busSearchButton].forEach {
            $0.backgroundColor = .appColor(.neutral50)
            $0.isUserInteractionEnabled = true
            $0.layer.cornerRadius = 8
        }
        
        [busTimetableLabel, busSearchLabel].forEach {
            $0.font = .appFont(.pretendardMedium, size: 14)
            $0.textColor = .black
            $0.textAlignment = .left
        }
        
        [moveBusTimetableLabel, moveBusSearchLabel].forEach {
            $0.font = .appFont(.pretendardRegular, size: 12)
            $0.textColor = .black
            $0.textAlignment = .left
        }
        
        [busSearchImageView, busTimetableImageView].forEach {
            $0.image = .appImage(asset: .arrowRight)?.withTintColor(.appColor(.neutral800), renderingMode: .alwaysOriginal)
        }
    }
    
    private func setLayouts() {
        [busTimetableButton, busSearchButton].forEach {
            addSubview($0)
        }
        
        [busTimetableLabel, moveBusTimetableLabel, busTimetableImageView].forEach {
            busTimetableButton.addSubview($0)
        }
        
        [busSearchLabel, moveBusSearchLabel, busSearchImageView].forEach {
            busSearchButton.addSubview($0)
        }
    }
    
    private func setConstraints() {
        busTimetableButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.top.bottom.equalToSuperview()
            $0.width.equalTo((UIScreen.main.bounds.width - 64) / 2)
        }
        busSearchButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(24)
            $0.top.bottom.equalToSuperview()
            $0.width.equalTo(busTimetableButton)
        }
        busTimetableLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalToSuperview().inset(12)
            $0.height.equalTo(22)
        }
        busSearchLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalToSuperview().inset(12)
            $0.height.equalTo(22)
        }
        moveBusSearchLabel.snp.makeConstraints {
            $0.leading.equalTo(busSearchLabel)
            $0.top.equalTo(busSearchLabel.snp.bottom)
            $0.height.equalTo(19)
        }
        moveBusTimetableLabel.snp.makeConstraints {
            $0.leading.equalTo(busTimetableLabel)
            $0.top.equalTo(busTimetableLabel.snp.bottom)
            $0.height.equalTo(19)
        }
        busTimetableImageView.snp.makeConstraints {
            $0.width.equalTo(15)
            $0.height.equalTo(15)
            $0.trailing.equalToSuperview().inset(27)
            $0.centerY.equalToSuperview()
        }
        busSearchImageView.snp.makeConstraints {
            $0.width.equalTo(15)
            $0.height.equalTo(15)
            $0.trailing.equalToSuperview().inset(27)
            $0.centerY.equalToSuperview()
        }
    }
    
    private func configureView() {
        configureUIComponents()
        setLayouts()
        setConstraints()
        let moveBusTimetableGesture = UITapGestureRecognizer(target: self, action: #selector(tapBusTimetableButton))
        let moveBusSearchGesture = UITapGestureRecognizer(target: self, action: #selector(tapBusSearchButton))
        busTimetableButton.addGestureRecognizer(moveBusTimetableGesture)
        busSearchButton.addGestureRecognizer(moveBusSearchGesture)
    }
}


