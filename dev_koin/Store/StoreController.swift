//
// Created by 정태훈 on 2020/01/13.
// Copyright (c) 2020 정태훈. All rights reserved.
//

import Foundation
import Alamofire

class StoreController: ObservableObject {
    @Published var stores: Shops? = nil

    init() {
        self.load_stores()
    }

    func load_stores() {
        if let data = UserDefaults.standard.object(forKey: "stores") as? Data {
            let decoder = JSONDecoder()
            if let loaded = try? decoder.decode(Shops.self, from: data) {
                self.stores = loaded

            }
        }
    }

    func get_stores() -> [Store] {
        if let shops = self.stores {
            return shops.shops
        }
        return []
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