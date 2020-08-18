//
// Created by 정태훈 on 2020/01/12.
// Copyright (c) 2020 정태훈. All rights reserved.
//

import Foundation
import SwiftUI
import PKHUD

struct MenuContent: View {
    // 유저 정보가 들어있는 오브젝트
    //@EnvironmentObject var settings: UserSettings
    @EnvironmentObject var config: UserConfig
    // 탭 정보가 들어있는 오브젝트
    @EnvironmentObject var viewRouter: ViewRouter
    
    init() {
        // 리스트의 구분선을 투명하게 변경
        UITableView.appearance().separatorColor = .clear
    }
    
    var body: some View {
        VStack {
            VStack(alignment: .leading){
                HStack{
                    Button(action: {
                        self.viewRouter.dismiss_menu()
                    }) {
                        Image(systemName: "chevron.left")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 24)
                            .foregroundColor(Color("black"))
                    }.padding(.bottom, 16)
                    Spacer()
                    Image("img_menu_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 40)
                }
                HStack(spacing: 4){
                    Text(self.config.nickname)
                        .font(.system(size: 15))
                        .fontWeight(.medium)
                        .foregroundColor(Color("light_navy"))
                    Text("님,안녕하세요!")
                        .font(.system(size: 13))
                        .foregroundColor(Color("light_navy"))
                }
            }
                .padding(EdgeInsets(top: 8 + UIDevice.current.NotchTopHeight, leading: 16, bottom: 8, trailing: 16))
            
            Button(action: {
                // 현재 view를 myinfo로 변경
                self.viewRouter.currentView = "myinfo"
                // 메뉴 닫음
                self.viewRouter.dismiss_menu()
            }) {
                HStack(spacing: 0){
                    Image("bottom_myinfo")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(self.viewRouter.currentView == "myinfo" ? Color("squash"): Color("black"))
                        .frame(height:24)
                    Text("내정보")
                        .font(.system(size: 15))
                        .foregroundColor(self.viewRouter.currentView == "myinfo" ? Color("squash"): Color("black"))
                }.frame(maxWidth: .infinity,alignment: .leading)
                    .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 0))
            }
            VStack{
                Text("학교정보")
                    .font(.system(size: 15))
                    .foregroundColor(Color(red: 133/255, green: 133/255, blue: 133/255))
                    .frame(maxWidth: .infinity,alignment: .leading)
                    .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 0))
            }.background(Color(red: 246/255, green: 248/255, blue: 249/255))
            HStack{
                Button(action: {
                    self.viewRouter.currentView = "store"
                    self.viewRouter.dismiss_menu()
                }) {
                    Text("주변 상점")
                        .font(.system(size: 15))
                        .foregroundColor(self.viewRouter.currentView == "store" ? Color("squash"): Color("black"))
                        .frame(maxWidth: .infinity,alignment: .leading)
                }
                Button(action: {
                    self.viewRouter.currentView = "dining"
                    self.viewRouter.dismiss_menu()
                }) {
                    Text("식단")
                        .font(.system(size: 15))
                        .foregroundColor(self.viewRouter.currentView == "dining" ? Color("squash"): Color("black"))
                        .frame(maxWidth: .infinity,alignment: .leading)
                }
            }.padding(EdgeInsets(top: 16, leading: 16, bottom: 8, trailing: 0))
            HStack{
                Button(action: {
                    self.viewRouter.currentView = "bus"
                    self.viewRouter.dismiss_menu()
                }) {
                    Text("버스 / 교통")
                        .font(.system(size: 15))
                        .foregroundColor(self.viewRouter.currentView == "bus" ? Color("squash"): Color("black"))
                        .frame(maxWidth: .infinity,alignment: .leading)
                }
                
                
                Button(action: {
                    self.viewRouter.currentView = "circle"
                    self.viewRouter.dismiss_menu()
                }) {
                    Text("동아리")
                        .font(.system(size: 15))
                        .foregroundColor(Color("black"))
                        .frame(maxWidth: .infinity,alignment: .leading)
                }
            }.padding(EdgeInsets(top: 8, leading: 16, bottom: 16, trailing: 0))
            VStack{
                Text("커뮤니티")
                    .font(.system(size: 15))
                    .foregroundColor(Color(red: 133/255, green: 133/255, blue: 133/255))
                    .frame(maxWidth: .infinity,alignment: .leading)
                    .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 0))
            }.background(Color(red: 246/255, green: 248/255, blue: 249/255))
            HStack{
                Button(action: {
                    self.viewRouter.currentView = "board_secret"
                    self.viewRouter.dismiss_menu()
                }) {
                    Text("익명게시판")
                        .font(.system(size: 15))
                        .foregroundColor(self.viewRouter.currentView == "board_secret" ? Color("squash"): Color("black"))
                    .frame(maxWidth: .infinity,alignment: .leading)
                }
                Button(action: {
                    self.viewRouter.currentView = "board_recruit"
                    self.viewRouter.dismiss_menu()
                }) {
                    Text("채용게시판")
                        .font(.system(size: 15))
                        .foregroundColor(self.viewRouter.currentView == "board_recruit" ? Color("squash"): Color("black"))
                    .frame(maxWidth: .infinity,alignment: .leading)
                }
            }.padding(EdgeInsets(top: 16, leading: 16, bottom: 8, trailing: 0))
            
            
            
            HStack{
                Button(action: {
                    self.viewRouter.currentView = "board_free"
                    self.viewRouter.dismiss_menu()
                }) {
                    Text("자유게시판")
                        .font(.system(size: 15))
                        .foregroundColor(self.viewRouter.currentView == "board_free" ? Color("squash"): Color("black"))
                    .frame(maxWidth: .infinity,alignment: .leading)
                }
                Button(action: {
                    prepare_project()
                    self.viewRouter.dismiss_menu()
                }) {
                    Text("분실물")
                        .font(.system(size: 15))
                        .foregroundColor(Color("black"))
                    .frame(maxWidth: .infinity,alignment: .leading)
                }
            }.padding(EdgeInsets(top: 8, leading: 16, bottom: 16, trailing: 0))
            /*
             Button(action: {
             prepare_project()
             self.viewRouter.dismiss_menu()
             }) {
             Text("중고장터")
             .font(.system(size: 15))
             .foregroundColor(Color("black"))
             }
             */
            VStack{
                Text("고객지원")
                    .font(.system(size: 15))
                    .foregroundColor(Color(red: 133/255, green: 133/255, blue: 133/255))
                    .frame(maxWidth: .infinity,alignment: .leading)
                    .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 0))
            }.background(Color(red: 246/255, green: 248/255, blue: 249/255))
            
            VStack{
                Button(action: {
                    let url: NSURL = URL(string: "http://pf.kakao.com/_twMBd")! as NSURL
                    UIApplication.shared.open(url as URL)
                }) {
                    HStack{
                        Text("카카오톡 1:1 대화")
                            .font(.system(size: 15))
                            .foregroundColor(Color("black"))
                        Spacer()
                    }
                }.padding(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
                Spacer()
                Button(action: {
                    let url: NSURL = URL(string: "https://bcsdlab.com")! as NSURL
                    UIApplication.shared.open(url as URL)
                }) {
                    HStack {
                        Spacer()
                        Image("logo_white")
                            .renderingMode(.original)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 16)
                            .opacity(0.5)
                    }.padding(.trailing, 16)
                }.padding(.bottom, UIDevice.current.NotchBottomHeight + 75)
            }
            
        }.frame(maxWidth: .infinity,maxHeight: .infinity,alignment: .topLeading)
            .onReceive(self.viewRouter.currentViewChange) { current in

        }
    }
}
