//
//  KoinBottomSheetContentViewController.swift
//  koin
//
//  Created by 홍기정 on 10/28/26.
//

import UIKit

/// 높이를 결정하는 UIKit 콘텐츠를 담는다.
@MainActor
final class KoinBottomSheetContentViewController: UIViewController {
    let contentView: any KoinBottomSheetContent

    init(contentView: some KoinBottomSheetContent) {
        self.contentView = contentView
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = contentView
    }

}
