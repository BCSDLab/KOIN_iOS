//
//  StoreView.swift
//  dev_koin
//
//  Created by 정태훈 on 2020/01/13.
//  Copyright © 2020 정태훈. All rights reserved.
//

import SwiftUI

struct StoreView: View {

    @ObservedObject var stores = StoreController()

    var body: some View {
        List {
            ForEach(stores.get_stores(), id: \.self) { i in
                Text(i.name)
            }
        }
    }
}

struct StoreView_Previews: PreviewProvider {
    static var previews: some View {
        StoreView()
    }
}
