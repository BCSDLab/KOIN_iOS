//
//  RecruitStepView.swift
//  koin
//
//  Created by 홍기정 on 9/13/26.
//

import SnapKit
import Then
import UIKit

final class RecruitStepView: UIView {

    // MARK: - Properties
    private let firstStepTitle: String
    private let secondStepTitle: String
    private let isFirstStep: Bool

    // MARK: - UI Components
    private let firstCircleView = UIView()
    private let firstNumberLabel = UILabel()
    private let firstTitleLabel = UILabel()
    private let connectorView = UIView()
    private let secondCircleView = UIView()
    private let secondNumberLabel = UILabel()
    private let secondTitleLabel = UILabel()

    // MARK: - Initializer
    init(
        firstStepTitle: String,
        secondStepTitle: String,
        isFirstStep: Bool
    ) {
        self.firstStepTitle = firstStepTitle
        self.secondStepTitle = secondStepTitle
        self.isFirstStep = isFirstStep
        super.init(frame: .zero)
        configureView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension RecruitStepView {
    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }

    private func setUpStyles() {
        firstCircleView.do {
            $0.backgroundColor = .appColor(isFirstStep ? .new400 : .neutral300)
            $0.layer.cornerRadius = 16
        }
        secondCircleView.do {
            $0.backgroundColor = .appColor(isFirstStep ? .neutral300 : .new400)
            $0.layer.cornerRadius = 16
        }
        connectorView.backgroundColor = .appColor(.neutral300)

        firstNumberLabel.do {
            $0.text = "1"
            $0.font = .appFont(.pretendardSemiBold, size: 15)
            $0.textColor = .appColor(isFirstStep ? .neutral0 : .neutral800)
            $0.textAlignment = .center
        }
        secondNumberLabel.do {
            $0.text = "2"
            $0.font = .appFont(.pretendardSemiBold, size: 15)
            $0.textColor = .appColor(isFirstStep ? .neutral800 : .neutral0)
            $0.textAlignment = .center
        }
        firstTitleLabel.do {
            $0.text = firstStepTitle
            $0.font = .appFont(.pretendardRegular, size: 10)
            $0.textColor = .appColor(isFirstStep ? .new400 : .neutral400)
            $0.textAlignment = .center
        }
        secondTitleLabel.do {
            $0.text = secondStepTitle
            $0.font = .appFont(.pretendardRegular, size: 10)
            $0.textColor = .appColor(isFirstStep ? .neutral400 : .new400)
            $0.textAlignment = .center
        }
    }

    private func setUpLayouts() {
        [firstCircleView, connectorView, secondCircleView, firstTitleLabel, secondTitleLabel].forEach {
            addSubview($0)
        }
        firstCircleView.addSubview(firstNumberLabel)
        secondCircleView.addSubview(secondNumberLabel)
    }

    private func setUpConstraints() {
        firstCircleView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.centerX.equalToSuperview().offset(-46)
            $0.size.equalTo(32)
        }
        connectorView.snp.makeConstraints {
            $0.leading.equalTo(firstCircleView.snp.trailing)
            $0.trailing.equalTo(secondCircleView.snp.leading)
            $0.centerY.equalTo(firstCircleView)
            $0.height.equalTo(3)
            $0.width.equalTo(60)
        }
        secondCircleView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.size.equalTo(32)
        }
        [firstNumberLabel, secondNumberLabel].forEach {
            $0.snp.makeConstraints { $0.edges.equalToSuperview() }
        }
        firstTitleLabel.snp.makeConstraints {
            $0.top.equalTo(firstCircleView.snp.bottom).offset(4)
            $0.centerX.equalTo(firstCircleView)
            $0.width.equalTo(56)
            $0.bottom.equalToSuperview()
        }
        secondTitleLabel.snp.makeConstraints {
            $0.top.equalTo(secondCircleView.snp.bottom).offset(4)
            $0.centerX.equalTo(secondCircleView)
            $0.width.equalTo(56)
            $0.bottom.equalToSuperview()
        }
    }
}
