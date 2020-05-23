//
//  CircleDetailView.swift
//  Koin
//
//  Created by 정태훈 on 2020/05/09.
//  Copyright © 2020 정태훈. All rights reserved.
//

import SwiftUI
import SDWebImageSwiftUI

struct CircleDetailView: View {
    let viewModel: CircleDetailViewModel
    
    init(viewModel: CircleDetailViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ScrollView {
            VStack{
                VStack{
                    HStack{
                        if(self.viewModel.logoUrl != "") {
                            VStack(alignment: .leading) {
                                WebImage(url: URL(string: self.viewModel.logoUrl))
                                    .placeholder {
                                        Circle().foregroundColor(.gray)
                                            .frame(minWidth: 50, maxWidth: 50, minHeight: 50, maxHeight: 50, alignment: .center)
                                }
                                .resizable()
                                .indicator(.activity)
                                .frame(minWidth: 50, maxWidth: 50, minHeight: 50, maxHeight: 50, alignment: .center)
                                .clipShape(Circle())
                            }
                            .background(Color.white)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color("store_menu_border"), lineWidth: 1))
                            .padding(EdgeInsets(top: 16, leading: 16, bottom: 10, trailing: 10))
                        } else {
                            Circle().foregroundColor(.gray)
                                .frame(minWidth: 50, maxWidth: 50, minHeight: 50, maxHeight: 50, alignment: .center)
                            .overlay(Circle().stroke(Color("store_menu_border"), lineWidth: 1))
                            .padding(EdgeInsets(top: 16, leading: 16, bottom: 10, trailing: 10))
                        }
                        VStack(alignment: .leading) {
                            Text(self.viewModel.name)
                                .font(.system(size: 20))
                                .fontWeight(.medium)
                                .foregroundColor(Color("content_black_color"))
                                .padding(.bottom, 4)
                            Text(self.viewModel.lineDescription)
                                .font(.system(size: 13))
                                .foregroundColor(Color("warm_grey"))
                        }.padding(EdgeInsets(top: 16, leading: 0, bottom: 10, trailing: 0))
                        Spacer()
                    }
                }
                Divider()
                if(self.viewModel.backgroundUrl != "") {
                    VStack(alignment: .leading) {
                        WebImage(url: URL(string: self.viewModel.backgroundUrl))
                            .placeholder {
                                Rectangle().foregroundColor(.gray)
                                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 180, maxHeight: 180, alignment: .center)
                        }
                        .resizable()
                        .indicator(.activity)
                        .scaledToFit()
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                    }.padding()
                } else {
                    Rectangle().foregroundColor(.white)
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 180, maxHeight: 180, alignment: .center)
                    .padding()
                }
                
                
                
                
                VStack(alignment: .leading) {
                    HStack{
                        Text("동아리방")
                            .font(.system(size: 15))
                            .foregroundColor(Color("warm_grey"))
                            .padding(.trailing, 10)
                        Text(self.viewModel.location)
                            .foregroundColor(Color("black"))
                            .font(.system(size: 15))
                        Spacer()
                    }.frame(minWidth: 0, maxWidth: .infinity)
                        .padding(.leading, 16)
                        .padding(.bottom, 10)
                    HStack {
                        Text("주요사업")
                            .padding(.trailing, 10)
                            .font(.system(size: 15))
                            .foregroundColor(Color("warm_grey"))
                        Text(self.viewModel.majorBusiness)
                            .foregroundColor(Color("black"))
                            .font(.system(size: 15))
                        Spacer()
                    }.frame(minWidth: 0, maxWidth: .infinity)
                        .padding(.leading, 16)
                        .padding(.bottom, 10)
                    HStack {
                        Text("지도교수")
                            .padding(.trailing, 10)
                            .font(.system(size: 15))
                            .foregroundColor(Color("warm_grey"))
                        Text(self.viewModel.professor)
                            .foregroundColor(Color("black"))
                            .font(.system(size: 15))
                        Spacer()
                    }.frame(minWidth: 0, maxWidth: .infinity)
                        .padding(.leading, 16)
                        .padding(.bottom, 10)
                    HStack {
                        Text("홈페이지")
                            .padding(.trailing, 10)
                            .font(.system(size: 15))
                            .foregroundColor(Color("warm_grey"))
                        Button(action: {
                            UIApplication.shared.open(URL(string: self.viewModel.introduceUrl.contains("http") ? self.viewModel.introduceUrl : "http://\(self.viewModel.introduceUrl)")!)
                        }) {
                            Text(self.viewModel.introduceUrl)
                                .foregroundColor(Color("black"))
                                .font(.system(size: 15))
                        }
                        Spacer()
                    }.frame(minWidth: 0, maxWidth: .infinity)
                        .padding(.leading, 16)
                }.padding(.vertical, 16)
                    .background(Color("store_menu_border"))
                Text(self.viewModel.introduce)
                    .font(.system(size: 13))
                    .lineSpacing(4)
                    .foregroundColor(Color("content_black_color"))
                    .padding(.vertical, 24)
                    .padding(.horizontal, 16)
                
                
                HStack(alignment: .center, spacing: 20) {
                    if(self.viewModel.facebookUrl != "") {
                        Button(action: {
                            UIApplication.shared.open(URL(string: self.viewModel.facebookUrl.contains("http") ? self.viewModel.facebookUrl : "http://\(self.viewModel.facebookUrl)")!)
                        }) {
                            Image("facebook")
                            .resizable()
                                .frame(width: 40, height: 40, alignment: .center)
                        }
                    }
                    if(self.viewModel.naverUrl != "") {
                        Button(action: {
                            UIApplication.shared.open(URL(string: self.viewModel.naverUrl.contains("http") ? self.viewModel.naverUrl : "http://\(self.viewModel.naverUrl)")!)
                        }) {
                            Image("naver")
                                .resizable()
                                .frame(width: 40, height: 40, alignment: .center)
                        }
                    }
                    if(self.viewModel.cyworldUrl != "") {
                        Button(action: {
                            UIApplication.shared.open(URL(string: self.viewModel.cyworldUrl.contains("http") ? self.viewModel.cyworldUrl : "http://\(self.viewModel.cyworldUrl)")!)
                        }) {
                            Image("cyworld")
                                .resizable()
                                .frame(width: 40, height: 40, alignment: .center)
                        }
                    }
                }.padding(.bottom, 20)
                
            }
        }
    }
}

struct CircleDetailView_Previews: PreviewProvider {
    static var previews: some View {
        CircleDetailView(viewModel: CircleDetailViewModel(id: 12))
    }
}
