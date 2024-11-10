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
    
    // MARK: - UIComponents
    private let departTimeButton = UIView()
    
    private let departTimeLabel = UILabel().then {
        $0.font = .appFont(.pretendardBold, size: 16)
        $0.textColor = .appColor(.info700)
        $0.textAlignment = .left
    }
    
    private let busTypeFilterButton = UIButton().then {
        $0.layer.cornerRadius = 12
        $0.backgroundColor = .appColor(.neutral50)
    }
   
    // MARK: - Initialization
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        configureView()
    }
    
    override func prepareForReuse() {
        subscriptions.removeAll()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureView()
    }
    
    func configure(departTime: String, busType: String) {
        departTimeLabel.text = departTime
        setUpBusTypeFilterButton(busType: busType)
    }
}

extension BusSearchResultTableViewHeader {
    private func setUpDepartTimeButton() {
        let imageView = UIImageView(image: .appImage(asset: .arrowDown))
        let departLabel = UILabel()
        departLabel.text = "출발"
        departLabel.font = .appFont(.pretendardBold, size: 16)
        departLabel.textColor = .black
        [imageView, departLabel, departTimeLabel].forEach {
            departTimeButton.addSubview($0)
        }
        departTimeLabel.snp.makeConstraints {
            $0.leading.centerY.equalToSuperview()
        }
        imageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(departLabel.snp.trailing).offset(8)
            $0.width.height.equalTo(15)
        }
        departLabel.snp.makeConstraints {
            $0.leading.equalTo(departTimeLabel.snp.trailing).offset(4)
            $0.centerY.equalTo(departTimeLabel)
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
            $0.top.equalToSuperview().offset(23)
            $0.height.equalTo(26)
        }
        busTypeFilterButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(24)
            $0.centerY.equalTo(departTimeButton)
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
        setUpDepartTimeButton()
    }
}

