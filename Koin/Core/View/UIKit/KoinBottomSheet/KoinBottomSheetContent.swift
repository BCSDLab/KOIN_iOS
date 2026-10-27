//
//  KoinBottomSheetContent.swift
//  koin
//
//  Created by 홍기정 on 11/1/26.
//

import UIKit

/// 하단 safe area를 제외한 높이를 결정하는 맥락. 키보드 높이와는 무관하다.
struct KoinBottomSheetContext {
    let width: CGFloat
    let maximumHeight: CGFloat
}

@MainActor
protocol KoinBottomSheetContent: UIView {
    var delegate: KoinBottomSheetDelegate? { get set }
    func sheetHeight(in context: KoinBottomSheetContext) -> CGFloat
}

extension KoinBottomSheetContent {
    func sheetHeight(in context: KoinBottomSheetContext) -> CGFloat {
        layoutIfNeeded()
        return systemLayoutSizeFitting(
            CGSize(width: context.width, height: 0),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height
    }
}
