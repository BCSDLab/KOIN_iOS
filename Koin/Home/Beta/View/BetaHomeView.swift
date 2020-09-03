//
//  BetaHomeView.swift
//  Koin
//
//  Created by 정태훈 on 2020/08/26.
//  Copyright © 2020 정태훈. All rights reserved.
//

import SwiftUI

struct BetaHomeView: View {
    
    @EnvironmentObject var tabData: ViewRouter
    @EnvironmentObject var config: UserConfig
    @ObservedObject var viewModel: HomeViewModel
    
    @State var nowDate: Date = Date()
    
    init() {
        self.viewModel = HomeViewModel()
    }
    
    @Environment(\.managedObjectContext) var managedObjectContext
    
    let storeCategoryList: [StoreCategory] =
    [
        StoreCategory(
            thumbnail: "store_category_chicken",
            category: "S005",
            name: "치킨"),
        StoreCategory(
            thumbnail: "store_category_pizza",
            category: "S006",
            name: "피자"),
        StoreCategory(
            thumbnail: "store_category_sweet_pork",
            category: "S007",
            name: "탕수육"),
        StoreCategory(
            thumbnail: "store_category_sweet_dosirak",
            category: "S002",
            name: "도시락"),
        StoreCategory(
            thumbnail: "store_category_sweet_pork_feet",
            category: "S003",
            name: "족발"),
        StoreCategory(
            thumbnail: "store_category_chinese",
            category: "S004",
            name: "중국집"),
        StoreCategory(
            thumbnail: "store_category_normal",
            category: "S008",
            name: "일반음식점"),
        StoreCategory(
            thumbnail: "store_category_hair",
            category: "S009",
            name: "미용실"),
        StoreCategory(
            thumbnail: "...",
            category: "S000",
            name: "기타"),
    ]

    
    func currentTimeToString(time: String) -> String {
        switch(time) {
            case "BREAKFAST":
                return "아침"
            case "LUNCH":
                return "점심"
            case "DINNER":
                return "저녁"
            default:
                return ""
        }
    }
    
    func currentPlaceToString(place: String) -> String {
        switch(place) {
            case "koreatech":
                return "한기대"
            case "terminal":
                return "야우리"
            case "station":
                return "천안역"
            default:
                return ""
        }
    }
    
