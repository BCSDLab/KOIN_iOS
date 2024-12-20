//
//  ExpressOrCityTimetableFooterView.swift
//  koin
//
//  Created by JOOMINKYUNG on 12/20/24.
//

import Combine
import SnapKit
import Then
import UIKit

final class BusTimetableFooterView: UITableViewHeaderFooterView {
    // MARK: - Properties
    var subscriptions = Set<AnyCancellable>()
    let tapIncorrenctBusInfoButtonPublisher = PassthroughSubject<Void, Never>()
    
    // MARK: - UIComponents
    
    private var updatedDateLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardRegular, size: 14)
        $0.textColor = .appColor(.neutral500)
        $0.textAlignment = .left
        $0.numberOfLines = 0
    }
    
    private let incorrectBusInfoButton = UIButton().then {
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage.appImage(asset: .incorrectInfo)
        let title = AttributedString("정보가 정확하지 않나요?", attributes: AttributeContainer([
            .font: UIFont.appFont(.pretendardRegular, size: 12),
            .foregroundColor: UIColor.appColor(.neutral500)
        ]))
        configuration.attributedTitle = title
        configuration.imagePadding = 4
        configuration.contentInsets = .init(top: 5, leading: 0, bottom: 5, trailing: 0)
        $0.configuration = configuration
    }
    
    // MARK: - Initialization
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureView()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        subscriptions.removeAll()
    }
    
    @objc private func tapIncorrentInfoButton() {
        tapIncorrenctBusInfoButtonPublisher.send()
    }
    
    func configure(updatedDate: String) {
        updatedDateLabel.text = updatedDate
    }
}

extension BusTimetableFooterView {
    private func setUpLayouts() {
        [updatedDateLabel, incorrectBusInfoButton].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        updatedDateLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.leading.equalTo(24)
            $0.trailing.equalTo(24)
        }
        incorrectBusInfoButton.snp.makeConstraints {
            $0.top.equalTo(updatedDateLabel.snp.bottom).offset(8)
            $0.leading.equalTo(24)
            $0.height.equalTo(20)
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
        incorrectBusInfoButton.addTarget(self, action: #selector(tapIncorrentInfoButton), for: .touchUpInside)
    }
}
