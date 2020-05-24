//
//  StoreView.swift
//  dev_koin
//
//  Created by 정태훈 on 2020/01/13.
//  Copyright © 2020 정태훈. All rights reserved.
//
import SwiftUI
import PKHUD

/*
struct StoreView: View {
    @ObservedObject var stores: StoreController = StoreController()
    @State var category: String = ""
    
    init() {
        self.stores.store_session()
        self.stores.load_stores()
    }

    //기타(S000), 콜벤(S001), 정식(S002), 족발(S003), 중국집(S004), 치킨(S005), 피자(S006), 탕수육(S007), 일반(S008), 미용실(S009)
    var body: some View {
        return ScrollView(.vertical) {
            Text("카테고리")
                .font(.system(size: 15))
                .fontWeight(.medium)
            .foregroundColor(Color("black"))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                
            HStack(alignment: .center, spacing: 20) {
                Button(action: {
                    if(self.category != "S005") {
                    self.category = "S005"
                    self.stores.get_stores(category: "S005")
                } else {
                        self.category = ""
                        HUD.show(.progress)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                            self.stores.load_stores()
                            HUD.hide()
                        }
                    
                    }
                    
                }
                ) {
                    VStack {
                        Image("store_category_chicken")
                                .renderingMode(.original)
                            .resizable()
                            .frame(width: 50, height: 50)
                        .padding(.bottom, 5)
                        Text("치킨").accentColor(self.category == "S005" ? Color("squash") : Color("black"))
                            .font(.system(size: 13))
                    }
                }
                Button(action: { if(self.category != "S006") {
                    self.category = "S006"
                    self.stores.get_stores(category: "S006")
                } else {
                    self.category = ""
                    HUD.show(.progress)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        self.stores.load_stores()
                        HUD.hide()
                    }
                    } }) {
                    VStack {
                        Image("store_category_pizza")
                                .renderingMode(.original)
                        .resizable()
                        .frame(width: 50, height: 50)
                        .padding(.bottom, 5)
                        Text("피자").accentColor(self.category == "S006" ? Color("squash") : Color("black"))
                        .font(.system(size: 13))
                    }
                }
                Button(action: { if(self.category != "S007") {
                    self.category = "S007"
                    self.stores.get_stores(category: "S007")
                } else {
                    self.category = ""
                    HUD.show(.progress)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        self.stores.load_stores()
                        HUD.hide()
                    }
                    } }) {
                    VStack {
                        Image("store_category_sweet_pork")
                                .renderingMode(.original)
                        .resizable()
                        .frame(width: 50, height: 50)
                            .padding(.bottom, 5)
                        Text("탕수육").accentColor(self.category == "S007" ? Color("squash") : Color("black"))
                        .font(.system(size: 13))
                    }
                }

                Button(action: { if(self.category != "S002") {
                    self.category = "S002"
                    self.stores.get_stores(category: "S002")
                } else {
                    self.category = ""
                    HUD.show(.progress)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        self.stores.load_stores()
                        HUD.hide()
                    }
                    } }) {
                    VStack {
                        Image("store_category_sweet_dosirak")
                                .renderingMode(.original)
                        .resizable()
                        .frame(width: 50, height: 50)
                        .padding(.bottom, 5)
                        Text("도시락").accentColor(self.category == "S002" ? Color("squash") : Color("black"))
                        .font(.system(size: 13))
                    }
                }
                Button(action: { if(self.category != "S003") {
                    self.category = "S003"
                    self.stores.get_stores(category: "S003")
                } else {
                    self.category = ""
                    HUD.show(.progress)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        self.stores.load_stores()
                        HUD.hide()
                    }
                    } }) {
                    VStack {
                        Image("store_category_sweet_pork_feet")
                                .renderingMode(.original)
                        .resizable()
                        .frame(width: 50, height: 50)
                        .padding(.bottom, 5)
                        Text("족발").accentColor(self.category == "S003" ? Color("squash") : Color("black"))
                        .font(.system(size: 13))
                    }
                }
            }
            HStack(alignment: .center, spacing: 20) {
                Button(action: { if(self.category != "S004") {
                    self.category = "S004"
                    self.stores.get_stores(category: "S004")
                } else {
                    self.category = ""
                    HUD.show(.progress)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        self.stores.load_stores()
                        HUD.hide()
                    }
                    } }) {
                    VStack {
                        Image("store_category_chinese")
                                .renderingMode(.original)
                        .resizable()
                        .frame(width: 50, height: 50)
                        .padding(.bottom, 5)
                        Text("중국집").accentColor(self.category == "S004" ? Color("squash") : Color("black"))
                        .font(.system(size: 13))
                    }
                }
                Button(action: { if(self.category != "S008") {
                    self.category = "S008"
                    self.stores.get_stores(category: "S008")
                } else {
                    self.category = ""
                    HUD.show(.progress)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        self.stores.load_stores()
                        HUD.hide()
                    }
                    } }) {
                    VStack {
                        Image("store_category_normal")
                                .renderingMode(.original)
                        .resizable()
                        .frame(width: 50, height: 50)
                        .padding(.bottom, 5)
                        Text("일반음식점").accentColor(self.category == "S008" ? Color("squash") : Color("black"))
                        .font(.system(size: 13))
                    }
                }
                Button(action: { if(self.category != "S009") {
                    self.category = "S009"
                    self.stores.get_stores(category: "S009")
                } else {
                    self.category = ""
                    HUD.show(.progress)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        self.stores.load_stores()
                        HUD.hide()
                    }
                    } }) {
                    VStack {
                        Image("store_category_hair")
                                .renderingMode(.original)
                        .resizable()
                        .frame(width: 50, height: 50)
                        .padding(.bottom, 5)
                        Text("미용실").accentColor(self.category == "S009" ? Color("squash") : Color("black"))
                        .font(.system(size: 13))
                    }
                }
                Button(action: { if(self.category != "S001") {
                    self.category = "S001"
                    self.stores.get_stores(category: "S001")
                } else {
                    self.category = ""
                    HUD.show(.progress)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        self.stores.load_stores()
                        HUD.hide()
                    }
                    } }) {
                    VStack {
                        ZStack {
                            Circle()
                            .foregroundColor(Color("grey_circle"))
                                .frame(width: 50, height: 50)
                                .padding(.all, 0)
                            Text("···")
                                .foregroundColor(.white)
                                .font(.largeTitle)
                        }.padding(.bottom, 5)
                        
                        
                        
                        Text("기타").accentColor(self.category == "S001" ? Color("squash") : Color("black"))
                        .font(.system(size: 13))
                    }
                        
                }
            }.padding(.bottom, 10)
            HStack {
                Text("상점 목록")
                    .fontWeight(.medium)
                    .padding(.leading)
                    .foregroundColor(Color("warm_grey"))
                .font(.system(size: 13))
                Spacer()
                Image("event")
                .renderingMode(.original)
                .resizable()
                    .frame(width: 12,height: 17)
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                Text(": 이벤트 진행중")
                    .fontWeight(.medium)
                    .padding(.trailing)
                .foregroundColor(Color("warm_grey"))
                .font(.system(size: 10))
            }.frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(Color("store_list_title"))
                
            
            VStack {
            ForEach(self.stores.get_stores(), id: \.self) { i in

                    StoreCellView(store_name: i.name, store_id: i.id, is_event: i.isEvent, is_delevery: i.delivery, is_card: i.payCard, is_bank: i.payBank)


            }
            }
        }.onAppear {
            /*
            print("shop appear")
            HUD.show(.progress)
            DispatchQueue.main.async {
                self.stores.store_session()
                self.stores.load_stores()
                HUD.hide()
            }*/
        }.onDisappear {
            print("shop disappear")
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
        return Group {
            if (isEvent) {
                NavigationLink(destination: StoreDetailView(store_id: storeId)) {
                    HStack {
                                Text(storeName)
                                    .font(.system(size: 15))
                                        .fontWeight(.medium)
                                        .foregroundColor(Color("black"))
                                    Image("event")
                                            .renderingMode(.original)
                                            .resizable()
                                            .frame(width: 12,height: 17)
                        
                        Spacer()
                        HStack {
                        Text("배달")
                                .foregroundColor(isDelivery ? Color("squash") : Color("cloudy_blue"))
                            .font(.system(size: 12))

                        Text("카드결제")
                                .foregroundColor(isCard ? Color("squash") : Color("cloudy_blue"))
                            .font(.system(size: 12))

                        Text("계좌이체")
                                .foregroundColor(isBank ? Color("squash") : Color("cloudy_blue"))
                            .font(.system(size: 12))
                        }
                    }.padding(.vertical, 4)
                            .frame(maxWidth: .infinity)
                        .padding(.all, 16.5)
                            .overlay(
                                    Rectangle()
                                            .stroke(Color("cloudy_blue"), lineWidth: 1)
                            )
                            .background(Color.white)
                        //.padding(.vertical, 6)
                        //.padding(.horizontal, 10)
                            .clipped()
                    //.shadow(color: Color.black.opacity(0.25), radius: 1, x: 0, y: 0)
                }.padding(.horizontal, 16.5)
            } else {
                NavigationLink(destination: StoreDetailView(store_id: storeId)) {
                    HStack {
                                Text(storeName)
                                    .font(.system(size: 15))
                                        .fontWeight(.medium)
                                        .foregroundColor(Color("black"))
                        Image("")
                        .renderingMode(.original)
                        .resizable()
                        .frame(width: 12,height: 17)
                    
                        Spacer()
                        HStack {
                        Text("배달")
                                .foregroundColor(isDelivery ? Color("squash") : Color("cloudy_blue"))
                            .font(.system(size: 12))

                        Text("카드결제")
                                .foregroundColor(isCard ? Color("squash") : Color("cloudy_blue"))
                            .font(.system(size: 12))

                        Text("계좌이체")
                                .foregroundColor(isBank ? Color("squash") : Color("cloudy_blue"))
                            .font(.system(size: 12))
                        }//.padding([.vertical, .trailing], 10)
                    }.padding(.vertical, 4)
                            .frame(maxWidth: .infinity)
                        .padding(.all, 16.5)
                            .overlay(
                                    Rectangle()
                                            .stroke(Color("cloudy_blue"), lineWidth: 1)
                            )
                            .background(Color.white)
                        //.padding(.vertical, 6)
                        //.padding(.horizontal, 10)
                            .clipped()
                    //.shadow(color: Color.black.opacity(0.25), radius: 1, x: 0, y: 0)
                }.padding(.horizontal, 16.5)
            }
        }
        
    }
}

struct StoreView_Previews: PreviewProvider {
    static var previews: some View {
        StoreView()
    }
}
*/
