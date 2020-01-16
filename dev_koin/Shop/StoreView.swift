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
        return List {
            
            ForEach(self.stores.get_stores(), id: \.self) { i in
            
                NavigationLink(destination: StoreDetailView(store_id: i.id)) {
                    HStack {
                        Text(i.name)
                        Text(String(i.id))
                        
                        Spacer()

                        Text("배달")
                            .foregroundColor(i.delivery ? Color("squash") : Color.black.opacity(0.7))
                            .accentColor(i.delivery ? Color("squash") : Color.black.opacity(0.7))
                        
                        Text("카드결제")
                        .foregroundColor(i.payCard ? Color("squash") : Color.black.opacity(0.7))
                        .accentColor(i.payCard ? Color("squash") : Color.black.opacity(0.7))
                        
                        Text("계좌이체")
                        .foregroundColor(i.payBank ? Color("squash") : Color.black.opacity(0.7))
                        .accentColor(i.payBank ? Color("squash") : Color.black.opacity(0.7))
                        
                    }
                }
            }
        }
    }
}

struct StoreView_Previews: PreviewProvider {
    static var previews: some View {
        StoreView(stores: StoreController())
    }
}
