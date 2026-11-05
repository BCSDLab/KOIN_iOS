//
//  AddClassHeaderView.swift
//  koin
//
//  Created by 김나훈 on 11/19/24.
//

import Combine
import UIKit

protocol TimetableSheetSizing: AnyObject {
    func calculateSheetHeight(in context: KoinBottomSheetContext) -> CGFloat
}

protocol TimetableScrollableSheet: TimetableSheetSizing {
    var sheetScrollView: UIScrollView { get }
}

enum TimetableButtonTitle {
    static func set(_ title: String, on button: UIButton, font: FontAsset, size: Int, color: ColorAsset, lineBreakMode: NSLineBreakMode = .byClipping) {
        var attributedTitle = AttributedString(title)
        attributedTitle.font = UIFont.appFont(font, size: size)
        attributedTitle.foregroundColor = UIColor.appColor(color)
        var configuration = button.configuration ?? .plain()
        configuration.title = nil
        configuration.attributedTitle = attributedTitle
        configuration.titleLineBreakMode = lineBreakMode
        button.configuration = configuration
        button.titleLabel?.numberOfLines = 1
        button.titleLabel?.lineBreakMode = lineBreakMode
    }

    static func text(on button: UIButton) -> String? {
        if let title = button.configuration?.attributedTitle {
            return String(title.characters)
        }
        return button.currentTitle
    }
}

final class TimetableSheetTitleView: UIView {
    // MARK: - Properties
    let closePublisher = PassthroughSubject<Void, Never>()

    // MARK: - UI Components
    private let titleLabel = UILabel()
    private let closeButton = UIButton(type: .system)

    init(title: String) {
        super.init(frame: .zero)
        titleLabel.text = title
        configureView()
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func setTitle(_ title: String) { titleLabel.text = title }

    @objc private func closeTapped() { closePublisher.send() }

    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }

    private func setUpStyles() {
        backgroundColor = .appColor(.neutral0)
        titleLabel.font = .appFont(.pretendardSemiBold, size: 18)
        titleLabel.textColor = .appColor(.new500)
        closeButton.setImage(UIImage.appImage(asset: .cancel)?.withRenderingMode(.alwaysTemplate), for: .normal)
        closeButton.tintColor = .appColor(.neutral800)
        closeButton.accessibilityLabel = "닫기"
    }

    private func setUpLayouts() {
        [titleLabel, closeButton].forEach { addSubview($0) }
    }

    private func setUpConstraints() {
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(32)
            $0.centerY.equalToSuperview()
            $0.trailing.lessThanOrEqualTo(closeButton.snp.leading).offset(-10)
        }
        closeButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-32)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(24)
        }
    }
}

final class TimetableSheetButtonBar: UIView {
    // MARK: - Properties
    let secondaryPublisher = PassthroughSubject<Void, Never>()
    let primaryPublisher = PassthroughSubject<Void, Never>()

    // MARK: - UI Components
    private let secondaryButton = UIButton(type: .system)
    private let primaryButton = StatefulButton(
        title: "완료", font: .appFont(.pretendardSemiBold, size: 16),
        enabledColor: .appColor(.new500), cornerRadius: 12
    )

    init(secondaryTitle: String, primaryTitle: String = "완료") {
        super.init(frame: .zero)
        configureView()
        setTitles(secondary: secondaryTitle, primary: primaryTitle)
        primaryButton.updateState(isEnabled: true)
        secondaryButton.addTarget(self, action: #selector(secondaryTapped), for: .touchUpInside)
        primaryButton.addTarget(self, action: #selector(primaryTapped), for: .touchUpInside)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func setTitles(secondary: String, primary: String) {
        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.appFont(.pretendardSemiBold, size: 16)]
        secondaryButton.setAttributedTitle(NSAttributedString(string: secondary, attributes: attributes), for: .normal)
        primaryButton.setAttributedTitle(NSAttributedString(string: primary, attributes: attributes), for: .normal)
    }

    func setPrimaryEnabled(_ enabled: Bool) { primaryButton.updateState(isEnabled: enabled) }

    @objc private func secondaryTapped() { secondaryPublisher.send() }
    @objc private func primaryTapped() { primaryPublisher.send() }

    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }

