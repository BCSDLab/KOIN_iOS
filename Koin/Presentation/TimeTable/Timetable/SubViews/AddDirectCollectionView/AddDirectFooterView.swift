//
//  AddDirectFooterView.swift
//  koin
//
//  Created by 김나훈 on 11/20/24.
//

import Combine
import UIKit

final class AddDirectFooterView: UICollectionReusableView {
    // MARK: - Properties
    static let identifier = "AddDirectFooterView"
    let footerTapPublisher = PassthroughSubject<Void, Never>()

    // MARK: - UI Components
    private let addButton = UIButton(type: .system)

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        addButton.addTarget(self, action: #selector(addTapped), for: .touchUpInside)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    @objc private func addTapped() { footerTapPublisher.send() }

    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }

    private func setUpStyles() {
        backgroundColor = .appColor(.neutral0)
        addButton.layer.borderColor = UIColor.appColor(.neutral300).cgColor
        addButton.layer.borderWidth = 0.5
        addButton.layer.cornerRadius = 16
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage.appImage(asset: .add)?.withRenderingMode(.alwaysTemplate)
        configuration.imagePlacement = .trailing
        configuration.baseForegroundColor = .appColor(.new500)
        configuration.contentInsets = .init(top: 0, leading: 18, bottom: 0, trailing: 10)
        addButton.configuration = configuration
        TimetableButtonTitle.set("시간 및 장소 추가", on: addButton, font: .pretendardSemiBold, size: 12, color: .new500)
        addButton.contentHorizontalAlignment = .fill
    }

    private func setUpLayouts() { addSubview(addButton) }

    private func setUpConstraints() {
        addButton.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(32)
        }
    }
}
