//
// Created by 정태훈 on 2020/01/12.
// Copyright (c) 2020 정태훈. All rights reserved.
//

import Foundation
import SwiftUI

struct MenuContent: View {
    @EnvironmentObject var settings: UserSettings
    @EnvironmentObject var viewRouter: ViewRouter

    init() {
        UITableView.appearance().separatorColor = .clear
    }

    var body: some View {
        VStack {
            HStack {
                Text("홍길동")
                        .font(.system(size: 20))
                        .fontWeight(.semibold)
                        .foregroundColor(Color("light_navy"))
                Text("님,안녕하세요!")
                        .font(.system(size: 15))
                        .foregroundColor(Color("light_navy"))
                Spacer()
                Image("img_menu_logo")
            }
                    .padding(.leading, CGFloat(20))
                    .padding(.trailing, CGFloat(20))
                    .padding(.top, CGFloat(50))
            List {
                HStack {
                    Image(systemName: "person")
                    Text("내정보")
                            .font(.subheadline)
                }.onTapGesture {
                    self.viewRouter.currentView = "myinfo"
                    print(self.viewRouter.currentView)
                    self.viewRouter.dismiss_menu()
                }

                Section(header:
                Text("학교정보")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.gray)
                        .opacity(0.8)) {
                    Text("주변 상점")
                            .font(.subheadline)
                    Text("버스 / 교통")
                            .font(.subheadline)
                    Text("식단")
                            .onTapGesture {
                                self.viewRouter.currentView = "dining"
                                print(self.viewRouter.currentView)
                                self.viewRouter.dismiss_menu()
                            }
                            .font(.subheadline)

                    Text("동아리")
                            .font(.subheadline)
                }
                Section(header:
                Text("커뮤니티")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.gray)
                        .opacity(0.8)) {
                    Text("익명게시판")
                            .font(.subheadline)
                    Text("자유게시판")
                            .font(.subheadline)
                    Text("채용게시판")
                            .font(.subheadline)
                    Text("콜벤쉐어링")
                            .font(.subheadline)
                    Text("중고장터")
                            .font(.subheadline)
                }
                Section(header:
                Text("고객지원")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.gray)
                        .opacity(0.8)) {
                    HStack {
                        Text("카카오톡 1:1 대화")
                                .font(.subheadline)
                        Spacer()
                        Image("kakaotalk")
                                .renderingMode(.template)
                                .foregroundColor(.gray)
                                .opacity(0.5)
                    }


                    HStack {
                        Text("버전 정보")
                                .font(.subheadline)
                        Spacer()
                        Text("")
                                .font(.title)
                                .foregroundColor(.gray)
                                .opacity(0.5)
                    }
                    HStack {
                        Text("만든이")
                                .font(.subheadline)
                        Spacer()
                        Text("BCSD Lab")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .opacity(0.5)
                    }
                }
            }

        }
    }
}