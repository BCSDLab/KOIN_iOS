//
//  RecruitProfilePostSkillTableViewCell.swift
//  koin
//
//  Created by 홍기정 on 9/21/26.
//

import Combine
import SnapKit
import Then
import UIKit

final class RecruitProfilePostSkillTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    let textChangedPublisher = PassthroughSubject<String, Never>()
    let deleteButtonTappedPublisher = PassthroughSubject<Void, Never>()
    var cellSubscriptions = Set<AnyCancellable>()
    
    // MARK: - UI Components
    private let containerView = UIView()
    private let textField = UITextField()
    private let deleteButton = UIButton(type: .system)
    
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
        textField.text = nil
    }
    
    // MARK: - Public
    func configure(text: String) {
        textField.text = text
    }
}

extension RecruitProfilePostSkillTableViewCell {
    private func setAddTargets() {
        textField.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)
        textField.addTarget(self, action: #selector(textFieldEditingDidEnd), for: .editingDidEnd)
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
    }
    
    @objc private func textFieldEditingChanged() {
        textChangedPublisher.send(textField.text ?? "")
    }
    
    @objc private func textFieldEditingDidEnd() {
        let text = (textField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        textField.text = text
        textChangedPublisher.send(text)
    }
    
    @objc private func deleteButtonTapped() {
        deleteButtonTappedPublisher.send()
    }
}

extension RecruitProfilePostSkillTableViewCell {
    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }
    
    private func setUpStyles() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        containerView.do {
            $0.backgroundColor = .appColor(.neutral0)
            $0.layer.cornerRadius = 16
        }
        textField.do {
            $0.font = .appFont(.pretendardRegular, size: 14)
            $0.textColor = .appColor(.neutral800)
            $0.attributedPlaceholder = NSAttributedString(
                string: "기술 또는 자격증을 입력해주세요.",
                attributes: [
                    .font: UIFont.appFont(.pretendardRegular, size: 14),
                    .foregroundColor: UIColor.appColor(.neutral500)
                ]
            )
        }
        deleteButton.do {
            $0.setImage(UIImage.appImage(asset: .newCancel)?.resize(to: CGSize(width: 20, height: 20)), for: .normal)
            $0.tintColor = .appColor(.neutral800)
        }
    }
    private func setUpLayouts() {
        [textField, deleteButton].forEach {
            containerView.addSubview($0)
        }
        [containerView].forEach {
            contentView.addSubview($0)
        }
    }
    private func setUpConstraints() {
        containerView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-8)
            $0.height.equalTo(40)
        }
        deleteButton.snp.makeConstraints {
            $0.top.bottom.trailing.equalToSuperview()
            $0.width.equalTo(44)
        }
        textField.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(12)
            $0.top.bottom.equalToSuperview()
            $0.trailing.equalTo(deleteButton.snp.leading)
        }
    }
}
