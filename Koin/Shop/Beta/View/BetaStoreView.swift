//
//  BetaStoreView.swift
//  Koin
//
//  Created by 정태훈 on 2020/05/19.
//  Copyright © 2020 정태훈. All rights reserved.
//

import SwiftUI
import PKHUD

struct BetaStoreView: View {
    @ObservedObject var viewModel: StoreViewModel
    
    init(viewModel: StoreViewModel) {
        self.viewModel = viewModel
        self.viewModel.load()
        HUD.show(.progress)
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
                    if(self.viewModel.category == "S005") {
                        self.viewModel.category = ""
                    } else {
                        self.viewModel.category = "S005"
                    }
                }) {
                    VStack {
                        Image("store_category_chicken")
                            .renderingMode(.original)
                            .resizable()
                            .frame(width: 50, height: 50)
                            .padding(.bottom, 5)
                        Text("치킨").accentColor(self.viewModel.category == "S005" ? Color("squash") : Color("black"))
                            .font(.system(size: 13))
                    }
                }
                Button(action: {
                    if(self.viewModel.category == "S006") {
                    self.viewModel.category = ""
                } else {
                    self.viewModel.category = "S006"
                    }
                    
                }) {
                        VStack {
                            Image("store_category_pizza")
                                .renderingMode(.original)
                                .resizable()
                                .frame(width: 50, height: 50)
                                .padding(.bottom, 5)
                            Text("피자").accentColor(self.viewModel.category == "S006" ? Color("squash") : Color("black"))
                                .font(.system(size: 13))
                        }
                }
                Button(action: {
                    if(self.viewModel.category == "S007") {
                        self.viewModel.category = ""
                    } else {
                        self.viewModel.category = "S007"
                    }
                }) {
                        VStack {
                            Image("store_category_sweet_pork")
                                .renderingMode(.original)
                                .resizable()
                                .frame(width: 50, height: 50)
                                .padding(.bottom, 5)
                            Text("탕수육").accentColor(self.viewModel.category == "S007" ? Color("squash") : Color("black"))
                                .font(.system(size: 13))
                        }
                }
                
                Button(action: {
                    if(self.viewModel.category == "S002") {
                        self.viewModel.category = ""
                    } else {
                        self.viewModel.category = "S002"
                    }
                }) {
                        VStack {
                            Image("store_category_sweet_dosirak")
                                .renderingMode(.original)
                                .resizable()
                                .frame(width: 50, height: 50)
                                .padding(.bottom, 5)
                            Text("도시락").accentColor(self.viewModel.category == "S002" ? Color("squash") : Color("black"))
                                .font(.system(size: 13))
                        }
                }
                Button(action: {
                    if(self.viewModel.category == "S003") {
                        self.viewModel.category = ""
                    } else {
                        self.viewModel.category = "S003"
                    }
                }) {
                        VStack {
                            Image("store_category_sweet_pork_feet")
                                .renderingMode(.original)
                                .resizable()
                                .frame(width: 50, height: 50)
                                .padding(.bottom, 5)
                            Text("족발").accentColor(self.viewModel.category == "S003" ? Color("squash") : Color("black"))
                                .font(.system(size: 13))
                        }
                }
            }
            HStack(alignment: .center, spacing: 20) {
                Button(action: {
                    if(self.viewModel.category == "S004") {
                        self.viewModel.category = ""
                    } else {
                        self.viewModel.category = "S004"
                    }
                }) {
                        VStack {
                            Image("store_category_chinese")
                                .renderingMode(.original)
                                .resizable()
                                .frame(width: 50, height: 50)
                                .padding(.bottom, 5)
                            Text("중국집").accentColor(self.viewModel.category == "S004" ? Color("squash") : Color("black"))
                                .font(.system(size: 13))
                        }
                }
                Button(action: {
                    if(self.viewModel.category == "S008") {
                        self.viewModel.category = ""
                    } else {
                        self.viewModel.category = "S008"
                    }
                }) {
                        VStack {
                            Image("store_category_normal")
                                .renderingMode(.original)
                                .resizable()
                                .frame(width: 50, height: 50)
                                .padding(.bottom, 5)
                            Text("일반음식점").accentColor(self.viewModel.category == "S008" ? Color("squash") : Color("black"))
                                .font(.system(size: 13))
                        }
                }
                Button(action: {
                    if(self.viewModel.category == "S009") {
                        self.viewModel.category = ""
                    } else {
                        self.viewModel.category = "S009"
                    }
                }) {
                        VStack {
                            Image("store_category_hair")
                                .renderingMode(.original)
                                .resizable()
                                .frame(width: 50, height: 50)
                                .padding(.bottom, 5)
                            Text("미용실").accentColor(self.viewModel.category == "S009" ? Color("squash") : Color("black"))
                                .font(.system(size: 13))
                        }
                }
                Button(action: {
                    if(self.viewModel.category == "S001") {
                        self.viewModel.category = ""
                    } else {
                        self.viewModel.category = "S001"
                    }
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
                            Text("기타").accentColor(self.viewModel.category == "S001" ? Color("squash") : Color("black"))
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
            
            
            ForEach(self.viewModel.data) { c in
                if (c.category == self.viewModel.category || self.viewModel.category == "") {
                    StoreRow(viewModel: c)
                        .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                }
            }
        }.onReceive(self.viewModel.result) { result in
            HUD.hide()
        }
    }
}


