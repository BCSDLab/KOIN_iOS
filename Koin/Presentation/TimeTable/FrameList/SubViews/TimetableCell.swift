//
//  TimetableCell.swift
//  koin
//
//  Created by 김나훈 on 11/21/24.
//

import UIKit

protocol TimetableCellDelegate: AnyObject {
    func settingButtonTapped(at indexPath: IndexPath)
}

final class TimetableCell: UITableViewCell {
    // MARK: - Properties
    weak var delegate: TimetableCellDelegate?
    private var indexPath: IndexPath?

    // MARK: - UI Components
    private let titleStackView = UIStackView()
    private let titleLabel = UILabel()
    private let bookmarkImageView = UIImageView()
    private let settingButton = UIButton(type: .custom)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureView()
        settingButton.addTarget(self, action: #selector(settingTapped), for: .touchUpInside)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(with timetable: FrameDto, at indexPath: IndexPath, canEdit: Bool = true) {
        self.indexPath = indexPath
        titleLabel.text = timetable.timetableName
        bookmarkImageView.isHidden = !canEdit || !timetable.isMain
        settingButton.isHidden = !canEdit
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        contentView.backgroundColor = .appColor(highlighted ? .neutral100 : .neutral0)
    }

    @objc private func settingTapped() {
        guard let indexPath else { return }
        delegate?.settingButtonTapped(at: indexPath)
    }

    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }

    private func setUpStyles() {
        backgroundColor = .appColor(.neutral0)
        selectionStyle = .none
        titleStackView.axis = .horizontal
        titleStackView.alignment = .center
        titleStackView.spacing = 8
        titleLabel.font = .appFont(.pretendardMedium, size: 15)
        titleLabel.textColor = .appColor(.neutral800)
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        bookmarkImageView.image = .appImage(asset: .timetableBookmark)
        bookmarkImageView.contentMode = .scaleAspectFit
        settingButton.setImage(UIImage.appImage(asset: .profileSetting)?.resize(to: CGSize(width: 21, height: 21))?.withRenderingMode(.alwaysTemplate), for: .normal)
        settingButton.tintColor = .appColor(.neutral500)
        settingButton.imageView?.contentMode = .scaleAspectFit
        settingButton.accessibilityLabel = "시간표 설정"
    }

    private func setUpLayouts() {
        [titleLabel, bookmarkImageView].forEach { titleStackView.addArrangedSubview($0) }
        [titleStackView, settingButton].forEach { contentView.addSubview($0) }
    }

    private func setUpConstraints() {
        titleStackView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(32)
            $0.top.equalToSuperview().offset(12)
            $0.height.equalTo(24)
            $0.trailing.lessThanOrEqualTo(settingButton.snp.leading).offset(-8)
        }
        bookmarkImageView.snp.makeConstraints { $0.size.equalTo(24).priority(999) }
        settingButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalTo(titleStackView)
            $0.size.equalTo(21)
        }
    }
}

final class FrameListSectionHeaderView: UIView {
    // MARK: - Properties
    private let isFirst: Bool
    private let onAdd: (UIButton) -> Void

    // MARK: - UI Components
    private let titleLabel = UILabel()
    private let addButton = UIButton(type: .custom)

    init(semester: String, section: Int, onAdd: @escaping (UIButton) -> Void) {
        isFirst = section == 0
        self.onAdd = onAdd
        super.init(frame: .zero)
        titleLabel.text = semester.reverseFormatSemester()
            .replacingOccurrences(of: "년 ", with: " ")
            .replacingOccurrences(of: " 학기", with: "학기")
        addButton.tag = section
        configureView()
        addButton.addTarget(self, action: #selector(addTapped), for: .touchUpInside)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    @objc private func addTapped() { onAdd(addButton) }

    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }

    private func setUpStyles() {
        backgroundColor = .appColor(.neutral0)
        titleLabel.font = .appFont(.pretendardSemiBold, size: 15)
        titleLabel.textColor = .appColor(.neutral800)
        addButton.setImage(.appImage(asset: .timetablePlusNeutral500), for: .normal)
        addButton.accessibilityLabel = "시간표 추가"
    }

    private func setUpLayouts() { [titleLabel, addButton].forEach { addSubview($0) } }

    private func setUpConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(isFirst ? 16 : 12)
            $0.leading.equalToSuperview().offset(20)
            $0.height.equalTo(24)
            $0.trailing.lessThanOrEqualTo(addButton.snp.leading).offset(-8)
        }
        addButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalTo(titleLabel)
            $0.size.equalTo(21)
        }
    }
}
