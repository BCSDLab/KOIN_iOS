//
//  KoinDropdownConfiguration.swift
//  koin
//
//  Created by 홍기정 on 8/21/26.
//

import UIKit

struct KoinDropdownConfiguration {
    // MARK: - Properties
    let topPadding: CGFloat
    let shadow: Shadow
    var direction: Direction = .down
}

// MARK: - Direction
extension KoinDropdownConfiguration {
    enum Direction {
        case down
        case auto
    }

    enum ResolvedDirection {
        case down
        case up
    }
}

// MARK: - Shadow
extension KoinDropdownConfiguration {
    enum Shadow {
        case shadow2
        case shadowSmall

        var color: ColorAsset {
            switch self {
            case .shadow2, .shadowSmall:
                return .neutral800
            }
        }

        var alpha: Float {
            switch self {
            case .shadow2: return 0.08
            case .shadowSmall: return 0.06
            }
        }

        var offset: CGPoint {
            switch self {
            case .shadow2: return CGPoint(x: 0, y: 4)
            case .shadowSmall: return CGPoint(x: 0, y: 1)
            }
        }

        var blur: CGFloat {
            switch self {
            case .shadow2: return 10
            case .shadowSmall: return 9
            }
        }

        var spread: CGFloat {
            switch self {
            case .shadow2: return 0
            case .shadowSmall: return 1
            }
        }
    }

    func shadowPadding(for direction: ResolvedDirection) -> UIEdgeInsets {
        let base = max(0, shadow.blur + shadow.spread)
        return UIEdgeInsets(
            top: direction == .up ? base + max(0, -shadow.offset.y) : 0,
            left: base + max(0, -shadow.offset.x),
            bottom: direction == .down ? base + max(0, shadow.offset.y) : 0,
            right: base + max(0, shadow.offset.x)
        )
    }
}
