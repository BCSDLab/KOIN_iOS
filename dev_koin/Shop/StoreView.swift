//
//  StoreView.swift
//  dev_koin
//
//  Created by 정태훈 on 2020/01/13.
//  Copyright © 2020 정태훈. All rights reserved.
//

import SwiftUI
import PKHUD


struct StoreView: View {
    @ObservedObject var stores: StoreController = StoreController()

    init() {

            self.stores.store_session()
            self.stores.load_stores()

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
                Button(action: { self.stores.get_stores(category: "S008") }) {
                    Text("8")
                }
                Button(action: { self.stores.get_stores(category: "S009") }) {
                    Text("9")
                }
            }

            ForEach(self.stores.get_stores(), id: \.self) { i in

                StoreCellView(store_name: i.name, store_id: i.id, is_event: i.isEvent, is_delevery: i.delivery, is_card: i.payCard, is_bank: i.payBank)


            }
        }.onAppear() {
            print("StoreView Appeared")
        }.onDisappear() {
            print("StoreView Disappeared")
        }
    }
}

struct StoreCellView: View {
    var storeName: String
    var storeId: Int
    var isDelivery: Bool = false
    var isCard: Bool = false
    var isBank: Bool = false
    var isEvent: Bool = false

    init(store_name: String, store_id: Int, is_event: Bool, is_delevery: Bool, is_card: Bool, is_bank: Bool) {
        storeName = store_name
        storeId = store_id
        isEvent = is_event
        isDelivery = is_delevery
        isCard = is_card
        isBank = is_bank
    }

    var body: some View {
        NavigationLink(destination: StoreDetailView(store_id: storeId)) {
            HStack {
                HStack {
                    Text(storeName)
                            .fontWeight(.semibold)
                            .foregroundColor(Color.black.opacity(0.7))
                    if (isEvent) {
                        Image("event")
                                .renderingMode(.original)
                                .frame(height: 7)
                                //.resizable()
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    }
                }
                Spacer()

                Text("배달")
                        .foregroundColor(isDelivery ? Color("squash") : Color.black.opacity(0.3))

                Text("카드결제")
                        .foregroundColor(isCard ? Color("squash") : Color.black.opacity(0.3))

                Text("계좌이체")
                        .foregroundColor(isBank ? Color("squash") : Color.black.opacity(0.3))

            }.fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .cornerRadius(10)
                    .overlay(
                            RoundedRectangle(cornerRadius: 1)
                                    .stroke(Color("cloudy_blue"), lineWidth: 0.7)
                    )
                    .background(Color.white)
                    .padding([.horizontal, .top])
                    .clipped()
                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 1)
        }
    }
}

struct StoreView_Previews: PreviewProvider {
    static var previews: some View {
        StoreView()
    }
}
