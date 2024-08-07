//
//  BusInformationCollectionViewCell.swift
//  koin
//
//  Created by JOOMINKYUNG on 2024/03/31.
//


import SnapKit
import UIKit

final class BusInformationCollectionViewCell: UICollectionViewCell {
    
    // MARK: - UI Components
    private let departedPlace: UILabel = {
        let label = UILabel()
        label.font = UIFont.appFont(FontAsset.pretendardRegular, size: 15)
        return label
    }()
    
    private let arrivedPlace: UILabel = {
        let label = UILabel()
        label.font = UIFont.appFont(FontAsset.pretendardRegular, size: 15)
        return label
    }()
    
    private let nextBusSign: UILabel = {
        let label = UILabel()
        label.font = UIFont.appFont(FontAsset.pretendardMedium, size: 15)
        label.text = "다음 버스"
        return label
    }()
    
    private let busNumber: UILabel = {
        let label = UILabel()
        label.font = UIFont.appFont(.pretendardRegular, size: 12)
        return label
    }()
    
    private let nextBusNumber: UILabel = {
        let label = UILabel()
        label.font = UIFont.appFont(.pretendardRegular, size: 12)
        return label
    }()
    
    
    private let departureSign: UILabel = {
        let label = paddingLabel(padding: UIEdgeInsets(top: 1, left: 9, bottom: 1, right: 9))
        label.text = "출발"
        label.layer.cornerRadius = 12
        label.font = UIFont.appFont(FontAsset.pretendardMedium, size: 13)
        label.layer.borderWidth = 1
        label.layer.borderColor = UIColor.white.cgColor
        
        return label
    }()
    
    private let arrivalSign: UILabel = {
        let label = paddingLabel(padding: UIEdgeInsets(top: 1, left: 9, bottom: 1, right: 9))
        label.text = "도착"
        label.layer.cornerRadius = 12
        label.font = UIFont.appFont(FontAsset.pretendardMedium, size: 13)
        label.layer.borderWidth = 1
        label.layer.borderColor = UIColor.white.cgColor
        
        return label
    }()
    
    private let busType: UILabel = {
        let label = UILabel()
        label.font = UIFont.appFont(FontAsset.pretendardRegular, size: 15)
        return label
    }()
    
    private let nextBusType: UILabel = {
        let label = UILabel()
        label.font = UIFont.appFont(FontAsset.pretendardRegular, size: 15)
        return label
    }()
    
    private let departedTime: UILabel = {
        let label = UILabel()
        label.font = UIFont.appFont(FontAsset.pretendardRegular, size: 14)
        return label
    }()
    
    private let remainTime: UILabel = {
        let label = UILabel()
        label.font = UIFont.appFont(FontAsset.pretendardBold, size: 18)
        return label
    }()
    
    private let nextDepartedTime: UILabel = {
        let label = UILabel()
        label.font = UIFont.appFont(FontAsset.pretendardRegular, size: 14)
        return label
    }()
    
    private let nextRemianTime: UILabel = {
        let label = UILabel()
        label.font = UIFont.appFont(FontAsset.pretendardBold, size: 18)
        return label
    }()
    
    private let nowBusView: UIView = {
        let view = UIView()
        
        return view
    }()
    
    private let nextBusView: UIView = {
        let view = UIView()
        
        return view
    }()

    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpLabelColor(labelColor: UIColor.appColor(.neutral0))
        setUpLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(busInfoModel: BusCardInformation) {
        self.departedPlace.text = busInfoModel.departedPlace.koreanDescription// 출발지) e.g - 한기대
        self.arrivedPlace.text = busInfoModel.arrivedPlace.koreanDescription // 도착지) e.g - 야우리
        self.departedTime.text = busInfoModel.departedTime ?? "" // 출발 시간
        self.nextDepartedTime.text = busInfoModel.nextBusInfo.departedTime ?? ""
        self.remainTime.text = busInfoModel.remainTime
        self.nextRemianTime.text = busInfoModel.nextBusInfo.remainTime
        self.busNumber.text = busInfoModel.busNumber ?? ""
        self.nextBusNumber.text = busInfoModel.nextBusInfo.busNumber ?? ""
        self.busType.text = busInfoModel.busTitle.koreanDescription
        self.nextBusType.text = busInfoModel.busTitle.koreanDescription
    }
}

extension BusInformationCollectionViewCell {
    func setUpViewColor(viewColor: UIColor) {
        nowBusView.backgroundColor = viewColor
        nextBusView.backgroundColor = viewColor
    }
    
    private func setUpLabelColor(labelColor: UIColor) {
        [departedPlace, arrivedPlace, departureSign, arrivalSign, busType, departedTime, remainTime, busNumber].forEach {
            $0.textColor = labelColor
        }
        [nextBusSign, nextBusType, nextRemianTime, nextDepartedTime, nextBusNumber].forEach {
            $0.textColor = labelColor
        }
    }
    
    private func setUpLayout() {
        addSubview(nowBusView)
        addSubview(nextBusView)
    
        [departedPlace, arrivedPlace, departureSign, arrivalSign, busType, departedTime, remainTime, busNumber].forEach {
            nowBusView.addSubview($0)
        }
        
        [nextBusSign, nextBusType, nextRemianTime, nextDepartedTime, nextBusNumber].forEach {
            nextBusView.addSubview($0)
        }
        
        nowBusView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.top.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.height.equalTo(140)
        }
        
        nextBusView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.top.equalTo(nowBusView.snp.bottom).offset(5)
            $0.height.equalTo(100)
        }
        
        departureSign.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(15)
            $0.top.equalToSuperview().inset(20)
        }
        
        departedPlace.snp.makeConstraints {
            $0.left.equalTo(departureSign.snp.right).offset(5)
            $0.centerY.equalTo(departureSign)
        }
        
        arrivalSign.snp.makeConstraints {
            $0.leading.equalTo(departureSign)
            $0.top.equalTo(departureSign.snp.bottom).offset(6)
        }
        
        arrivedPlace.snp.makeConstraints {
            $0.left.equalTo(arrivalSign.snp.right).offset(5)
            $0.centerY.equalTo(arrivalSign)
        }
        
        busType.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(15)
            $0.centerY.equalTo(departedPlace)
        }
        
        busNumber.snp.makeConstraints {
            $0.trailing.equalTo(busType)
            $0.top.equalTo(busType.snp.bottom).offset(4)
        }
        
        nextBusType.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(15)
            $0.centerY.equalTo(nextBusSign)
        }
        
        remainTime.snp.makeConstraints {
            $0.leading.equalTo(departureSign)
            $0.bottom.equalToSuperview().inset(20)
        }
        
        departedTime.snp.makeConstraints {
            $0.trailing.equalTo(busType)
            $0.bottom.equalTo(remainTime)
        }
        
        nextBusSign.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(15)
            $0.top.equalToSuperview().inset(20)
        }
        
        nextRemianTime.snp.makeConstraints {
            $0.leading.equalTo(nextBusSign)
            $0.bottom.equalToSuperview().inset(15)
        }
        
        nextDepartedTime.snp.makeConstraints {
            $0.trailing.equalTo(busType)
            $0.bottom.equalTo(nextRemianTime)
        }
        
        nextBusNumber.snp.makeConstraints {
            $0.trailing.equalTo(nextBusType)
            $0.top.equalTo(nextBusType.snp.bottom).offset(3)
        }
    }
}
