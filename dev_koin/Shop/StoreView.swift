//
//  StoreView.swift
//  dev_koin
//
//  Created by 정태훈 on 2020/01/13.
//  Copyright © 2020 정태훈. All rights reserved.
//

import SwiftUI

struct StoreView: View {

    @ObservedObject var stores: StoreController
    
    init() {
        stores = StoreController()
    }
    

    var body: some View {
        return ScrollView(.vertical) {
            HStack {
                Button(action: {self.stores.get_stores(category: "S001")}) {
                    Text("1")
                }
                Button(action: {self.stores.get_stores(category: "S002")}) {
                    Text("2")
                }
                Button(action: {self.stores.get_stores(category: "S003")}) {
                    Text("3")
                }
                Button(action: {self.stores.get_stores(category: "S004")}) {
                    Text("4")
                }
                Button(action: {self.stores.get_stores(category: "S005")}) {
                    Text("5")
                }
            }
            HStack {
                Button(action: {self.stores.get_stores(category: "S006")}) {
                    Text("6")
                }
                Button(action: {self.stores.get_stores(category: "S007")}) {
                    Text("7")
                }
                Button(action: {self.stores.get_stores(category: "S008")}) {
                    Text("8")
                }
                Button(action: {self.stores.get_stores(category: "S009")}) {
                    Text("9")
                }
            }
            
            ForEach(self.stores.get_stores(), id: \.self) { i in
            
                NavigationLink(destination: StoreDetailView(store_id: i.id)) {
                    HStack {
                        Text(i.name)
                        Text(i.isEvent ? "(이벤트)": "")
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
        }.onAppear() {
            print("StoreView Appeared")
        }.onDisappear() {
            print("StoreView Disappeared")
        }
    }
}

struct StoreView_Previews: PreviewProvider {
    static var previews: some View {
        StoreView()
    }
}
