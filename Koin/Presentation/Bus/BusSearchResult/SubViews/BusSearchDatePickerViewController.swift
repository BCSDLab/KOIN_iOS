//
//  BusSearchDatePickerViewController.swift
//  koin
//
//  Created by JOOMINKYUNG on 11/17/24.
//

import UIKit
import Combine
import SnapKit

final class BusSearchDatePickerViewController: KoinModalViewController {
    
    // MARK: - Properties
    /// 완료: 선택한 Date, 이번 표시 동안 사용자가 휠을 조작했는지
    private let onCompleted: (Date, Bool) -> Void
    private let onDepartureNowTapped: ()->Void
    private var isDateChanged = false
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    private let customView = UIView()
    private let mainTitleLabel = UILabel()
    private let subTitleLabel = UILabel()
    private let pickerBackgroundView = UIView()
    private let pickerView: NewKoinPickerView
    /// busDeparture 컬럼 순서: 날짜 · 오전/오후 · 시 · 분
    private let timeSeparatorLabel = UILabel()
    /// ':' 가로 중심 = picker leading + 시·분 경계 가운데(picker 좌표)
    private var timeSeparatorCenterXConstraint: Constraint?
    private let hourColumn = 2
    private let minuteColumn = 3
    /// picker 배경 영역 122(subTitle 아래 24 ~ 컨테이너 bottom) 안에서 picker(90) 위아래 여백
    private let pickerVerticalInset: CGFloat = 16
    /// ':' 글자 시각 중심 보정. picker 정중앙에서 1pt 위
    private let timeSeparatorCenterYOffset: CGFloat = -1
    
    // MARK: - Initializer
    init(
        subTitle: String,
        now: Date,
        departDate: Date,
        onCompleted: @escaping (Date, Bool) -> Void,
        onDepartureNowTapped: @escaping ()->Void
    ) {
        self.onCompleted = onCompleted
        self.onDepartureNowTapped = onDepartureNowTapped
        self.pickerView = NewKoinPickerView(configuration: .busDeparture(now: now))
        
        super.init(configuration: .init(
            appearance: .primary,
            content: .custom(customView: customView),
            button: .buttons(
                leftButtonTitle: "지금 출발",
                leftButtonStyle: .init(
                    textColor: .neutral600,
                    font: .pretendardMedium,
                    fontSize: 15
                ),
                rightButtonTitle: "완료",
                rightButtonAction: {}
            ),
            layout: .init(
                contentTopPadding: 24,
                contentHorizontalPadding: 0
            )
        ))
        
        configureSubTitleLabel(subTitle)
        pickerView.setDate(departDate, animated: false)
        bind()
    }
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutTimeSeparatorLabel()
    }
    
    // MARK: - Override
    /// 지금 출발: host가 now 갱신 후 적용
    override func leftButtonTapped() {
        dismiss(animated: true) { [weak self] in
            self?.onDepartureNowTapped()
        }
    }
    
    /// 완료: 선택한 Date 적용
    override func rightButtonTapped() {
        dismiss(animated: true) { [weak self] in
            guard let self else { return }
            onCompleted(pickerView.date, isDateChanged)
        }
    }
}

extension BusSearchDatePickerViewController {
    
    private func bind() {
        pickerView.datePublisher.sink { [weak self] _ in
            self?.isDateChanged = true
        }.store(in: &subscriptions)
    }
    
    /// x: 시·분 컬럼 경계 가운데(시|분 간격 가운데), y: picker 정중앙 - 1
    /// viewDidLayoutSubviews 시점엔 customView 배치 전이라 좌표 변환 대신 picker 기준 constraint offset만 갱신
    private func layoutTimeSeparatorLabel() {
        guard let hourFrame = pickerView.frame(ofColumn: hourColumn),
              let minuteFrame = pickerView.frame(ofColumn: minuteColumn) else {
            timeSeparatorLabel.isHidden = true
            return
        }
        timeSeparatorLabel.isHidden = false
        timeSeparatorCenterXConstraint?.update(offset: (hourFrame.maxX + minuteFrame.minX) / 2)
    }
    
    private func configureSubTitleLabel(_ text: String) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.do {
            $0.alignment = .left
            $0.lineSpacing = 14 * 0.6
            $0.lineBreakStrategy = .hangulWordPriority
        }
        subTitleLabel.attributedText = NSAttributedString(
            string: text,
            attributes: [
                .foregroundColor: UIColor.appColor(.neutral500),
                .font: UIFont.appFont(.pretendardRegular, size: 14),
                .paragraphStyle: paragraphStyle,
            ]
        )
    }
    
    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }
    
    private func setUpStyles() {
        mainTitleLabel.do {
            $0.text = "출발 시각 설정"
            $0.textColor = .appColor(.neutral700)
            $0.font = .appFont(.pretendardMedium, size: 18)
            $0.numberOfLines = 1
            $0.textAlignment = .left
        }
        subTitleLabel.do {
            $0.numberOfLines = 2
        }
        pickerBackgroundView.do {
            $0.backgroundColor = .appColor(.neutral50)
        }
        timeSeparatorLabel.do {
            $0.text = ":"
            $0.textColor = .appColor(.primary500)
            $0.font = .appFont(.pretendardMedium, size: 16)
            $0.isUserInteractionEnabled = false
        }
    }
    
    private func setUpLayouts() {
        [mainTitleLabel, subTitleLabel, pickerBackgroundView, timeSeparatorLabel].forEach {
            customView.addSubview($0)
        }
        pickerBackgroundView.addSubview(pickerView)
    }
    
    private func setUpConstraints() {
        mainTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(29)
        }
        subTitleLabel.snp.makeConstraints {
            $0.top.equalTo(mainTitleLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalTo(mainTitleLabel)
            $0.height.equalTo(44)
        }
        pickerBackgroundView.snp.makeConstraints {
            $0.top.equalTo(subTitleLabel.snp.bottom).offset(24)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        pickerView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(pickerVerticalInset)
            $0.leading.trailing.equalToSuperview()
        }
        timeSeparatorLabel.snp.makeConstraints {
            timeSeparatorCenterXConstraint = $0.centerX.equalTo(pickerView.snp.leading).constraint
            $0.centerY.equalTo(pickerView).offset(timeSeparatorCenterYOffset)
        }
        
        customView.snp.makeConstraints {
            $0.width.equalTo(301)
            $0.height.equalTo(227)
        }
    }
}
