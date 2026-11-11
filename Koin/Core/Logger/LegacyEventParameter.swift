//
//  LegacyEventParameter.swift
//  koin
//

import Foundation

/// 구 명세 label. category를 호출 시 넘기고 screen_view는 보내지 않는다.
/// 현행 명세로 전환한 label은 EventParameter로 옮긴다.
protocol LegacyEventLabelType {
    var rawValue: String { get }
    var team: String { get }
}
