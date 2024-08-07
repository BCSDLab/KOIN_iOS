//
//  Log.swift
//  Koin
//
//  Created by 김나훈 on 3/11/24.
//

import Foundation
import OSLog
// 로깅 처리를 도와줌
enum Log {
  static func make() -> Logger {
    .init(subsystem: Bundle.main.bundleIdentifier ?? "NONE", category: "")
  }
}
