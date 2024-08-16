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
    var exchangeAreaButtonTappedAction: (() -> Void)?
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
        label.font = UIFont.appFont(.pretendardRegular, size: 12)
        label.textAlignment = .center
        return label
    }()
    
    private let redirectedLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appFont(.pretendardMedium, size: 12)
        label.textColor = UIColor.appColor(.neutral500)
        label.textAlignment = .left
        return label
    }()
    
    private let arrowImage: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage.appImage(symbol: .chevronRight)
        imageView.image = image
        imageView.tintColor = .appColor(.neutral500)
        return imageView
    }()
    
    private let redirectedButton: UIView = {
        let view = UIView()
        view.backgroundColor = .appColor(.neutral100)
        view.layer.cornerRadius = 8
        return view
    }()
    
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        exchangeAreaButton.addTarget(self, action: #selector(exchangeAreaButtonButtonTapped), for: .touchUpInside)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(redirectBtnTapped))
        self.redirectedButton.addGestureRecognizer(tapGesture)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycles
    override func prepareForReuse() {
        super.prepareForReuse()

    }
}

extension BusCollectionViewCell {
    
    func configure(busInfo: BusInformation) {
        busLabel.text = busInfo.busType.koreanDescription
        redirectedLabel.text = busInfo.redirectedText
        startAreaLabel.text = busInfo.startBusArea.koreanDescription
        endAreaLabel.text = busInfo.endBusArea.koreanDescription
        timeLabel.text = busInfo.remainTime
        startTimeLabel.text = busInfo.departedTime
        self.contentView.backgroundColor = .appColor(busInfo.color)
    }
    
    @objc func exchangeAreaButtonButtonTapped() {
        exchangeAreaButtonTappedAction?()
    }
    
    @objc func redirectBtnTapped() {
        redirectBtnTappedAction?(true)
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
