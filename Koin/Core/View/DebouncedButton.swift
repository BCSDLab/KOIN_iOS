//
//  DebouncedButton.swift
//  koin
//
//  Created by 김나훈 on 12/30/24.
//

import UIKit
import RxSwift
import RxCocoa

class DebouncedButton: UIButton {
    private let disposeBag = DisposeBag()
    private var isRequestInProgress = false

    func throttle(interval: RxTimeInterval = .seconds(1), action: @escaping () -> Void) {
        self.rx.tap
            .filter { [weak self] in
                guard let self = self else { return false }
                if self.isRequestInProgress {
                    return false
                } else {
                    self.isRequestInProgress = true
                    return true
                }
            }
            .bind { [weak self] in
                action()
                DispatchQueue.main.asyncAfter(deadline: .now() + interval.toTimeInterval()) {
                    self?.isRequestInProgress = false
                }
            }
            .disposed(by: disposeBag)
    }
}

extension RxTimeInterval {
    func toTimeInterval() -> TimeInterval {
        switch self {
        case .seconds(let seconds):
            return TimeInterval(seconds)
        case .milliseconds(let milliseconds):
            return TimeInterval(milliseconds) / 1000.0
        case .microseconds(let microseconds):
            return TimeInterval(microseconds) / 1_000_000.0
        case .nanoseconds(let nanoseconds):
            return TimeInterval(nanoseconds) / 1_000_000_000.0
        case .never:
            return TimeInterval.infinity
        }
    }
}
