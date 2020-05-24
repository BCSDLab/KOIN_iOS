//
//  StoreDetailViewModel.swift
//  Koin
//
//  Created by 정태훈 on 2020/05/19.
//  Copyright © 2020 정태훈. All rights reserved.
//

import Foundation
import Combine

class StoreDetailViewModel: ObservableObject {
    var item: Store? = nil
    let storeFetcher: StoreFetcher = StoreFetcher()
    private var disposables = Set<AnyCancellable>()

    @Published var imageId: Int = 0
    @Published var showImage: Bool = false

    init(id: Int) {
        load(id: id)
    }

    func load(id: Int) {
        self.storeFetcher.getDetailStore(id: id)
                .receive(on: DispatchQueue.main)
                .print()
                .sink(receiveCompletion: { value in
                    switch value {
                    case .failure:
                        self.item = nil
                    case .finished:
                        break
                    }
                }, receiveValue: { shop in
                    self.item = shop
                })
                .store(in: &disposables)
    }


    var name: String {
        return item?.name ?? ""
    }

    var phone: String {
        return item?.phone ?? ""
    }

    var openTime: String {
        return item?.openTime ?? ""
    }

    var closeTime: String {
        return item?.closeTime ?? ""
    }

    var deliveryPrice: Int {
        return item?.deliveryPrice ?? 0
    }

    var isDelivery: Bool {
        return item?.delivery ?? false
    }

    var isCard: Bool {
        return item?.payCard ?? false
    }

    var isBank: Bool {
        return item?.payBank ?? false
    }

    var menus: [Menus] {
        return item?.menus ?? []
    }

    var menuViewModel: [StoreMenuRowViewModel] {
        return menus.map { m in
            StoreMenuRowViewModel(item: m)
        }
    }

    var images: [String] {
        return item?.imageUrls ?? []
    }

    var isEvent: Bool {
        return item?.isEvent ?? false
    }

    var event: [StoreEvent] {
        return item?.eventArticles ?? []
    }

    var address: String {
        return item?.address ?? ""
    }

    var description: String {
        return item?.description ?? ""
    }

}