    private func setUpStyles() {
        backgroundColor = .appColor(.neutral0)
        secondaryButton.titleLabel?.font = .appFont(.pretendardSemiBold, size: 16)
        secondaryButton.setTitleColor(.appColor(.neutral600), for: .normal)
        secondaryButton.layer.borderColor = UIColor.appColor(.neutral400).cgColor
        secondaryButton.layer.borderWidth = 1
        secondaryButton.layer.cornerRadius = 12
        secondaryButton.titleLabel?.numberOfLines = 1
        primaryButton.titleLabel?.numberOfLines = 1
    }

    private func setUpLayouts() {
        [secondaryButton, primaryButton].forEach { addSubview($0) }
    }

    private func setUpConstraints() {
        secondaryButton.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(12)
            $0.leading.equalToSuperview().offset(32)
            $0.width.equalTo(98)
            $0.height.equalTo(48)
        }
        primaryButton.snp.makeConstraints {
            $0.top.bottom.equalTo(secondaryButton)
            $0.leading.equalTo(secondaryButton.snp.trailing).offset(12)
            $0.trailing.equalToSuperview().offset(-32)
        }
    }
}

final class AddClassHeaderView: UIView, UITextFieldDelegate {
    // MARK: - Properties
    let closePublisher = PassthroughSubject<Void, Never>()
    let filterButtonPublisher = PassthroughSubject<Void, Never>()
    let searchClassPublisher = PassthroughSubject<String, Never>()
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - UI Components
    private let titleView = TimetableSheetTitleView(title: "수업 추가")
    private let filterButton = UIButton(type: .system)
    private let searchButton = UIButton(type: .system)
    private let searchTextField = UITextField()

    init() {
        super.init(frame: .zero)
        configureView()
        searchTextField.delegate = self
        filterButton.addTarget(self, action: #selector(filterTapped), for: .touchUpInside)
        searchButton.addTarget(self, action: #selector(searchTapped), for: .touchUpInside)
        titleView.closePublisher.sink { [weak self] in self?.closePublisher.send() }.store(in: &subscriptions)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    @objc private func filterTapped() { filterButtonPublisher.send() }

    @objc private func searchTapped() {
        guard let text = searchTextField.text, !text.isEmpty else { return }
        searchClassPublisher.send(text)
        searchTextField.resignFirstResponder()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchClassPublisher.send(textField.text ?? "")
        textField.resignFirstResponder()
        return true
    }

    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }

    private func setUpStyles() {
        backgroundColor = .appColor(.neutral0)
        searchTextField.font = .appFont(.pretendardRegular, size: 12)
        searchTextField.textColor = .appColor(.neutral800)
        searchTextField.tintColor = .appColor(.new500)
        searchTextField.attributedPlaceholder = NSAttributedString(string: "검색어를 입력해주세요.", attributes: [
            .font: UIFont.appFont(.pretendardRegular, size: 12),
            .foregroundColor: UIColor.appColor(.neutral500)
        ])
        searchTextField.returnKeyType = .search
        searchTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 36))
        searchTextField.leftViewMode = .always
        let iconContainer = UIView(frame: CGRect(x: 0, y: 0, width: 41, height: 36))
        searchButton.setImage(UIImage.appImage(asset: .recruitSearch)?.withRenderingMode(.alwaysOriginal), for: .normal)
        searchButton.frame = CGRect(x: 0, y: 7.5, width: 21, height: 21)
        searchButton.accessibilityLabel = "강의 검색"
        iconContainer.addSubview(searchButton)
        searchTextField.rightView = iconContainer
        searchTextField.rightViewMode = .always
        filterButton.setImage(UIImage.appImage(asset: .recruitFilter)?.withRenderingMode(.alwaysOriginal), for: .normal)
        filterButton.accessibilityLabel = "전공 선택"
        [searchTextField, filterButton].forEach {
            $0.layer.borderColor = UIColor.appColor(.neutral300).cgColor
            $0.layer.borderWidth = 1
            $0.layer.cornerRadius = 18
        }
    }

    private func setUpLayouts() {
        [titleView, searchTextField, filterButton].forEach { addSubview($0) }
    }

    private func setUpConstraints() {
        titleView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(66)
        }
        searchTextField.snp.makeConstraints {
            $0.top.equalTo(titleView.snp.bottom).offset(12)
            $0.leading.equalToSuperview().offset(32)
            $0.height.equalTo(36)
            $0.trailing.equalTo(filterButton.snp.leading).offset(-12)
        }
        filterButton.snp.makeConstraints {
            $0.top.height.equalTo(searchTextField)
            $0.trailing.equalToSuperview().offset(-32)
            $0.width.equalTo(57)
            $0.bottom.equalToSuperview().offset(-12)
        }
    }
}
