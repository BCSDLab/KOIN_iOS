//
//  UIViewController+KoinBottomSheet.swift
//  koin
//
//  Created by 홍기정 on 10/28/26.
//

import UIKit
import SnapKit

extension UIViewController {
    @discardableResult
    func presentBottomSheet(
        _ contentView: some KoinBottomSheetContent,
        configuration: KoinBottomSheetConfiguration = .init()
    ) -> KoinBottomSheetController? {
        guard let window = viewIfLoaded?.window else { return nil }
        assert(contentView.superview == nil, "Create new content for every KoinBottomSheet presentation")
        window.endEditing(true)

        let host: UIViewController
        switch configuration.style {
        case .modal:
            host = tabBarController ?? navigationController ?? self
        case .nonModal:
            host = self
        }
        // 닫히는 중인 시트는 애니메이션 동안 붙어 있지만, 활성 시트 조회에서는 빠진다.
        activeBottomSheets.forEach { $0.dismissForReplacement() }

        let sheet = KoinBottomSheetController(
            contentViewController: KoinBottomSheetContentViewController(contentView: contentView),
            owner: self,
            configuration: configuration
        )
        contentView.delegate = sheet
        host.addChild(sheet)
        host.view.addSubview(sheet.view)
        sheet.view.snp.makeConstraints { $0.edges.equalToSuperview() }
        sheet.didMove(toParent: host)
        sheet.presentSheet()
        return sheet
    }

    func dismissBottomSheet() {
        guard viewIfLoaded?.window != nil else { return }
        let modalHost = tabBarController ?? navigationController ?? self
        activeBottomSheets
            .filter { $0.owner === self || $0.parent === modalHost }
            .forEach { $0.dismiss() }
    }

    /// 같은 화면의 시트만 본다: 자신과 modal host의 직속 child.
    private var activeBottomSheets: [KoinBottomSheetController] {
        let modalHost = tabBarController ?? navigationController ?? self
        let candidates = modalHost === self ? children : children + modalHost.children
        return candidates
            .compactMap { $0 as? KoinBottomSheetController }
            .filter { $0.isActive }
    }
}
