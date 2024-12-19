//
//  BusSearchResultTableViewHeader.swift
//  koin
//
//  Created by JOOMINKYUNG on 11/10/24.
//

import Combine
import SnapKit
import Then
import UIKit

final class BusSearchResultTableViewHeader: UITableViewHeaderFooterView {
    // MARK: - Properties
    var subscriptions = Set<AnyCancellable>()
    let tapDepartTimeButtonPublisher = PassthroughSubject<Void, Never>()
    let tapDepartBusTypeButtonPublisher = PassthroughSubject<Void, Never>()
    
    
    // MARK: - UIComponents
    private let departTimeButton = UIView().then {
        $0.isUserInteractionEnabled = true
    }
    
    private let departTimeLabel = UILabel().then {
        $0.font = .appFont(.pretendardBold, size: 16)
        $0.textColor = .appColor(.info700)
        $0.textAlignment = .left
        $0.minimumScaleFactor = 0.3
        $0.adjustsFontSizeToFitWidth = true
    }
    
    private let departGuideLabel = UILabel().then {
        $0.text = "출발"
        $0.minimumScaleFactor = 0.3
        $0.adjustsFontSizeToFitWidth = true
        $0.font = .appFont(.pretendardBold, size: 16)
        $0.textColor = .black
    }
    
    private let busTypeFilterButton = UIButton().then {
        $0.layer.cornerRadius = 12
        $0.backgroundColor = .appColor(.neutral50)
    }
   
    // MARK: - Initialization
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        configureView()
        setUpBusTypeFilterButton(busType: BusType.noValue.koreanDescription)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureView()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        subscriptions.removeAll()
    }
    
    func configureDepartTime(departTime: String) {
        departTimeLabel.text = departTime
        departTimeLabel.sizeToFit()
        departTimeButton.sizeToFit()
    }
    
    func configureDepartBusType(busType: BusType) {
        setUpBusTypeFilterButton(busType: busType.koreanDescription)
    }
    
    @objc private func tapDepartTimeButton() {
        tapDepartTimeButtonPublisher.send()
        
    }
    
    @objc private func tapDepartBusTypeButton() {
        tapDepartBusTypeButtonPublisher.send()
    }
}

extension BusSearchResultTableViewHeader {
    private func setUpDepartTimeButton() {
        let imageView = UIImageView(image: .appImage(asset: .arrowDown))
        [imageView, departGuideLabel, departTimeLabel].forEach {
            departTimeButton.addSubview($0)
        }
        departTimeLabel.snp.makeConstraints {
            $0.leading.centerY.equalToSuperview()
            $0.trailing.equalTo(departGuideLabel.snp.leading).offset(-4)
        }
        imageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-4)
            $0.leading.equalTo(departGuideLabel.snp.trailing).offset(4)
            $0.width.height.equalTo(15)
        }
        departGuideLabel.snp.makeConstraints {
            $0.trailing.equalTo(imageView.snp.leading).offset(-4)
            $0.leading.equalTo(departTimeLabel.snp.trailing).offset(4)
            $0.centerY.equalTo(departTimeLabel)
            $0.width.equalTo(30)
        }
    }
    
    private func setUpBusTypeFilterButton(busType: String) {
        var configuration = UIButton.Configuration.plain()
        configuration.attributedTitle = AttributedString(busType, attributes: AttributeContainer([.font: UIFont.appFont(.pretendardMedium, size: 14), .foregroundColor: UIColor.appColor(.neutral800)]))
        configuration.image = .appImage(asset: .arrowDown)
        configuration.imagePadding = 4
        configuration.contentInsets = .init(top: 9, leading: 16, bottom: 9, trailing: 16)
        configuration.imagePlacement = .trailing
        busTypeFilterButton.configuration = configuration
    }
    
    private func setUpLayouts() {
        [busTypeFilterButton, departTimeButton].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        departTimeButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(173)
            $0.height.equalTo(42)
        }
        busTypeFilterButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(24)
            $0.centerY.equalTo(departTimeButton)
            $0.width.equalTo(104)
            $0.height.equalTo(40)
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
        setUpDepartTimeButton()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapDepartTimeButton))
        departTimeButton.addGestureRecognizer(tapGesture)
        busTypeFilterButton.addTarget(self, action: #selector(tapDepartBusTypeButton), for: .touchUpInside)
    }
}
