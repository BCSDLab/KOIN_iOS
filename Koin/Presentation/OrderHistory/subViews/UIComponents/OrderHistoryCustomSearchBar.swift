//
//  OrderHistoryCustomSearchBar.swift
//  koin
//
//  Created by 김성민 on 9/8/25.
//

import UIKit
import SnapKit

final class OrderHistoryCustomSearchBar: UIView {

    //MARK: - CallBack
    var onTextChanged: ((String) -> Void)?
    var onReturn: ((String) -> Void)?

    // MARK: - UI
    private let iconView = UIImageView().then {
        $0.image = UIImage.appImage(asset: .search)?.withRenderingMode(.alwaysTemplate)
        $0.tintColor = UIColor.appColor(.neutral500)
        $0.contentMode = .scaleAspectFit
    }

    let textField = UITextField().then {
        
        $0.clearButtonMode = .whileEditing
        $0.returnKeyType = .search
        $0.autocapitalizationType = .none
        $0.clearButtonMode = .never
        $0.autocorrectionType = .no
        $0.spellCheckingType = .no
        $0.font = UIFont.appFont(.pretendardRegular, size: 14)
        $0.textColor = .label
        $0.attributedPlaceholder = NSAttributedString(
            string: "주문한 메뉴/매장을 찾아보세요",
            attributes: [
                .foregroundColor: UIColor.appColor(.neutral400),
                .font: UIFont.appFont(.pretendardRegular, size: 14)
            ]
        )
    }

    // MARK: - Layout Config
    var contentInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12) { didSet { remakeConstraints() } }
    var spacing: CGFloat = 8 { didSet { remakeConstraints() } }
    var iconSize: CGFloat = 18 { didSet { iconView.snp.updateConstraints { $0.size.equalTo(iconSize) } } }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupActions()
        makeConstraints()
    }
    required init?(coder: NSCoder) { fatalError() }
    
    func setPlaceholder(_ text: String) {
        textField.attributedPlaceholder = NSAttributedString(
            string: text,
            attributes: [
                .foregroundColor: UIColor.appColor(.neutral400),
                .font: UIFont.appFont(.pretendardRegular, size: 14)
            ]
        )
    }

    func setLeftIcon(_ image: UIImage?, tint: UIColor? = nil) {
        iconView.image = image?.withRenderingMode(.alwaysTemplate)
        if let tint { iconView.tintColor = tint }
    }

    @discardableResult
    func focus() -> Bool { textField.becomeFirstResponder() }
    func unfocus() { textField.resignFirstResponder() }

    // MARK: - Private
    private func setupUI() {
        backgroundColor = UIColor.appColor(.neutral0)
        layer.cornerRadius = 16
        layer.masksToBounds = false
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        layer.shadowOpacity = 0.06

        addSubview(iconView)
        addSubview(textField)
    }

    private func setupActions() {
        textField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        textField.delegate = self
    }

    private func makeConstraints() {
        iconView.snp.makeConstraints {
            $0.size.equalTo(iconSize)
            $0.leading.equalToSuperview().inset(contentInsets.left)
            $0.centerY.equalToSuperview()
        }
        textField.snp.makeConstraints {
            $0.leading.equalTo(iconView.snp.trailing).offset(spacing)
            $0.top.equalToSuperview().inset(contentInsets.top)
            $0.bottom.equalToSuperview().inset(contentInsets.bottom)
            $0.trailing.equalToSuperview().inset(contentInsets.right)
            $0.height.greaterThanOrEqualTo(36)
        }
    }

    private func remakeConstraints() {
        iconView.snp.remakeConstraints {
            $0.size.equalTo(iconSize)
            $0.leading.equalToSuperview().inset(contentInsets.left)
            $0.centerY.equalToSuperview()
        }
        textField.snp.remakeConstraints {
            $0.leading.equalTo(iconView.snp.trailing).offset(spacing)
            $0.top.equalToSuperview().inset(contentInsets.top)
            $0.bottom.equalToSuperview().inset(contentInsets.bottom)
            $0.trailing.equalToSuperview().inset(contentInsets.right)
            $0.height.greaterThanOrEqualTo(36)
        }
        layoutIfNeeded()
    }

    @objc private func textDidChange() {
        onTextChanged?(textField.text ?? "")
    }
}

extension OrderHistoryCustomSearchBar: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        onReturn?(textField.text ?? "")
        textField.resignFirstResponder()
        return true
    }
}


