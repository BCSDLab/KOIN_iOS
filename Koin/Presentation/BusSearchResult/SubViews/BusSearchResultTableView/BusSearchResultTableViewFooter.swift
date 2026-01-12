//
//  BusSearchResultTableViewFooter.swift
//  koin
//
//  Created by JOOMINKYUNG on 12/16/24.
//

import Combine
import SnapKit
import Then
import UIKit

final class BusSearchResultTableViewFooter: UITableViewHeaderFooterView {
    // MARK: - Properties
    static let reuseIdentifier = "BusSearchResultTableViewFooter"
    
    var subscriptions = Set<AnyCancellable>()
    let tapSeeMoreButtonPublisher = PassthroughSubject<Void, Never>()
    
    // MARK: - UIComponents
    private let seeMoreButton = UIButton().then {
        $0.contentEdgeInsets = .init(top: 8, left: 73, bottom: 8, right: 73)
        $0.layer.cornerRadius = 8
        $0.layer.borderColor = UIColor.appColor(.neutral200).cgColor
        $0.layer.borderWidth = 1
        $0.clipsToBounds = true
        let title = "교통편 더보기 ↓"
        let font = UIFont.appFont(.pretendardMedium, size: 14)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.appColor(.neutral600)
        ]
        
        let attributedTitle = NSAttributedString(string: title, attributes: attributes)
        $0.setAttributedTitle(attributedTitle, for: .normal)
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
    
    @objc private func tapSeeMoreButton() {
        tapSeeMoreButtonPublisher.send()
    }
}

extension BusSearchResultTableViewFooter {
    private func setUpLayouts() {
        [seeMoreButton].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        seeMoreButton.snp.makeConstraints {
            $0.centerY.centerX.equalToSuperview()
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
        seeMoreButton.addTarget(self, action: #selector(tapSeeMoreButton), for: .touchUpInside)
    }
}

