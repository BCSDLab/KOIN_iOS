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
    @ObservedObject var stores: StoreController

    init() {
        self.stores = StoreController()
    }

//종류
    //기타(S000), 콜벤(S001), 정식(S002), 족발(S003), 중국집(S004), 치킨(S005), 피자(S006), 탕수육(S007), 일반(S008), 미용실(S009)
    var body: some View {
        return ScrollView(.vertical) {
            HStack(alignment: .center, spacing: 15) {
                Button(action: { self.stores.get_stores(category: "S005") }) {
                    VStack {
                        Image("store_category_chicken")
                                .renderingMode(.original)
                        //.frame(width: 35, height: 35)
                        Text("치킨")
                    }
                }
                Button(action: { self.stores.get_stores(category: "S006") }) {
                    VStack {
                        Image("store_category_pizza")
                                .renderingMode(.original)
                        //.frame(width: 35, height: 35)
                        Text("피자")
                    }
                }
                Button(action: { self.stores.get_stores(category: "S007") }) {
                    VStack {
                        Image("store_category_sweet_pork")
                                .renderingMode(.original)
                        //.frame(width: 35, height: 35)
                        Text("탕수육")
                    }
                }

                Button(action: { self.stores.get_stores(category: "S002") }) {
                    VStack {
                        Image("store_category_sweet_dosirak")
                                .renderingMode(.original)
                        //.frame(width: 35, height: 35)
                        Text("도시락")
                    }
                }
                Button(action: { self.stores.get_stores(category: "S003") }) {
                    VStack {
                        Image("store_category_sweet_pork_feet")
                                .renderingMode(.original)
                        //.frame(width: 35, height: 35)
                        Text("족발")
                    }
                }


            }
            HStack(alignment: .center, spacing: 15) {

                Button(action: { self.stores.get_stores(category: "S004") }) {
                    VStack {
                        Image("store_category_chinese")
                                .renderingMode(.original)
                        //.frame(width: 35, height: 35)
                        Text("중국집")
                    }
                }
                Button(action: { self.stores.get_stores(category: "S008") }) {
                    VStack {
                        Image("store_category_normal")
                                .renderingMode(.original)
                        //.frame(width: 35, height: 35)
                        Text("일반음식점")
                    }
                }
                Button(action: { self.stores.get_stores(category: "S009") }) {
                    VStack {
                        Image("store_category_hair")
                                .renderingMode(.original)
                        //.frame(width: 35, height: 35)
                        Text("미용실")
                    }
                }
                Button(action: { self.stores.get_stores(category: "S001") }) {
                    VStack {
                        Circle().foregroundColor(Color("black"))
                                .frame(width: 50, height: 50).padding(.all, 0)
                        Text("기타")
                    }
                }
            }

            ForEach(self.stores.get_stores(), id: \.self) { i in

                StoreCellView(store_name: i.name, store_id: i.id, is_event: i.isEvent, is_delevery: i.delivery, is_card: i.payCard, is_bank: i.payBank)


            }
        }.onAppear() {
            HUD.show(.progress)
            DispatchQueue.main.async {
                self.stores.store_session()
                self.stores.load_stores()
                HUD.hide()
            }
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
