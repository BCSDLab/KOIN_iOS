//
//  KoinPickerView+Configuration.swift
//  koin
//
//  Created by 홍기정 on 10/30/26.
//

import UIKit

extension KoinPickerView {

    // MARK: - Configuration
    struct Configuration {
        var mode: Mode
        var format: ColumnFormat = ColumnFormat()
        var minimumDate: Date?
        var maximumDate: Date?
        var minuteInterval: MinuteInterval = .one
        var visibleRowCount: VisibleRowCount = .three
        var style: Style
        /// 인접 컬럼 글자 사이 간격. 화면마다 다르므로 기본값 없음
        var columnSpacing: ColumnSpacing
    }

    // MARK: - Mode
    enum Mode {
        /// yyyy년 · M월 · d일
        case date
        /// 오전/오후 · h · mm
        case time12h
        /// H · mm (24:00 지원)
        case time24h
        /// 날짜 · 오전/오후 · h · mm
        case dateAndTime
    }

    // MARK: - ColumnFormat
    struct ColumnFormat {
        /// dateAndTime 모드: 날짜 컬럼을 오늘/내일 기준으로 표시할 기준일. nil이면 M월 d일(EEE)
        var relativeDayReference: Date?
        /// dateAndTime 모드: 날짜 컬럼 정렬
        var dateColumnAlignment: NSTextAlignment = .center
        /// time12h·dateAndTime 모드: 오전/오후 컬럼 표기
        var meridiemSymbols: PickerMeridiemSymbols = .korean
    }

    // MARK: - MinuteInterval
    enum MinuteInterval: Int {
        case one = 1
        case five = 5
        case ten = 10
        case fifteen = 15
        case thirty = 30
    }

    // MARK: - ColumnSpacing
    /// 인접 두 컬럼의 글자 사이 간격(UIPickerView 컴포넌트 간격 제외)
    enum ColumnSpacing {
        /// 모든 인접 컬럼 사이 같은 간격. 양 끝 컬럼 바깥에도 절반씩(컬럼 폭 = 글자 폭 + 간격)
        case uniform(CGFloat)
        /// 왼쪽부터 인접 컬럼 사이 간격, 개수 = 컬럼 수 - 1. 양 끝 컬럼 바깥 여백 0
        case each([CGFloat])

        /// 컬럼별 좌우 여백. 인접 간격을 양쪽 컬럼이 절반씩 나눈다
        func insets(numberOfColumns: Int) -> [UIEdgeInsets] {
            let gapCount = max(0, numberOfColumns - 1)
            let gaps: [CGFloat]
            let edge: CGFloat
            switch self {
            case .uniform(let spacing):
                gaps = Array(repeating: spacing, count: gapCount)
                edge = spacing / 2
            case .each(let spacings):
                guard spacings.count == gapCount else {
                    assertionFailure("ColumnSpacing.each 개수 \(spacings.count) ≠ 컬럼 수 - 1 = \(gapCount)")
                    return ColumnSpacing.uniform(spacings.first ?? 0).insets(numberOfColumns: numberOfColumns)
                }
                gaps = spacings
                edge = 0
            }
            return (0..<numberOfColumns).map { column in
                UIEdgeInsets(
                    top: 0,
                    left: column == 0 ? edge : gaps[column - 1] / 2,
                    bottom: 0,
                    right: column == numberOfColumns - 1 ? edge : gaps[column] / 2
                )
            }
        }
    }

    // MARK: - VisibleRowCount
    enum VisibleRowCount: Int {
        case three = 3
        case five = 5
    }

    // MARK: - Style
    struct Style {
        var selectedColor: UIColor
        var deselectedColor: UIColor
        var font: UIFont

        static let primary = Style(
            selectedColor: .appColor(.primary500),
            deselectedColor: .appColor(.neutral500),
            font: .appFont(.pretendardMedium, size: 16)
        )

        static let new = Style(
            selectedColor: .appColor(.new500),
            deselectedColor: .appColor(.neutral500),
            font: .appFont(.pretendardMedium, size: 16)
        )

        static let neutral = Style(
            selectedColor: .appColor(.neutral800),
            deselectedColor: .appColor(.neutral500),
            font: .appFont(.pretendardMedium, size: 16)
        )
    }
}

// MARK: - Presets
extension KoinPickerView.Configuration {

    /// BUS: 오늘 00:00 ~ +89일 23:59, 1분
    static func busDeparture(now: Date) -> Self {
        let calendar = Calendar.koin
        let today = calendar.startOfDay(for: now)
        let endOfLastDay = calendar.date(byAdding: .day, value: 90, to: today)
            .flatMap { calendar.date(byAdding: .minute, value: -1, to: $0) }
        return Self(
            mode: .dateAndTime,
            format: .init(relativeDayReference: now, dateColumnAlignment: .right),
            minimumDate: today,
            maximumDate: endOfLastDay,
            minuteInterval: .one,
            style: .primary,
            // 날짜|오전오후, 오전오후|시, 시|분. 디자인 18/14/22 - 시스템 5pt(UIPickerView 컬럼 사이 고정 간격)
            columnSpacing: .each([13, 9, 17])
        )
    }

    /// TimeTable: 09:00 ~ 24:00, 30분. time 모드는 min/max의 시각만 사용한다
    static var timetable: Self {
        let calendar = Calendar.koin
        let referenceDay = calendar.startOfDay(for: Date(timeIntervalSince1970: 0))
        return Self(
            mode: .time24h,
            minimumDate: calendar.date(byAdding: .hour, value: 9, to: referenceDay),
            maximumDate: calendar.date(byAdding: .hour, value: 24, to: referenceDay),
            minuteInterval: .thirty,
            visibleRowCount: .five,
            style: .neutral,
            columnSpacing: .uniform(20)
        )
    }

    /// LostItem: 10년 전 ~ 오늘
    static func lostItemDate(now: Date) -> Self {
        return Self(
            mode: .date,
            minimumDate: Calendar.koin.date(byAdding: .year, value: -10, to: now),
            maximumDate: now,
            style: .neutral,
            columnSpacing: .uniform(24)
        )
    }

    /// CallVan 날짜: 오늘 ~ +364일
    static func callVanDate(now: Date) -> Self {
        return Self(
            mode: .date,
            minimumDate: now,
            maximumDate: Calendar.koin.date(byAdding: .day, value: 364, to: now),
            style: .neutral,
            columnSpacing: .uniform(40)
        )
    }

    /// CallVan 시간: AM/PM · h · mm, 1분
    static var callVanTime: Self {
        return Self(
            mode: .time12h,
            format: .init(meridiemSymbols: .english),
            minuteInterval: .one,
            style: .neutral,
            columnSpacing: .uniform(40)
        )
    }

    /// Recruit 날짜: 범위는 host가 setRange(minimum:maximum:)로 주입
    static var recruitDate: Self {
        return Self(
            mode: .date,
            style: .neutral,
            columnSpacing: .uniform(40)
        )
    }
}
