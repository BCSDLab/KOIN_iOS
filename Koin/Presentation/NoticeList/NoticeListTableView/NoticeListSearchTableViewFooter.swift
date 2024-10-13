//
//  NoticeListSearchTableViewFooter.swift
//  koin
//
//  Created by JOOMINKYUNG on 9/19/24.
//

import Combine
import SnapKit
import Then
import UIKit

final class NoticeSearchTableViewFooter: UITableViewHeaderFooterView {
    // MARK: - Properties
    let tapBtnPublisher = PassthroughSubject<Void, Never>()
    var subscriptions = Set<AnyCancellable>()
    
    static let id = "NoticeSearhTableViewFooter"
    
    // MARK: - UIComponents
    private let listLoadButton = UIButton().then {
        $0.setTitle("게시물 5개 더보기", for: .normal)
        $0.titleLabel?.font = .appFont(.pretendardRegular, size: 16)
        $0.setTitleColor(.appColor(.neutral500), for: .normal)
    }
    
    private let borderView = UIView().then {
        $0.backgroundColor = .appColor(.neutral300)
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
    
    @objc private func tapListLoadButton() {
        tapBtnPublisher.send()
    }
}

extension NoticeSearchTableViewFooter {
    private func setUpLayouts() {
        [listLoadButton, borderView].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        listLoadButton.snp.makeConstraints {
            $0.leading.trailing.top.equalToSuperview()
            $0.bottom.equalToSuperview().inset(1)
        }
        borderView.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.bottom.leading.trailing.equalToSuperview()
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
        listLoadButton.addTarget(self, action: #selector(tapListLoadButton), for: .touchUpInside)
        contentView.backgroundColor = .appColor(.neutral50)
    }
}

