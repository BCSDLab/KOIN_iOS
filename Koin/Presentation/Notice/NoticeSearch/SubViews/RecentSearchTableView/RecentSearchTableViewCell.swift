//
//  RecentSearchTableViewCell.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/23/24.
//

import Combine
import SnapKit
import Then
import UIKit

final class RecentSearchTableViewCell: UITableViewCell {
    //MARK: - Properties
    
    let tapDeleteButtonPublisher = PassthroughSubject<Void, Never>()
    var subscriptions = Set<AnyCancellable>()
    
    //MARK: - UI Components
    
    private let searchedWordLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardRegular, size: 16)
        $0.textColor = .appColor(.neutral800)
    }
    
    private let deleteButton = UIButton().then {
        $0.setImage(.appImage(asset: .delete), for: .normal)
    }
    
    //MARK: -Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureView()
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        subscriptions.removeAll()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureView()
    }
    
    func configure(searchedData: String) {
        searchedWordLabel.text = searchedData
    }
    
    @objc private func deleteButtonTapped() {
        tapDeleteButtonPublisher.send()
    }
}

extension RecentSearchTableViewCell {
    private func setUpLayouts() {
        [searchedWordLabel, deleteButton].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        searchedWordLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(24)
        }
        
        deleteButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(searchedWordLabel.snp.trailing).offset(2)
            $0.width.equalTo(20)
            $0.height.equalTo(20)
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
    }
}

