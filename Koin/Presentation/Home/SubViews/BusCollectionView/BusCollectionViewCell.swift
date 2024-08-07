//
//  BusCollectionViewCell.swift
//  Koin
//
//  Created by 김나훈 on 1/19/24.
//
import Combine
import SnapKit
import UIKit

final class BusCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    var buttonTappedAction: (([String]) -> Void)?
    var redirectBtnTappedAction: ((Bool) -> Void)?
    var cancellables = Set<AnyCancellable>()
    // MARK: - UI Components
    
    private let wrapperView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private let busLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appFont(.pretendardBold, size: 12)
        label.textColor = UIColor.appColor(.neutral0)
        label.textAlignment = .center
        return label
    }()
    
    private let startTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appFont(.pretendardRegular, size: 12)
        label.textAlignment = .center
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appFont(.pretendardMedium, size: 16)
        label.textAlignment = .center
        label.tintColor = UIColor.appColor(.primary500)
        return label
    }()
    
    private let startAreaLabel: UILabel = {
        let label = UILabel()
        label.text = "한기대"
        label.font = UIFont.appFont(.pretendardRegular, size: 12)
        label.textAlignment = .center
        return label
    }()
    
    private let exchangeAreaButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage.appImage(asset: .exchange), for: .normal)
        return button
    }()
    
    private let endAreaLabel: UILabel = {
        let label = UILabel()
        label.text = "야우리"
        label.font = UIFont.appFont(.pretendardRegular, size: 12)
        label.textAlignment = .center
        return label
    }()
    
    let redirectedLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appFont(.pretendardMedium, size: 12)
        label.textColor = UIColor.appColor(.neutral500)
        label.textAlignment = .left
        return label
    }()
    
    let arrowImage: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage.appImage(symbol: .chevronRight)
        imageView.image = image
        imageView.tintColor = .appColor(.neutral500)
        return imageView
    }()
    
    let redirectedButton: UIView = {
        let view = UIView()
        view.backgroundColor = .appColor(.neutral100)
        view.layer.cornerRadius = 8
        return view
    }()
    
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        exchangeAreaButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(redirectBtnTapped))
        self.redirectedButton.addGestureRecognizer(tapGesture)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycles
    override func prepareForReuse() {
        super.prepareForReuse()
        [busLabel, timeLabel, startTimeLabel].forEach { label in
            label.text = ""
        }
        if startAreaLabel.text == "야우리" {
            let tempText = startAreaLabel.text
            startAreaLabel.text = endAreaLabel.text
            endAreaLabel.text = tempText
        }
    }
}

extension BusCollectionViewCell {
    
    func configure(busType: BusType, redirectedText: String, colorAsset: SceneColorAsset) {
        busLabel.text = busType.koreanDescription
        redirectedLabel.text = redirectedText
        self.contentView.backgroundColor = .appColor(colorAsset)
    }
        
    func getBusEnumType(busType: BusType) -> BusType {
        return busType
    }
    
    // TODO: - 이것들 전부 별로다... 나중에 enum을 통한 rawValue로 바꿔야함..
    func getBusType() -> [String] {
        let from: String
        let to: String
        let type: String
        switch busLabel.text {
        case "학교셔틀": type = "shuttle"
        case "대성고속": type = "express"
        default: type = "city"
        }
        switch startAreaLabel.text {
        case "한기대":
            from = "koreatech"
            to = "terminal"
        default:
            from = "terminal"
            to = "koreatech"
        }
        return [from, to, type, busLabel.text ?? ""]
    }
    @objc func buttonTapped() {
        let tempText = startAreaLabel.text
        startAreaLabel.text = endAreaLabel.text
        endAreaLabel.text = tempText
        buttonTappedAction?(getBusType())
    }
    
    @objc func redirectBtnTapped() {
        redirectBtnTappedAction?(true)
    }
    
    func updateText(data: BusDTO) {
        timeLabel.text = ""
        startTimeLabel.text = ""
        if let remainTime = data.nowBus?.remainTime {
            updateTimeLabel(time: remainTime)
            calculateAndDisplayDepartureTime(remainTime: remainTime)
        } else {
            timeLabel.text = "운행정보없음"
        }
    }
    
    private func calculateAndDisplayDepartureTime(remainTime: Int) {
    
        let remainTimeInMinutes = Double(remainTime) / 60.0
        let roundedMinutes = ceil(remainTimeInMinutes)
        let roundedRemainTime = Int(roundedMinutes * 60.0)
        let currentTime = Date()
        let departureTime = currentTime.addingTimeInterval(TimeInterval(roundedRemainTime))
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH시 mm분"
        let departureTimeString = dateFormatter.string(from: departureTime)
        
        startTimeLabel.text = "\(departureTimeString)에 출발"
    }
    
    private func updateTimeLabel(time: Int) {
   
        let hours = time / 3600
        let minutes = (time % 3600) / 60
        let timeString: String
        if hours > 0 {
            timeString = "\(hours)시간 \(minutes)분 전"
        } else {
            timeString = "\(minutes)분 전"
        }
        timeLabel.text = timeString
    }
}

extension BusCollectionViewCell {
    private func setUpLayouts() {
        [busLabel, wrapperView].forEach {
            contentView.addSubview($0)
        }
        [timeLabel, startAreaLabel, exchangeAreaButton, endAreaLabel, startTimeLabel, redirectedButton].forEach {
            wrapperView.addSubview($0)
        }
        [redirectedLabel, arrowImage].forEach {
            redirectedButton.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        busLabel.snp.makeConstraints { make in
            make.top.equalTo(self.snp.top)
            make.centerX.equalToSuperview()
            make.height.equalTo(35)
        }
        wrapperView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(35)
            make.leading.trailing.bottom.equalToSuperview()
        }
        timeLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(15)
            make.centerX.equalTo(self.snp.centerX)
            make.height.equalTo(16)
        }
        startTimeLabel.snp.makeConstraints { make in
            make.top.equalTo(timeLabel.snp.bottom).offset(5)
            make.width.equalTo(self.snp.width)
            make.height.equalTo(18)
        }
        exchangeAreaButton.snp.makeConstraints { make in
            make.top.equalTo(startTimeLabel.snp.bottom).offset(12)
            make.centerX.equalTo(self.snp.centerX)
            make.height.equalTo(16)
        }
        startAreaLabel.snp.makeConstraints { make in
            make.top.equalTo(startTimeLabel.snp.bottom).offset(11)
            make.trailing.equalTo(exchangeAreaButton.snp.leading).offset(-11)
            make.height.equalTo(18)
        }
        endAreaLabel.snp.makeConstraints { make in
            make.top.equalTo(startTimeLabel.snp.bottom).offset(11)
            make.leading.equalTo(exchangeAreaButton.snp.trailing).offset(11)
            make.height.equalTo(18)
        }
        redirectedButton.snp.makeConstraints { make in
            make.leading.equalTo(16)
            make.trailing.equalToSuperview().inset(16)
            make.top.equalTo(exchangeAreaButton.snp.bottom).offset(12)
            make.bottom.equalToSuperview().inset(16)
        }
        redirectedLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
        }
        arrowImage.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(12)
            make.centerY.equalToSuperview()
            make.width.equalTo(15)
            make.height.equalTo(20)
        }
    }
    
    private func setUpBorder() {
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.appColor(.neutral500).withAlphaComponent(0.2).cgColor
        self.layer.cornerRadius = 8
        self.contentView.layer.cornerRadius = 8
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
        setUpBorder()
    }
}
