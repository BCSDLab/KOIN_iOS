//
//  RecruitPostRoleTableViewCell.swift
//  koin
//
//  Created by Codex on 9/11/26.
//

import UIKit
import Combine
import SnapKit
import Then

final class RecruitPostRoleTableViewCell: UITableViewCell {
    // MARK: - Publishers
    let nameChangedPublisher = PassthroughSubject<(text: String, isComposing: Bool), Never>()
    let nameEditingEndedPublisher = PassthroughSubject<String, Never>()
    let addMembersTappedPublisher = PassthroughSubject<Void, Never>()
    let subtractMembersTappedPublisher = PassthroughSubject<Void, Never>()
    let deleteTappedPublisher = PassthroughSubject<Void, Never>()
    var cellSubscriptions: Set<AnyCancellable> = []

    // MARK: - UI Components
    private let stackView = UIStackView()
    private let nameContainerView = UIView()
    private let nameTextField = UITextField()
    private let nameCounterLabel = UILabel()
    private let membersContainerView = UIView()
    private let subtractMembersButton = UIButton()
    private let membersLabel = UILabel()
    private let addMembersButton = UIButton()
    private let deleteButton = UIButton()

    // MARK: - Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureView()
        setAddTargets()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        cellSubscriptions.removeAll()
        nameTextField.text = nil
        nameCounterLabel.text = nil
    }

    // MARK: - Public
    func configure(
        numberOfGeneralMembers: Int?,
        canSubtractMember: Bool,
        canAddMember: Bool
    ) {
        guard let numberOfGeneralMembers else {
            assert(false)
            return
        }
        UIView.performWithoutAnimation { [weak self] in
            guard let self else { return }
            nameContainerView.isHidden = true
            membersLabel.text = "\(numberOfGeneralMembers)"
            subtractMembersButton.isEnabled = canSubtractMember
            addMembersButton.isEnabled = canAddMember
            deleteButton.isHidden = true
            
            membersContainerView.snp.removeConstraints()
        }
    }

    func configure(
        model: RecruitRoleRequest,
        showsNameTextField: Bool,
        canSubtractMember: Bool,
        canAddMember: Bool,
        showsDeleteButton: Bool
    ) {
        UIView.performWithoutAnimation { [weak self] in
            guard let self else { return }
            configure(name: model.name)
            nameContainerView.isHidden = !showsNameTextField
            membersLabel.text = "\(model.maximumParticipants)"
            subtractMembersButton.isEnabled = canSubtractMember
            addMembersButton.isEnabled = canAddMember
            deleteButton.isHidden = !showsDeleteButton
            
            membersContainerView.snp.remakeConstraints {
                $0.width.equalTo(101).priority(.high)
            }
        }
    }

    func configure(
        numberOfMembers: Int,
        canSubtractMember: Bool,
        canAddMember: Bool,
        showsDeleteButton: Bool
    ) {
        membersLabel.text = "\(numberOfMembers)"
        subtractMembersButton.isEnabled = canSubtractMember
        addMembersButton.isEnabled = canAddMember
        deleteButton.isHidden = !showsDeleteButton
    }

    func configure(name: String) {
        if nameTextField.text != name {
            nameTextField.text = name
        }
        nameCounterLabel.text = "\(name.count)/10"
    }
}