    var timer: Timer {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {_ in
            self.nowDate = Date()
        }
    }
    //시분초 단위로 분래
    func countDownString(from date: Date, until nowDate: Date) -> String {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar
            .dateComponents([.hour, .minute, .second]
                ,from: nowDate,
                 to: date)
        return String(format: "%02d시간 %02d분 %02d초",
                      components.hour ?? 00,
                      components.minute ?? 00,
                      components.second ?? 00)
    }
    
    
    var body: some View {
        GeometryReader { geometry in
            //ScrollView(.vertical) {
            VStack(alignment: .center, spacing: 0){
                    
                    Text("버스/교통")
                        .font(.system(size: 15))
                        .foregroundColor(Color("light_navy"))
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 11)
                        .padding(.leading, 20)
                    
                    CarouselView(itemHeight: 135, views: [
                        AnyView(VStack(spacing: 0){
                            HStack(spacing: 0){
                                Spacer()
                                Image("homeBus")
                                    .renderingMode(.template)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 14)
                                    .foregroundColor(.white)
                                .padding(.trailing, 4)
                                Text("학교셔틀")
                                    .font(.system(size: 12))
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.vertical, 9)
                                Spacer()
                            }
                            .background(Color("squash").frame(maxWidth: .infinity))
                                .frame(maxWidth: .infinity)
                            
                            if(self.viewModel.shuttleTime.timeIntervalSince(Date()) > 0) {
                                HStack(spacing: 0){
                                    Text(self.countDownString(from: self.viewModel.shuttleTime, until: self.nowDate))
                                        .font(.system(size: 16))
                                        .fontWeight(.medium)
                                        .kerning(-0.8)
                                        .foregroundColor(Color("black"))
                                        .onAppear(perform: {
                                            let _ = self.timer
                                        })
                                    Text(" 남음")
                                        .font(.system(size: 16))
                                        .fontWeight(.medium)
                                        .kerning(-0.8)
                                        .foregroundColor(Color("black"))
                                }.padding(.top, 23)
                            } else {
                                Text("운행 정보 없음")
                                    .font(.system(size: 16))
                                    .fontWeight(.medium)
                                    .kerning(-0.8)
                                    .foregroundColor(Color("black"))
                                    .padding(.top, 23)
                            }
                            
                            HStack(spacing: 0){
                                Text(self.viewModel.isChange ? "야우리" : "한기대")
                                    .font(.system(size: 12))
                                    .kerning(-0.6)
                                    .foregroundColor(Color("black"))
                                Button(action: {
                                    self.viewModel.changeBusPlace()
                                }) {
                                    Image("homeBusChangeIcon")
                                        .renderingMode(.original)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 16)
                                        .padding(.horizontal, 11)
                                }
                                Text(self.viewModel.isChange ? "한기대" : "야우리")
                                    .font(.system(size: 12))
                                    .kerning(-0.6)
                                    .foregroundColor(Color("black"))
                            }.padding(.top, 12)
                            Spacer()
                        }),
                        AnyView(VStack(spacing: 0){
                            HStack(spacing: 0){
                                Spacer()
                                Image("homeBus")
                                    .renderingMode(.template)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 14)
                                    .foregroundColor(.white)
                                .padding(.trailing, 4)
                                Text("대성고속")
                                    .font(.system(size: 12))
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.vertical, 9)
                                Spacer()
                            }
                            .background(Color("shark").frame(maxWidth: .infinity))
                            .frame(maxWidth: .infinity)
                            if(self.viewModel.expressTime.timeIntervalSince(Date()) > 0) {
                                HStack(spacing: 0){
                                    Text(self.countDownString(from: self.viewModel.expressTime, until: self.nowDate))
                                        .font(.system(size: 16))
                                        .fontWeight(.medium)
                                        .kerning(-0.8)
                                        .foregroundColor(Color("black"))
                                        .onAppear(perform: {
                                            let _ = self.timer
                                        })
                                    Text(" 남음")
                                        .font(.system(size: 16))
                                        .fontWeight(.medium)
                                        .kerning(-0.8)
                                        .foregroundColor(Color("black"))
                                }.padding(.top, 23)
                            } else {
                                Text("운행 정보 없음")
                                    .font(.system(size: 16))
                                    .fontWeight(.medium)
                                    .kerning(-0.8)
                                    .foregroundColor(Color("black"))
                                    .padding(.top, 23)
                            }
                            HStack(spacing: 0){
                                Text(self.viewModel.isChange ? "야우리" : "한기대")
                                    .font(.system(size: 12))
                                    .kerning(-0.6)
                                    .foregroundColor(Color("black"))
                                Button(action: {
                                    self.viewModel.changeBusPlace()
                                }) {
                                    Image("homeBusChangeIcon")
                                        .renderingMode(.original)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 16)
                                        .padding(.horizontal, 11)
                                }
                                Text(self.viewModel.isChange ? "한기대" :  "야우리")
                                    .font(.system(size: 12))
                                    .kerning(-0.6)
                                    .foregroundColor(Color("black"))
                            }.padding(.top, 12)
                            Spacer()
                        }),
                        AnyView(VStack(spacing: 0){
                            HStack(spacing: 0){
                                Spacer()
                                Image("homeBus")
                                    .renderingMode(.template)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 14)
                                    .foregroundColor(.white)
                                    .padding(.trailing, 4)
                                Text("시내버스")
                                    .font(.system(size: 12))
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.vertical, 9)
                                Spacer()
                            }
                            .background(Color("mint").frame(maxWidth: .infinity))
                            .frame(maxWidth: .infinity)
                            if(self.viewModel.cityBusTime.timeIntervalSince(Date()) > 0) {
                                HStack(spacing: 0){
                                    Text(self.countDownString(from: self.viewModel.cityBusTime, until: self.nowDate))
                                        .font(.system(size: 16))
                                        .fontWeight(.medium)
                                        .kerning(-0.8)
                                        .foregroundColor(Color("black"))
                                        .onAppear(perform: {
                                            let _ = self.timer
                                        })
                                    Text(" 남음")
                                        .font(.system(size: 16))
                                        .fontWeight(.medium)
                                        .kerning(-0.8)
                                        .foregroundColor(Color("black"))
                                }.padding(.top, 23)
                            } else {
                                Text("운행 정보 없음")
                                    .font(.system(size: 16))
                                    .fontWeight(.medium)
                                    .kerning(-0.8)
                                    .foregroundColor(Color("black"))
                                    .padding(.top, 23)
                            }
                            HStack(spacing: 0){
                                Text(self.viewModel.isChange ? "야우리" : "한기대")
                                    .font(.system(size: 12))
                                    .kerning(-0.6)
                                    .foregroundColor(Color("black"))
                                Button(action: {
                                    self.viewModel.changeBusPlace()
                                }) {
                                    Image("homeBusChangeIcon")
                                        .renderingMode(.original)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 16)
                                        .padding(.horizontal, 11)
                                }
                                Text(self.viewModel.isChange ? "한기대" :  "야우리")
                                    .font(.system(size: 12))
                                    .kerning(-0.6)
                                    .foregroundColor(Color("black"))
                            }.padding(.top, 12)
                            Spacer()
                        }),
                        AnyView(VStack(spacing: 0){
                            HStack(spacing: 0){
                                Spacer()
                                Image("homeBus")
                                    .renderingMode(.template)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 14)
                                    .foregroundColor(.white)
                                .padding(.trailing, 4)
                                Text("학교셔틀")
                                    .font(.system(size: 12))
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.vertical, 9)
                                Spacer()
                            }
                            .background(Color("squash").frame(maxWidth: .infinity))
                                .frame(maxWidth: .infinity)
                            
                            if(self.viewModel.shuttleTime.timeIntervalSince(Date()) > 0) {
                                HStack(spacing: 0){
                                    Text(self.countDownString(from: self.viewModel.shuttleTime, until: self.nowDate))
                                        .font(.system(size: 16))
                                        .fontWeight(.medium)
                                        .kerning(-0.8)
                                        .foregroundColor(Color("black"))
                                        .onAppear(perform: {
                                            let _ = self.timer
                                        })
                                    Text(" 남음")
                                        .font(.system(size: 16))
                                        .fontWeight(.medium)
                                        .kerning(-0.8)
                                        .foregroundColor(Color("black"))
                                }.padding(.top, 23)
                            } else {
                                Text("운행 정보 없음")
                                    .font(.system(size: 16))
                                    .fontWeight(.medium)
                                    .kerning(-0.8)
                                    .foregroundColor(Color("black"))
                                    .padding(.top, 23)
                            }
                            
                            HStack(spacing: 0){
                                Text(self.viewModel.isChange ? "야우리" : "한기대")
                                    .font(.system(size: 12))
                                    .kerning(-0.6)
                                    .foregroundColor(Color("black"))
                                Button(action: {
                                    self.viewModel.changeBusPlace()
                                }) {
                                    Image("homeBusChangeIcon")
                                        .renderingMode(.original)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 16)
                                        .padding(.horizontal, 11)
                                }
                                Text(self.viewModel.isChange ? "한기대" : "야우리")
                                    .font(.system(size: 12))
                                    .kerning(-0.6)
                                    .foregroundColor(Color("black"))
                            }.padding(.top, 12)
                            Spacer()
                        }),
                        AnyView(VStack(spacing: 0){
                            HStack(spacing: 0){
                                Spacer()
                                Image("homeBus")
                                    .renderingMode(.template)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 14)
                                    .foregroundColor(.white)
                                .padding(.trailing, 4)
                                Text("대성고속")
                                    .font(.system(size: 12))
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.vertical, 9)
                                Spacer()
                            }
                            .background(Color("shark").frame(maxWidth: .infinity))
                            .frame(maxWidth: .infinity)
                            if(self.viewModel.expressTime.timeIntervalSince(Date()) > 0) {
                                HStack(spacing: 0){
                                    Text(self.countDownString(from: self.viewModel.expressTime, until: self.nowDate))
                                        .font(.system(size: 16))
                                        .fontWeight(.medium)
                                        .kerning(-0.8)
                                        .foregroundColor(Color("black"))
                                        .onAppear(perform: {
                                            let _ = self.timer
                                        })
                                    Text(" 남음")
                                        .font(.system(size: 16))
                                        .fontWeight(.medium)
                                        .kerning(-0.8)
                                        .foregroundColor(Color("black"))
                                }.padding(.top, 23)
                            } else {
                                Text("운행 정보 없음")
                                    .font(.system(size: 16))
                                    .fontWeight(.medium)
                                    .kerning(-0.8)
                                    .foregroundColor(Color("black"))
                                    .padding(.top, 23)
                            }
                            HStack(spacing: 0){
                                Text(self.viewModel.isChange ? "야우리" : "한기대")
                                    .font(.system(size: 12))
                                    .kerning(-0.6)
                                    .foregroundColor(Color("black"))
                                Button(action: {
                                    self.viewModel.changeBusPlace()
                                }) {
                                    Image("homeBusChangeIcon")
                                        .renderingMode(.original)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 16)
                                        .padding(.horizontal, 11)
                                }
                                Text(self.viewModel.isChange ? "한기대" :  "야우리")
                                    .font(.system(size: 12))
                                    .kerning(-0.6)
                                    .foregroundColor(Color("black"))
                            }.padding(.top, 12)
                            Spacer()
                        }),
                        AnyView(VStack(spacing: 0){
                            HStack(spacing: 0){
                                Spacer()
                                Image("homeBus")
                                    .renderingMode(.template)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 14)
                                    .foregroundColor(.white)
                                    .padding(.trailing, 4)
                                Text("시내버스")
                                    .font(.system(size: 12))
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.vertical, 9)
                                Spacer()
                            }
                            .background(Color("mint").frame(maxWidth: .infinity))
                            .frame(maxWidth: .infinity)
                            if(self.viewModel.cityBusTime.timeIntervalSince(Date()) > 0) {
                                HStack(spacing: 0){
                                    Text(self.countDownString(from: self.viewModel.cityBusTime, until: self.nowDate))
                                        .font(.system(size: 16))
                                        .fontWeight(.medium)
                                        .kerning(-0.8)
                                        .foregroundColor(Color("black"))
                                        .onAppear(perform: {
                                            let _ = self.timer
                                        })
                                    Text(" 남음")
                                        .font(.system(size: 16))
                                        .fontWeight(.medium)
                                        .kerning(-0.8)
                                        .foregroundColor(Color("black"))
                                }.padding(.top, 23)
                            } else {
                                Text("운행 정보 없음")
                                    .font(.system(size: 16))
                                    .fontWeight(.medium)
                                    .kerning(-0.8)
                                    .foregroundColor(Color("black"))
                                    .padding(.top, 23)
                            }
                            HStack(spacing: 0){
                                Text(self.viewModel.isChange ? "야우리" : "한기대")
                                    .font(.system(size: 12))
                                    .kerning(-0.6)
                                    .foregroundColor(Color("black"))
                                Button(action: {
                                    self.viewModel.changeBusPlace()
                                }) {
                                    Image("homeBusChangeIcon")
                                        .renderingMode(.original)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 16)
                                        .padding(.horizontal, 11)
                                }
                                Text(self.viewModel.isChange ? "한기대" :  "야우리")
                                    .font(.system(size: 12))
                                    .kerning(-0.6)
                                    .foregroundColor(Color("black"))
                            }.padding(.top, 12)
                            Spacer()
                        }),
                        AnyView(VStack(spacing: 0){
                            HStack(spacing: 0){
                                Spacer()
                                Image("homeBus")
                                    .renderingMode(.template)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 14)
                                    .foregroundColor(.white)
                                .padding(.trailing, 4)
                                Text("학교셔틀")
                                    .font(.system(size: 12))
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.vertical, 9)
                                Spacer()
                            }
                            .background(Color("squash").frame(maxWidth: .infinity))
                                .frame(maxWidth: .infinity)
                            
                            if(self.viewModel.shuttleTime.timeIntervalSince(Date()) > 0) {
                                HStack(spacing: 0){
                                    Text(self.countDownString(from: self.viewModel.shuttleTime, until: self.nowDate))
                                        .font(.system(size: 16))
                                        .fontWeight(.medium)
                                        .kerning(-0.8)
                                        .foregroundColor(Color("black"))
                                        .onAppear(perform: {
                                            let _ = self.timer
                                        })
                                    Text(" 남음")
                                        .font(.system(size: 16))
                                        .fontWeight(.medium)
                                        .kerning(-0.8)
                                        .foregroundColor(Color("black"))
                                }.padding(.top, 23)
                            } else {
                                Text("운행 정보 없음")
                                    .font(.system(size: 16))
                                    .fontWeight(.medium)
                                    .kerning(-0.8)
                                    .foregroundColor(Color("black"))
                                    .padding(.top, 23)
                            }
                            
                            HStack(spacing: 0){
                                Text(self.viewModel.isChange ? "야우리" : "한기대")
                                    .font(.system(size: 12))
                                    .kerning(-0.6)
                                    .foregroundColor(Color("black"))
                                Button(action: {
                                    self.viewModel.changeBusPlace()
                                }) {
                                    Image("homeBusChangeIcon")
                                        .renderingMode(.original)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 16)
                                        .padding(.horizontal, 11)
                                }
                                Text(self.viewModel.isChange ? "한기대" : "야우리")
                                    .font(.system(size: 12))
                                    .kerning(-0.6)
                                    .foregroundColor(Color("black"))
                            }.padding(.top, 12)
                            Spacer()
                        }),
                        AnyView(VStack(spacing: 0){
                            HStack(spacing: 0){
                                Spacer()
                                Image("homeBus")
                                    .renderingMode(.template)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 14)
                                    .foregroundColor(.white)
                                .padding(.trailing, 4)
                                Text("대성고속")
                                    .font(.system(size: 12))
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.vertical, 9)
                                Spacer()
                            }
                            .background(Color("shark").frame(maxWidth: .infinity))
                            .frame(maxWidth: .infinity)
                            if(self.viewModel.expressTime.timeIntervalSince(Date()) > 0) {
                                HStack(spacing: 0){
                                    Text(self.countDownString(from: self.viewModel.expressTime, until: self.nowDate))
                                        .font(.system(size: 16))
                                        .fontWeight(.medium)
                                        .kerning(-0.8)
                                        .foregroundColor(Color("black"))
                                        .onAppear(perform: {
                                            let _ = self.timer
                                        })
                                    Text(" 남음")
                                        .font(.system(size: 16))
                                        .fontWeight(.medium)
                                        .kerning(-0.8)
                                        .foregroundColor(Color("black"))
                                }.padding(.top, 23)
                            } else {
                                Text("운행 정보 없음")
                                    .font(.system(size: 16))
                                    .fontWeight(.medium)
                                    .kerning(-0.8)
                                    .foregroundColor(Color("black"))
                                    .padding(.top, 23)
                            }
                            HStack(spacing: 0){
                                Text(self.viewModel.isChange ? "야우리" : "한기대")
                                    .font(.system(size: 12))
                                    .kerning(-0.6)
                                    .foregroundColor(Color("black"))
                                Button(action: {
                                    self.viewModel.changeBusPlace()
                                }) {
                                    Image("homeBusChangeIcon")
                                        .renderingMode(.original)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 16)
                                        .padding(.horizontal, 11)
                                }
                                Text(self.viewModel.isChange ? "한기대" :  "야우리")
                                    .font(.system(size: 12))
                                    .kerning(-0.6)
                                    .foregroundColor(Color("black"))
                            }.padding(.top, 12)
                            Spacer()
                        }),
                        AnyView(VStack(spacing: 0){
                            HStack(spacing: 0){
                                Spacer()
                                Image("homeBus")
                                    .renderingMode(.template)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 14)
                                    .foregroundColor(.white)
                                    .padding(.trailing, 4)
                                Text("시내버스")
                                    .font(.system(size: 12))
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.vertical, 9)
                                Spacer()
                            }
                            .background(Color("mint").frame(maxWidth: .infinity))
                            .frame(maxWidth: .infinity)
                            if(self.viewModel.cityBusTime.timeIntervalSince(Date()) > 0) {
                                HStack(spacing: 0){
                                    Text(self.countDownString(from: self.viewModel.cityBusTime, until: self.nowDate))
                                        .font(.system(size: 16))
                                        .fontWeight(.medium)
                                        .kerning(-0.8)
                                        .foregroundColor(Color("black"))
                                        .onAppear(perform: {
                                            let _ = self.timer
                                        })
                                    Text(" 남음")
                                        .font(.system(size: 16))
                                        .fontWeight(.medium)
                                        .kerning(-0.8)
                                        .foregroundColor(Color("black"))
                                }.padding(.top, 23)
                            } else {
                                Text("운행 정보 없음")
                                    .font(.system(size: 16))
                                    .fontWeight(.medium)
                                    .kerning(-0.8)
                                    .foregroundColor(Color("black"))
                                    .padding(.top, 23)
                            }
                            HStack(spacing: 0){
                                Text(self.viewModel.isChange ? "야우리" : "한기대")
                                    .font(.system(size: 12))
                                    .kerning(-0.6)
                                    .foregroundColor(Color("black"))
                                Button(action: {
                                    self.viewModel.changeBusPlace()
                                }) {
                                    Image("homeBusChangeIcon")
                                        .renderingMode(.original)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 16)
                                        .padding(.horizontal, 11)
                                }
                                Text(self.viewModel.isChange ? "한기대" :  "야우리")
                                    .font(.system(size: 12))
                                    .kerning(-0.6)
                                    .foregroundColor(Color("black"))
                            }.padding(.top, 12)
                            Spacer()
                        }),
                    ]).padding(.bottom, 30)
                    
                    Text("주변상점")
                        .font(.system(size: 15))
                        .foregroundColor(Color("light_navy"))
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 11)
                        .padding(.leading, 20)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack{
                            ForEach(self.storeCategoryList, id: \.self) { (category: StoreCategory) in
                                VStack{
                                    if (category.thumbnail != "...") {
                                        Button(action: {
                                            self.tabData.storeCategory = category.category
                                            self.tabData.currentView = "store"
                                        }) {
                                            VStack {
                                                Image(category.thumbnail)
                                                    .renderingMode(.original)
                                                    .resizable()
                                                    .frame(width: 50, height: 50)
                                                    .padding(.bottom, 5)
                                                Text(category.name).accentColor(Color("black"))
                                                    .font(.system(size: 13))
                                            }
                                        }
                                    } else {
                                        Button(action: {
                                            self.tabData.storeCategory = category.category
                                            self.tabData.currentView = "store"
                                        }) {
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
                                                Text("기타")
                                                    .accentColor(Color("black"))
                                                    .font(.system(size: 13))
                                            }
                                            
                                        }
                                    }
                                }
                            }
                        }.padding(.horizontal, 20)
                    }.padding(.bottom, 30)
                    
                    
                    Text("식단")
                        .font(.system(size: 15))
                        .foregroundColor(Color("light_navy"))
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 15)
                        .padding(.leading, 20)
                    
                    VStack {
                        
                        VStack{
                            HStack(spacing: 20){
                                ForEach(self.viewModel.currentMeal.filter { (m: DiningRequest) in
                                    m.type == self.viewModel.currentMealTime
                                }) { (meal: DiningRequest) in
                                    Button(action: {
                                        self.viewModel.setMealPlace(place: meal.place)
                                    }) {
                                        Text(meal.place)
                                            .font(.system(size: 13))
                                            .foregroundColor(self.viewModel.selectedPlace == meal.place ? Color("light_navy") : Color(red: 153/255, green: 153/255, blue: 153/255))
                                    }
                                }
                                Spacer()
                                Text(self.currentTimeToString(time: self.viewModel.currentMealTime))
                                    .font(.system(size: 13))
                                .foregroundColor(Color("black"))
                            }.padding(EdgeInsets(top: 18, leading: 16, bottom: 27, trailing: 16))
                            
                            if(self.viewModel.currentMeal.filter { (m: DiningRequest) in
                                m.type == self.viewModel.currentMealTime
                            }.count == 0) {
                                Text("운영중인 식단이 없습니다.")
                                    .font(.system(size: 12))
                                    .foregroundColor(Color("black"))
                                    .padding(.bottom, 27)
                            } else {
                                /*ForEach(self.viewModel.currentMeal.first(where: {
                                    $0.type == self.viewModel.currentMealTime && $0.place == self.viewModel.selectedPlace
                                    })!.menu, id: \.self) { (menu: String) in
                                    Text(menu)
                                        .font(.system(size: 12))
                                        .foregroundColor(Color("black"))
                                    
                                }*/
                                Grid(self.viewModel.currentMeal.first(where: {
                                    $0.type == self.viewModel.currentMealTime && $0.place == self.viewModel.selectedPlace
                                })?.menu ?? [], id: \.self) { m in
                                    Text(m)
                                        .font(.system(size: 12))
                                        .foregroundColor(Color("black"))
                                }.gridStyle(StaggeredGridStyle(tracks: 2))
                                .padding(.bottom, 27)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .top)
                        .background(Color.white.shadow(color: Color.black.opacity(0.25), radius: 4, x: 0, y: 2))
                        
                        
                    }.padding(.horizontal, 20)
                    
                    
                    Spacer()
                    
                    
                    
                }.padding(EdgeInsets(top: 50, leading: 0, bottom: 60, trailing: 0))
            //}
                //.navigationBarHidden(true)
                
        }.onAppear{
            self.tabData.openNavigationBar()
            self.tabData.currentView = "home"
        }
    }
}

struct BetaHomeView_Previews: PreviewProvider {
    static var previews: some View {
        BetaHomeView()
    }
}
