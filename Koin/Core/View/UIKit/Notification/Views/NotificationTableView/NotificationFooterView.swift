//
//  NotificationFooterView.swift
//  koin
//
//  Created by 홍기정 on 6/3/26.
//

import UIKit
import SnapKit
import Then

final class NotificationFooterView: UIView {
    
    enum State {
        case info
        case loading
    }
    
    // MARK: - UI Components
    private let infoLabel = UILabel()
    private let loadingIndicator = UIActivityIndicatorView(style: .medium).then {
        $0.startAnimating()
    }
    
    // MARK: - Properties
    private var state: State = .info
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        update(state: .info)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    func update(state: State) {
        self.state = state
        infoLabel.isHidden = state != .info
        loadingIndicator.isHidden = state != .loading
    }
}

private extension NotificationFooterView {
    
    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }
    
    private func setUpStyles() {
        backgroundColor = UIColor.ColorSystem.Neutral.gray0
        
        infoLabel.do {
            $0.text = "14일이 지난 알림은 자동으로 삭제됩니다."
            $0.font = UIFont.appFont(.pretendardRegular, size: 14)
            $0.textColor = UIColor.ColorSystem.Neutral.gray500
            $0.textAlignment = .center
            $0.numberOfLines = 0
        }
    }
    
    private func setUpLayouts() {
        [infoLabel, loadingIndicator].forEach {
            addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        infoLabel.snp.makeConstraints {
            $0.top.greaterThanOrEqualToSuperview().offset(20)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.bottom.equalToSuperview().offset(-20).priority(.low)
            $0.height.equalTo(15)
        }
        
        loadingIndicator.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
}
