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

    func makeUIView(context: Context) -> TabBarCollectionView {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        let tabBarCollectionView = TabBarCollectionView(frame: .zero, collectionViewLayout: flowLayout).then {
            $0.backgroundColor = .clear
        }
        context.coordinator.bind(tabBarCollectionView: tabBarCollectionView)
        return tabBarCollectionView
    }

    func updateUIView(_ tabBarCollectionView: TabBarCollectionView, context: Context) {
        let coordinator = context.coordinator
        coordinator.onTap = onTap

        if coordinator.lastSelectedType != selectedNoticeType {
            tabBarCollectionView.update(selectedType: selectedNoticeType)
            coordinator.lastSelectedType = selectedNoticeType
        }
    }

    static func dismantleUIView(_ tabBarCollectionView: TabBarCollectionView, coordinator: Coordinator) {
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

        func bind(tabBarCollectionView: TabBarCollectionView) {
            tabBarCollectionView.selectTabPublisher.sink { [weak self] type in
                self?.onTap(type)
            }.store(in: &subscriptions)
        }
    }
}
