//
// Created by 정태훈 on 2020/01/13.
// Copyright (c) 2020 정태훈. All rights reserved.
//
import Foundation
import Alamofire
import SwiftUI
import Combine
import PKHUD

class StoreController: ObservableObject {
    @Published var stores: Shops?
    @Published var detail_store: Store?
    var isImageClicked: Bool = false
    var expandImage: String = ""

    let objectWillChange = PassthroughSubject<StoreController, Never>()

    func open_image(image: String) {
        expandImage = image
        isImageClicked = true
        objectWillChange.send(self)
    }

    func dismiss_image() {
        isImageClicked = false
        objectWillChange.send(self)
    }

    init() {
        stores = Shops()
        detail_store = Store()
    }

    init(store_id: Int) {
        self.store_session()
        self.load_store(store_id: store_id)
    }

    func load_stores() {
        if let data = UserDefaults.standard.object(forKey: "stores") as? Data {
            let decoder = JSONDecoder()
            if let loaded = try? decoder.decode(Shops.self, from: data) {
                self.stores = loaded
            }
        }
        objectWillChange.send(self)
    }
    
    
    
    func load_store(store_id: Int){
        Alamofire
        .request("http://stage.api.koreatech.in/shops/\(store_id)", method: .get, encoding: JSONEncoding.prettyPrinted)
        .validate { request, response, data in
            return .success
        }
        .response { response in
            guard let data = response.data else {
                return
            }
            do {
                let decoder = JSONDecoder()
                let storeRequest = try decoder.decode(Store.self, from: data)
                self.detail_store = storeRequest
                self.objectWillChange.send(self)

            } catch let error {
                print(error)
            }

        }
        
    }

    func get_stores() -> [Store] {
        if let shops = self.stores {
            return shops.shops
        }
        return []
    }
    
    func get_stores(category: String){
        var filtered_stores: [Store] = []
        
        if let data = UserDefaults.standard.object(forKey: "stores") as? Data {
            let decoder = JSONDecoder()
            if let loaded = try? decoder.decode(Shops.self, from: data) {
                    for store in loaded.shops {
                        if category == "S001" {
                            if store.category == category || store.category == "S000" {
                                filtered_stores.append(store)
                            }
                        } else {
                            if store.category == category {
                                filtered_stores.append(store)
                            }
                        }

                    }
            }
        }
        
        self.stores = Shops(shops: filtered_stores)
        self.objectWillChange.send(self)
    }

    func store_session() {
        Alamofire
                .request("http://stage.api.koreatech.in/shops", method: .get, encoding: JSONEncoding.prettyPrinted)
                .validate { request, response, data in
                    return .success
                }
                .response { response in
                    guard let data = response.data else {
                        return
                    }
                    do {
                        let decoder = JSONDecoder()
                        let storeRequest = try decoder.decode(Shops.self, from: data)
                        self.stores = storeRequest

                        let encoder = JSONEncoder()
                        if let encoded = try? encoder.encode(self.stores) {
                            UserDefaults.standard.set(encoded, forKey: "stores")
                        }


                    } catch let error {
                        print(error)
                    }

                }
    }
}
