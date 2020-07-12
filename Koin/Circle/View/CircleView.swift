//
//  CircleView.swift
//  Koin
//
//  Created by 정태훈 on 2020/05/09.
//  Copyright © 2020 정태훈. All rights reserved.
//

import SwiftUI

struct CircleView: View {
    @ObservedObject var viewModel: CircleViewModel
    @EnvironmentObject var tabData: ViewRouter
    
    init() {
        self.viewModel = CircleViewModel()
    }
    
    var body: some View {
        List {
            VStack(alignment: .leading) {
                Text("카테고리")
                    .font(.system(size: 15))
                    .fontWeight(.medium)
                    .foregroundColor(Color("black"))
                    .padding(.top, 16)
                    .padding(.bottom, 8)
                HStack(alignment: .center){
                    Button(action: {
                        self.viewModel.category = ""
                    }) {
                        VStack {
                            Image("entire")
                                .resizable()
                                .frame(width: 32, height: 32)
                                .padding(.bottom, 8)
                                .foregroundColor(self.viewModel.category == "" ? Color("squash") : Color("circle_unselect_color"))
                            Text("전체보기")
                                .font(.system(size: 13))
                                .foregroundColor(.black)
                        }
                    }
                    Spacer()
                    Button(action: {
                        self.viewModel.category = "C001"
                    }) {
                        VStack {
                            Image("art")
                                .resizable()
                                .frame(width: 32, height: 32)
                                .padding(.bottom, 8)
                                .foregroundColor(self.viewModel.category == "C001" ? Color("squash") : Color("circle_unselect_color"))
                            Text("예술분야")
                                .font(.system(size: 13))
                                .foregroundColor(.black)
                        }
                    }
                    Spacer()
                    Button(action: {
                        self.viewModel.category = "C002"
                    }) {
                        VStack {
                            Image("mic")
                                .resizable()
                                .frame(width: 32, height: 32)
                                .padding(.bottom, 8)
                                .foregroundColor(self.viewModel.category == "C002" ? Color("squash") : Color("circle_unselect_color"))
                            Text("공연분야")
                                .font(.system(size: 13))
                                .foregroundColor(.black)
                        }
                    }
                    Spacer()
                    Button(action: {
                        self.viewModel.category = "C003"
                    }) {
                        VStack {
                            Image("trophy")
                                .resizable()
                                .frame(width: 32, height: 32)
                                .padding(.bottom, 8)
                                .foregroundColor(self.viewModel.category == "C003" ? Color("squash") : Color("circle_unselect_color"))
                            Text("운동분야")
                                .font(.system(size: 13))
                                .foregroundColor(.black)
                        }
                    }
                }.frame(minWidth: 0, idealWidth: .infinity, alignment: .center)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 10)
                    .listRowInsets(EdgeInsets())
                HStack(alignment: .center){
                    Button(action: {
                        self.viewModel.category = "C004"
                    }) {
                        VStack {
                            Image("study")
                                .resizable()
                                .frame(width: 32, height: 32)
                                .padding(.bottom, 8)
                                .foregroundColor(self.viewModel.category == "C004" ? Color("squash") : Color("circle_unselect_color"))
                            Text("학술분야")
                                .font(.system(size: 13))
                                .foregroundColor(.black)
                        }
                    }
                    Spacer()
                    Button(action: {
                        self.viewModel.category = "C005"
                    }) {
                        VStack {
                            Image("earth")
                                .resizable()
                                .frame(width: 32, height: 32)
                                .padding(.bottom, 8)
                                .foregroundColor(self.viewModel.category == "C005" ? Color("squash") : Color("circle_unselect_color"))
                            Text("종교분야")
                                .font(.system(size: 13))
                                .foregroundColor(.black)
                        }
                    }
                    Spacer()
                    Button(action: {
                        self.viewModel.category = "C006"
                    }) {
                        VStack {
                            Image("heart")
                                .resizable()
                                .frame(width: 32, height: 32)
                                .padding(.bottom, 8)
                                .foregroundColor(self.viewModel.category == "C006" ? Color("squash") : Color("circle_unselect_color"))
                            Text("사회분야")
                                .font(.system(size: 13))
                                .foregroundColor(.black)
                        }
                    }
                    Spacer()
                    Button(action: {
                        self.viewModel.category = "C007"
                    }) {
                        VStack {
                            Image("flag")
                                .resizable()
                                .frame(width: 32, height: 32)
                                .padding(.bottom, 8)
                                .foregroundColor(self.viewModel.category == "C007" ? Color("squash") : Color("circle_unselect_color"))
                            Text("준동아리")
                                .font(.system(size: 13))
                                .foregroundColor(.black)
                        }
                    }
                }.frame(minWidth: 0, idealWidth: .infinity, alignment: .center)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 10)
                    .listRowInsets(EdgeInsets())
            }.buttonStyle(PlainButtonStyle())
            HStack {
                Text("동아리 목록")
                    .font(.system(size: 13))
                    .foregroundColor(Color("warm_grey"))
                    .padding(.leading, 16)
                    .padding(.vertical, 8)
                Spacer()
            }.listRowInsets(EdgeInsets())
                .background(Color("pale_gray"))
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            ForEach(self.viewModel.data) { c in
                if (c.category == self.viewModel.category || self.viewModel.category == "") {
                    CircleCell(viewModel: c)
                        .onAppear {
                            if(c.id == self.viewModel.data.last?.id) {
                                self.viewModel.load()
                            }
                    }.listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                }
            }
            
        }.padding(0)
            .navigationBarTitle(Text("동아리"), displayMode: .inline)
            .onAppear{
                self.viewModel.load()
                
        }
    }
}

