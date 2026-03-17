//
//  CallVanDataView.swift
//  koin
//
//  Created by 홍기정 on 3/10/26.
//

import UIKit

final class CallVanDataView: UIView {
    
    // MARK: - UI Components
    private let listLabel = UILabel()
    private let poepleImageView = UIImageView()
    private let participantsLabel = UILabel()
    
    private let wrapperView = UIView()
    private let wrapperLayoutGuide = UILayoutGuide()
    private let routeImageView = UIImageView()
    private let departureLabel = UILabel()
    private let arrivalLabel = UILabel()
    private let dateTimeLabel = UILabel()
    
    // MARK: - Initializer
    init() {
        super.init(frame: .zero)
        configureView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    func configure(callVanData: CallVanData) {
        participantsLabel.text = "\(callVanData.currentParticipants)/\(callVanData.maxParticipants)"
        
        departureLabel.attributedText = NSAttributedString(
            string: "출발: \(callVanData.departure)",
            attributes: [
                .font : UIFont.appFont(.pretendardMedium, size: 14),
                .foregroundColor : UIColor.appColor(.neutral800)
            ]
        )
        arrivalLabel.attributedText = NSAttributedString(
            string: "도착: \(callVanData.arrival)",
            attributes: [
                .font : UIFont.appFont(.pretendardMedium, size: 14),
                .foregroundColor : UIColor.appColor(.neutral800)
            ]
        )
        dateTimeLabel.attributedText = NSAttributedString(
            string: callVanData.dateTime,
            attributes: [
                .font : UIFont.appFont(.pretendardRegular, size: 12),
                .foregroundColor : UIColor.appColor(.neutral600)
            ]
        )
    }
}

extension CallVanDataView {
    
    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }
    
    private func setUpStyles() {
        listLabel.do {
            $0.text = "참여자 리스트"
            $0.textColor = UIColor.appColor(.neutral800)
            $0.font = UIFont.appFont(.pretendardMedium, size: 18)
        }
        poepleImageView.do {
            $0.image = UIImage.appImage(asset: .callVanListPeople)?.withRenderingMode(.alwaysTemplate)
            $0.tintColor = UIColor.appColor(.neutral600)
        }
        participantsLabel.do {
            $0.font = UIFont.appFont(.pretendardRegular, size: 14)
            $0.textColor = UIColor.appColor(.neutral600)
        }
        
        wrapperView.do {
            $0.layer.borderColor = UIColor.appColor(.neutral400).cgColor
            $0.layer.borderWidth = 1
            $0.layer.cornerRadius = 8
        }
        routeImageView.do {
            $0.image = UIImage.appImage(asset: .callVanRoute)
        }
    }
    
    private func setUpLayouts() {
        [routeImageView, departureLabel, arrivalLabel, dateTimeLabel].forEach {
            wrapperView.addSubview($0)
        }
        [listLabel, poepleImageView, participantsLabel, wrapperView].forEach {
            addSubview($0)
        }
        [wrapperLayoutGuide].forEach {
            addLayoutGuide($0)
        }
    }
    
    private func setUpConstraints() {
        listLabel.snp.makeConstraints {
            $0.height.equalTo(29)
            $0.top.equalToSuperview().offset(4)
            $0.leading.equalToSuperview().offset(24)
        }
        poepleImageView.snp.makeConstraints {
            $0.size.equalTo(20)
            $0.centerY.equalTo(listLabel)
            $0.leading.equalTo(listLabel.snp.trailing).offset(16)
        }
        participantsLabel.snp.makeConstraints {
            $0.centerY.equalTo(listLabel)
            $0.leading.equalTo(poepleImageView.snp.trailing).offset(4)
        }
        
        wrapperView.snp.makeConstraints {
            $0.top.equalTo(listLabel.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.bottom.equalToSuperview().offset(-8)
        }
        wrapperLayoutGuide.snp.makeConstraints {
            $0.top.bottom.equalTo(wrapperView).inset(12)
            $0.leading.equalTo(wrapperView).offset(24)
            $0.trailing.lessThanOrEqualTo(dateTimeLabel.snp.leading).offset(-8)
        }
        routeImageView.snp.makeConstraints {
            $0.leading.centerY.equalTo(wrapperLayoutGuide)
        }
        departureLabel.snp.makeConstraints {
            $0.height.equalTo(22)
            $0.top.equalTo(wrapperLayoutGuide)
            $0.leading.equalTo(routeImageView.snp.trailing).offset(8)
        }
        arrivalLabel.snp.makeConstraints {
            $0.height.equalTo(22)
            $0.leading.equalTo(departureLabel)
            $0.top.equalTo(departureLabel.snp.bottom)
            $0.bottom.trailing.equalTo(wrapperLayoutGuide)
        }
        dateTimeLabel.snp.makeConstraints {
            $0.centerY.equalTo(wrapperView)
            $0.trailing.equalTo(wrapperView).offset(-24)
        }
    }
}
