//
//  RecruitProfilePostSecondStepView.swift
//  koin
//
//  Created by 홍기정 on 9/15/26.
//

import UIKit

final class RecruitProfilePostSecondStepView: UIScrollView {

    init() {
        super.init(frame: .zero)
        backgroundColor = .appColor(.newBackground)
        showsVerticalScrollIndicator = false
        alwaysBounceVertical = true
        keyboardDismissMode = .interactive
        contentInsetAdjustmentBehavior = .never
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
