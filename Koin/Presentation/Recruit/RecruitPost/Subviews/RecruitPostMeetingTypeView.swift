//
//  RecruitPostMeetingTypeView.swift
//  koin
//
//  Created by 홍기정 on 8/30/26.
//

import UIKit
import Combine
import SnapKit
import Then

final class RecruitPostMeetingTypeView: UIView {
    
    // MARK: - Properties
    let meetingTypeChangedPublisher = PassthroughSubject<RecruitMeetingType, Never>()
    
    // MARK: - UI Components
    private let headerView = RecruitPostSectionHeaderView(title: "진행방식", isRequired: true)
    private let optionStackView = UIStackView()
    private lazy var optionButtons: [UIButton] = RecruitMeetingType.allCases.map { meetingType in
        makeButton(for: meetingType)
    }
    
    // MARK: - Initializer
    init() {
        super.init(frame: .zero)
        configureView()
        setAddTargets()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    func configure(meetingType: RecruitMeetingType?) {
        optionButtons.forEach { button in
            button.isSelected = button.tag == meetingType?.index
            button.setNeedsUpdateConfiguration()
        }
    }
}

extension RecruitPostMeetingTypeView {
    private func setAddTargets() {
        optionButtons.forEach {
            $0.addTarget(self, action: #selector(optionButtonTapped), for: .touchUpInside)
        }
    }
    
    @objc private func optionButtonTapped(_ sender: UIButton) {
        guard let meetingType = RecruitMeetingType(index: sender.tag) else {
            return
        }
        configure(meetingType: meetingType)
        meetingTypeChangedPublisher.send(meetingType)
    }
}

extension RecruitPostMeetingTypeView {
    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }
    
    private func setUpStyles() {
        optionStackView.do {
            $0.axis = .horizontal
            $0.distribution = .fillEqually
            $0.spacing = 8
        }
    }
    
    private func setUpLayouts() {
        [headerView, optionStackView].forEach {
            addSubview($0)
        }
        optionButtons.forEach {
            optionStackView.addArrangedSubview($0)
        }
    }
    
    private func setUpConstraints() {
        headerView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
        optionStackView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom).offset(8)
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(63)
        }
    }
}

extension RecruitPostMeetingTypeView {    
    private func makeButton(for meetingType: RecruitMeetingType) -> UIButton {
        var configuration = UIButton.Configuration.plain()
        configuration.image = .appImage(asset: meetingType.imageAsset)
        configuration.attributedTitle = AttributedString(
            meetingType.rawValue,
            attributes: AttributeContainer([
                .font: UIFont.appFont(.pretendardRegular, size: 12)
            ])
        )
        configuration.imagePadding = 4
        configuration.imagePlacement = .top
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0)
        let button = UIButton(configuration: configuration)
        button.tag = meetingType.index
        button.configurationUpdateHandler = { button in
            let foregroundColor: UIColor
            let backgroundColor: UIColor
        
            if button.isSelected {
                foregroundColor = .appColor(.neutral0)
                backgroundColor = .appColor(.new500)
            } else if button.isHighlighted {
                foregroundColor = .appColor(.neutral600)
                backgroundColor = .appColor(.neutral100)
            } else {
                foregroundColor = .appColor(.neutral600)
                backgroundColor = .appColor(.neutral0)
            }

            var configuration = button.configuration
            let image = configuration?.image
            configuration?.image = image?.withTintColor(foregroundColor, renderingMode: .alwaysOriginal)
            configuration?.attributedTitle?.foregroundColor = foregroundColor
            configuration?.background.backgroundColor = backgroundColor
            configuration?.background.cornerRadius = 16
            button.configuration = configuration
        }
        button.setNeedsUpdateConfiguration()
        return button
    }
}
