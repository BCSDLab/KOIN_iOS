//
//  OneBusTimetableTableViewFooter.swift
//  koin
//
//  Created by JOOMINKYUNG on 12/20/24.
//

import Combine
import SnapKit
import Then
import UIKit

final class OneBusTimetableTableViewFooter: UITableViewHeaderFooterView {
    // MARK: - Properties
    var subscriptions = Set<AnyCancellable>()
    let tapIncorrenctBusInfoButtonPublisher = PassthroughSubject<Void, Never>()
    
    // MARK: - UIComponents
    
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
}

extension OneBusTimetableTableViewFooter {
    private func setUpLayouts() {
        [incorrectBusInfoButton].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        incorrectBusInfoButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
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