extension RecruitPostRoleTableViewCell {
    private func setAddTargets() {
        nameTextField.addTarget(self, action: #selector(nameTextFieldEditingChanged), for: .editingChanged)
        nameTextField.addTarget(self, action: #selector(nameTextFieldEditingEnded), for: .editingDidEnd)
        subtractMembersButton.addTarget(self, action: #selector(subtractMembersButtonTapped), for: .touchUpInside)
        addMembersButton.addTarget(self, action: #selector(addMembersButtonTapped), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
    }

    @objc private func nameTextFieldEditingChanged() {
        let text = nameTextField.text ?? ""
        nameCounterLabel.text = "\(text.count)/10"
        nameChangedPublisher.send((text, nameTextField.markedTextRange != nil))
    }

    @objc private func nameTextFieldEditingEnded() {
        nameEditingEndedPublisher.send(nameTextField.text ?? "")
    }

    @objc private func subtractMembersButtonTapped() {
        subtractMembersTappedPublisher.send(())
    }

    @objc private func addMembersButtonTapped() {
        addMembersTappedPublisher.send(())
    }

    @objc private func deleteButtonTapped() {
        deleteTappedPublisher.send(())
    }
}

extension RecruitPostRoleTableViewCell {
    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }

    private func setUpStyles() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        stackView.do {
            $0.axis = .horizontal
            $0.alignment = .fill
            $0.spacing = 8
        }
        [nameContainerView, membersContainerView].forEach {
            $0.backgroundColor = .appColor(.neutral0)
            $0.layer.cornerRadius = 8
        }
        
        nameTextField.do {
            $0.font = .appFont(.pretendardRegular, size: 12)
            $0.textColor = .appColor(.neutral600)
            $0.autocorrectionType = .no
            $0.spellCheckingType = .no
            $0.autocapitalizationType = .none
            $0.attributedPlaceholder = NSAttributedString(
                string: "역할을 입력해주세요.",
                attributes: [
                    .font: UIFont.appFont(.pretendardRegular, size: 12),
                    .foregroundColor: UIColor.appColor(.neutral500)
                ]
            )
        }
        nameCounterLabel.do {
            $0.font = .appFont(.pretendardRegular, size: 12)
            $0.textColor = .appColor(.neutral600)
            $0.textAlignment = .right
            $0.setContentCompressionResistancePriority(.required, for: .horizontal)
        }
        membersLabel.do {
            $0.font = .appFont(.pretendardRegular, size: 12)
            $0.textColor = .appColor(.neutral600)
            $0.textAlignment = .center
        }
        configureIconButton(subtractMembersButton, imageAsset: .minus)
        configureIconButton(addMembersButton, imageAsset: .addThin)
        configureIconButton(deleteButton, imageAsset: .delete)
    }

    private func configureIconButton(_ button: UIButton, imageAsset: ImageAsset) {
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage.appImage(asset: imageAsset)?
            .withTintColor(.appColor(.neutral600), renderingMode: .alwaysOriginal)
        configuration.contentInsets = .zero
        button.configuration = configuration
        button.configurationUpdateHandler = { button in
            let image = button.configuration?.image
            button.configuration?.image = image?.withTintColor(.appColor(button.isEnabled ? .neutral600 : .neutral400))
        }
    }

    private func setUpLayouts() {
        contentView.addSubview(stackView)
        [nameContainerView, membersContainerView, deleteButton].forEach {
            stackView.addArrangedSubview($0)
        }
        [nameTextField, nameCounterLabel].forEach {
            nameContainerView.addSubview($0)
        }
        [subtractMembersButton, membersLabel, addMembersButton].forEach {
            membersContainerView.addSubview($0)
        }
    }

    private func setUpConstraints() {
        stackView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(44)
        }
        nameTextField.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.equalToSuperview().offset(12)
        }
        nameCounterLabel.snp.makeConstraints {
            $0.leading.equalTo(nameTextField.snp.trailing).offset(4)
            $0.trailing.equalToSuperview().offset(-12)
            $0.centerY.equalToSuperview()
        }
        subtractMembersButton.snp.makeConstraints {
            $0.top.leading.bottom.equalToSuperview()
            $0.width.equalTo(34)
        }
        membersLabel.snp.makeConstraints {
            $0.leading.equalTo(subtractMembersButton.snp.trailing)
            $0.top.bottom.equalToSuperview()
        }
        addMembersButton.snp.makeConstraints {
            $0.leading.equalTo(membersLabel.snp.trailing)
            $0.top.trailing.bottom.equalToSuperview()
            $0.width.equalTo(34)
        }
        deleteButton.snp.makeConstraints {
            $0.width.equalTo(16)
        }
    }
}
