//
//  KoinPickerDropDownView.swift
//  koin
//
//  Created by 홍기정 on 10/30/26.
//

import UIKit
import Combine
import SnapKit

final class KoinPickerDropDownView: UIView {

    private enum Metric {
        static let pickerTop: CGFloat = 12
        static let separatorSpacing: CGFloat = 8
        static let separatorHeight: CGFloat = 1
        static let buttonHeight: CGFloat = 22
        static let bottom: CGFloat = 12
    }

    // MARK: - Publisher
    /// 휠 조작 + 초기화 버튼
    var datePublisher: AnyPublisher<Date, Never> {
        return dateSubject.eraseToAnyPublisher()
    }
    private let dateSubject = PassthroughSubject<Date, Never>()
    private let applyButtonTappedSubject = PassthroughSubject<Void, Never>()

    // MARK: - Properties
    var date: Date {
        return pickerView.date
    }
    private var subscriptions: Set<AnyCancellable> = []

    // MARK: - UI Components
    private let pickerView: KoinPickerView
    private let separatorView = UIView()
    private let resetButton = UIButton()
    private let applyButton = UIButton()
    /// 초기화·확인 버튼 글자색
    private let buttonColor: UIColor

    // MARK: - Initializer
    init(configuration: KoinPickerView.Configuration, buttonColor: UIColor = .appColor(.new500)) {
        self.pickerView = KoinPickerView(configuration: configuration)
        self.buttonColor = buttonColor
        super.init(frame: .zero)
        configureView()
        bind()
        setAddTargets()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public
    /// 이벤트 없음
    func setDate(_ date: Date) {
        pickerView.setDate(date, animated: false)
    }

    /// 이벤트 없음. 현재 값 재정규화
    func setRange(minimum: Date?, maximum: Date?) {
        pickerView.setRange(minimum: minimum, maximum: maximum)
    }
}

// MARK: - KoinDropdownContentView
extension KoinPickerDropDownView: KoinDropdownContentView {
    var dismissTappedPublisher: AnyPublisher<Void, Never> {
        applyButtonTappedSubject.eraseToAnyPublisher()
    }
    /// 3행 picker(90) + 고정 여백 63 = 153
    var height: CGFloat {
        return Metric.pickerTop
            + pickerView.intrinsicContentSize.height
            + Metric.separatorSpacing * 2
            + Metric.separatorHeight
            + Metric.buttonHeight
            + Metric.bottom
    }
}

extension KoinPickerDropDownView {

    private func bind() {
        pickerView.datePublisher.sink { [weak self] date in
            self?.dateSubject.send(date)
        }.store(in: &subscriptions)
    }

    private func setAddTargets() {
        applyButton.addTarget(self, action: #selector(applyButtonTapped), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
    }

    /// 닫기만. 드롭다운형은 휠 변경이 즉시 반영된다
    @objc private func applyButtonTapped() {
        applyButtonTappedSubject.send()
    }

    /// 현재 시각으로 clamp 후 1회 발행
    @objc private func resetButtonTapped() {
        pickerView.setDate(Date(), animated: false)
        dateSubject.send(pickerView.date)
    }
}

extension KoinPickerDropDownView {

    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }

    private func setUpStyles() {
        backgroundColor = UIColor.appColor(.neutral100)

        pickerView.do {
            $0.backgroundColor = .clear
        }

        separatorView.do {
            $0.backgroundColor = UIColor.appColor(.neutral200)
        }

        applyButton.do {
            $0.setAttributedTitle(NSAttributedString(
                string: "확인",
                attributes: [
                    .font : UIFont.appFont(.pretendardMedium, size: 14),
                    .foregroundColor : buttonColor
                ]
            ), for: .normal)
        }

        resetButton.do {
            $0.setAttributedTitle(NSAttributedString(
                string: "초기화",
                attributes: [
                    .font : UIFont.appFont(.pretendardMedium, size: 14),
                    .foregroundColor : buttonColor
                ]
            ), for: .normal)
        }
    }

    private func setUpLayouts() {
        [pickerView, separatorView, resetButton, applyButton].forEach {
            addSubview($0)
        }
    }

    private func setUpConstraints() {
        pickerView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(Metric.pickerTop)
            $0.centerX.equalToSuperview()
        }
        separatorView.snp.makeConstraints {
            $0.height.equalTo(Metric.separatorHeight)
            $0.top.equalTo(pickerView.snp.bottom).offset(Metric.separatorSpacing)
            $0.leading.trailing.equalToSuperview().inset(10)
        }
        applyButton.snp.makeConstraints {
            $0.height.equalTo(Metric.buttonHeight)
            $0.top.equalTo(separatorView.snp.bottom).offset(Metric.separatorSpacing)
            $0.trailing.equalToSuperview().offset(-24)
            $0.bottom.equalToSuperview().offset(-Metric.bottom)
        }
        resetButton.snp.makeConstraints {
            $0.top.bottom.equalTo(applyButton)
            $0.trailing.equalTo(applyButton.snp.leading).offset(-16)
        }
    }
}
