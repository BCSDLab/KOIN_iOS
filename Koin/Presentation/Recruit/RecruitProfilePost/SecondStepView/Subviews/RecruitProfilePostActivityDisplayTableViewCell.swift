//
//  RecruitProfilePostActivityDisplayTableViewCell.swift
//  koin
//
//  Created by 홍기정 on 9/21/26.
//

import Combine
import SnapKit
import Then
import UIKit

final class RecruitProfilePostActivityDisplayTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    let editButtonTappedPublisher = PassthroughSubject<Void, Never>()
    let deleteButtonTappedPublisher = PassthroughSubject<Void, Never>()
    var cellSubscriptions = Set<AnyCancellable>()
    
    // MARK: - UI Components
    private let cardView = UIView()
    private let titleLabel = UILabel()
    private let editButton = UIButton(type: .system)
    private let deleteButton = UIButton(type: .system)
    private let periodTitleLabel = UILabel()
    private let periodLabel = UILabel()
    private let descriptionTitleLabel = UILabel()
    private let descriptionLabel = UILabel()
    
    // MARK: - Initializer
    override init(
        style: UITableViewCell.CellStyle,
        reuseIdentifier: String?
    ) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureView()
        setAddTargets()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - PrepareForReuse
    override func prepareForReuse() {
        super.prepareForReuse()
        cellSubscriptions.removeAll()
    }
    
    // MARK: - Public
    func configure(activity: RecruitProfileActivityRequest) {
        titleLabel.text = activity.title
        descriptionLabel.text = activity.description
        descriptionLabel.do {
            $0.setLineHeight(lineHeight: 1.60, text: activity.description ?? "")
        }
        
        guard let startedAt = activity.startedAt else {
            periodLabel.text = nil
            return
        }
        let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ko_KR")
            formatter.dateFormat = "yyyy.MM.dd"
            return formatter
        }()
        let start = dateFormatter.string(from: startedAt)
        if activity.isOngoing {
            periodLabel.text = "\(start) - 진행 중"
        } else if let endedAt = activity.endedAt {
            periodLabel.text = "\(start) - \(dateFormatter.string(from: endedAt))"
        } else {
            periodLabel.text = start
        }
    }
}

extension RecruitProfilePostActivityDisplayTableViewCell {
    private func setAddTargets() {
        editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
    }
    
    @objc private func editButtonTapped() {
        editButtonTappedPublisher.send()
    }
    
    @objc private func deleteButtonTapped() {
        deleteButtonTappedPublisher.send()
    }
}

extension RecruitProfilePostActivityDisplayTableViewCell {
    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }
    private func setUpStyles() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        cardView.do {
            $0.backgroundColor = .appColor(.neutral0)
            $0.layer.cornerRadius = 16
        }
        titleLabel.do {
            $0.font = .appFont(.pretendardSemiBold, size: 14)
            $0.textColor = .appColor(.neutral800)
            $0.numberOfLines = 0
        }
        editButton.do {
            $0.setAttributedTitle(NSAttributedString(
                string: "수정",
                attributes: [
                    .font: UIFont.appFont(.pretendardRegular, size: 10),
                    .foregroundColor: UIColor.appColor(.new500)
                ]
            ), for: .normal)
            $0.layer.cornerRadius = 10
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.appColor(.new500).cgColor
        }
        deleteButton.do {
            $0.setImage(UIImage.appImage(asset: .newCancel)?.resize(to: CGSize(width: 20, height: 20)), for: .normal)
            $0.tintColor = .appColor(.neutral800)
        }
        [periodTitleLabel, descriptionTitleLabel].forEach {
            $0.font = .appFont(.pretendardRegular, size: 12)
            $0.textColor = .appColor(.neutral500)
        }
        periodTitleLabel.text = "활동 기간"
        descriptionTitleLabel.text = "활동 내용"
        
        [periodLabel, descriptionLabel].forEach {
            $0.font = .appFont(.pretendardRegular, size: 12)
            $0.textColor = .appColor(.neutral800)
            $0.numberOfLines = 0
        }
    }
    
    private func setUpLayouts() {
        [titleLabel, editButton, deleteButton, periodTitleLabel, periodLabel,
         descriptionTitleLabel, descriptionLabel].forEach(cardView.addSubview)
        contentView.addSubview(cardView)
    }
    
    private func setUpConstraints() {
        cardView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-8)
        }
        titleLabel.snp.makeConstraints {
            $0.height.equalTo(22)
            $0.top.leading.equalToSuperview().offset(12)
            $0.trailing.lessThanOrEqualTo(editButton.snp.leading).offset(-8)
        }
        deleteButton.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.trailing.equalToSuperview()
            $0.size.equalTo(44)
        }
        editButton.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.trailing.equalTo(deleteButton.snp.leading)
            $0.width.equalTo(34)
            $0.height.equalTo(20)
        }
        periodTitleLabel.snp.makeConstraints {
            $0.height.equalTo(19)
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.leading.equalToSuperview().offset(12)
        }
        periodLabel.snp.makeConstraints {
            $0.height.equalTo(19)
            $0.top.equalTo(periodTitleLabel)
            $0.leading.equalTo(periodTitleLabel.snp.trailing).offset(8)
            $0.trailing.lessThanOrEqualToSuperview().offset(-12)
        }
        descriptionTitleLabel.snp.makeConstraints {
            $0.height.equalTo(19)
            $0.top.equalTo(periodLabel.snp.bottom).offset(12)
            $0.leading.equalToSuperview().offset(12)
        }
        descriptionLabel.snp.makeConstraints {
            $0.height.greaterThanOrEqualTo(19)
            $0.top.equalTo(descriptionTitleLabel).offset(-12 * 0.6)
            $0.leading.equalTo(descriptionTitleLabel.snp.trailing).offset(8)
            $0.trailing.equalToSuperview().offset(-12)
            $0.bottom.equalToSuperview().offset(-16)
        }
    }
}
