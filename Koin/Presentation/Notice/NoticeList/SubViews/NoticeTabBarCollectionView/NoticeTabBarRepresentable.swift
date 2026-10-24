//
//  NoticeTabBarRepresentable.swift
//  koin
//
//  Created by 홍기정 on 10/22/26.
//

import Combine
import SwiftUI
import UIKit

struct NoticeTabBarRepresentable: UIViewRepresentable {

    // MARK: - Properties
    let selectedNoticeType: NoticeListType
    let onTap: (NoticeListType) -> Void

    // MARK: - UIViewRepresentable
    func makeCoordinator() -> Coordinator {
        Coordinator(onTap: onTap)
    }

    func makeUIView(context: Context) -> NoticeTabBarCollectionView {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        let noticeTabBarCollectionView = NoticeTabBarCollectionView(frame: .zero, collectionViewLayout: flowLayout).then {
            $0.backgroundColor = .clear
        }
        context.coordinator.bind(noticeTabBarCollectionView: noticeTabBarCollectionView)
        return noticeTabBarCollectionView
    }

    func updateUIView(
        _ noticeTabBarCollectionView: NoticeTabBarCollectionView,
        context: Context
    ) {
        let coordinator = context.coordinator
        coordinator.onTap = onTap

        if coordinator.lastSelectedType != selectedNoticeType {
            noticeTabBarCollectionView.update(selectedType: selectedNoticeType)
            coordinator.lastSelectedType = selectedNoticeType
        }
    }

    static func dismantleUIView(
        _ noticeTabBarCollectionView: NoticeTabBarCollectionView,
        coordinator: Coordinator
    ) {
        coordinator.subscriptions.removeAll()
    }
}

extension NoticeTabBarRepresentable {
    final class Coordinator {
        var onTap: (NoticeListType) -> Void
        var lastSelectedType: NoticeListType?
        var subscriptions: Set<AnyCancellable> = []

        init(onTap: @escaping (NoticeListType) -> Void) {
            self.onTap = onTap
        }

        func bind(noticeTabBarCollectionView: NoticeTabBarCollectionView) {
            noticeTabBarCollectionView.selectTabPublisher.sink { [weak self] type in
                self?.onTap(type)
            }.store(in: &subscriptions)
        }
    }
}
