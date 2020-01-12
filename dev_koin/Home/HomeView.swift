//
// Created by 정태훈 on 2020/01/12.
// Copyright (c) 2020 정태훈. All rights reserved.
//

import Foundation
import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewRouter: ViewRouter
    init() {
        UINavigationBar.appearance().barTintColor = UIColor(named: "light_navy")
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
    }

    func getItemWidth(containerWidth: CGFloat) -> CGFloat {
        return (containerWidth - 50) / 3
    }

    func getItemHeight(containerHeight: CGFloat) -> CGFloat {
        return (containerHeight) / 3
    }

    var body: some View {
        NavigationView{
            GeometryReader { geometry in
                ZStack {
                    VStack {
                        Image("img_bg")
                                .resizable()
                                .frame(width: geometry.size.width, height: 400)
                                .background(Color("squash"))
                        Spacer()
                    }
                            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .top)
                            .edgesIgnoringSafeArea(.top)

                    VStack(alignment: .leading) {
                        VStack(alignment: .leading) {
                            Image("logo_footer")
                                    .renderingMode(.original)
                                    .resizable()
                                    .frame(width: 65, height: 37)
                            Text("\'코인\' ios앱 출시")
                                    .fontWeight(.light)
                                    .foregroundColor(Color.white.opacity(0.5))
                                    .font(.system(size: 15))
                            Text("코리아텍 학생들이\n함께 만들어가는 커뮤니티")
                                    .font(.system(size: 25))
                                    .fontWeight(.medium)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                        }
                                .frame(width: geometry.size.height, height: 400, alignment: .top)
                                .padding(.leading, 30)
                        Spacer()
                    }
                            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .leading)
                    VStack() {
                        Spacer()
                        VStack(alignment: .center, spacing: 0) {
                            HStack(alignment: .center, spacing: 0) {
                                Button(action: {}) {
                                    VStack{
                                        Spacer()
                                        Image("circles")
                                                .renderingMode(.original)
                                                .resizable()
                                                .frame(width: 30, height: 30)
                                        Spacer()
                                        Text("동아리")
                                                .fontWeight(.semibold)
                                                .foregroundColor(.black)
                                                .opacity(0.6)
                                                .padding(.bottom, 20)
                                    }
                                            .frame(width: self.getItemWidth(containerWidth: geometry.size.width), height: self.getItemWidth(containerWidth: geometry.size.width))
                                            .background(Color.white)
                                }
                                        .clipped()
                                        .border(Color.gray.opacity(0.2), width: 0.5)
                                Button(action: {}) {
                                    VStack{
                                        Spacer()
                                        Image("bus")
                                                .renderingMode(.original)
                                                .resizable()
                                                .frame(width: 30, height: 30)
                                        Spacer()
                                        Text("버스/교통")
                                                .fontWeight(.semibold)
                                                .foregroundColor(.black)
                                                .opacity(0.6)
                                                .padding(.bottom, 20)
                                    }
                                            .frame(width: self.getItemWidth(containerWidth: geometry.size.width), height: self.getItemWidth(containerWidth: geometry.size.width))
                                            .background(Color.white)
                                }
                                        .border(Color.gray.opacity(0.2), width: 0.5)
                                Button(action: {}) {
                                    VStack{
                                        Spacer()
                                        Image("timetable")
                                                .renderingMode(.original)
                                                .resizable()
                                                .frame(width: 30, height: 30)
                                        Spacer()
                                        Text("시간표")
                                                .fontWeight(.semibold)
                                                .foregroundColor(.black)
                                                .opacity(0.6)
                                                .padding(.bottom, 20)
                                    }
                                            .frame(width: self.getItemWidth(containerWidth: geometry.size.width), height: self.getItemWidth(containerWidth: geometry.size.width))
                                            .background(Color.white)
                                }
                                        .border(Color.gray.opacity(0.2), width: 0.5)
                            }
                            HStack(alignment: .center, spacing: 0) {
                                Button(action: {}) {
                                    VStack{
                                        Spacer()
                                        Image("store")
                                                .renderingMode(.original)
                                                .resizable()
                                                .frame(width: 30, height: 30)
                                        Spacer()
                                        Text("주변상점")
                                                .fontWeight(.semibold)
                                                .foregroundColor(.black)
                                                .opacity(0.6)
                                                .padding(.bottom, 20)
                                    }
                                            .frame(width: self.getItemWidth(containerWidth: geometry.size.width), height: self.getItemWidth(containerWidth: geometry.size.width))
                                            .background(Color.white)
                                }
                                        .clipped()
                                        .border(Color.gray.opacity(0.2), width: 0.5)

                                Button(action: {self.viewRouter.currentView = "dining"
                                    self.viewRouter.dismiss_menu()}) {
                                    VStack{
                                        Spacer()
                                        Image("restaurant")
                                                .renderingMode(.original)
                                                .resizable()
                                                .frame(width: 30, height: 30)
                                        Spacer()
                                        Text("식단")
                                                .fontWeight(.semibold)
                                                .foregroundColor(.black)
                                                .opacity(0.6)
                                                .padding(.bottom, 20)
                                    }
                                            .frame(width: self.getItemWidth(containerWidth: geometry.size.width), height: self.getItemWidth(containerWidth: geometry.size.width))
                                            .background(Color.white)
                                }

                                        .border(Color.gray.opacity(0.2), width: 0.5)
                                Button(action: {}) {
                                    VStack{
                                        Spacer()
                                        Image("market")
                                                .renderingMode(.original)
                                                .resizable()
                                                .frame(width: 30, height: 30)
                                        Spacer()
                                        Text("중고장터")
                                                .fontWeight(.semibold)
                                                .foregroundColor(.black)
                                                .opacity(0.6)
                                                .padding(.bottom, 20)
                                    }
                                            .frame(width: self.getItemWidth(containerWidth: geometry.size.width), height: self.getItemWidth(containerWidth: geometry.size.width))
                                            .background(Color.white)
                                }
                                        .border(Color.gray.opacity(0.2), width: 0.5)
                            }
                            HStack(alignment: .center, spacing: 0) {
                                Button(action: {}) {
                                    VStack{
                                        Spacer()
                                        Image("board_free")
                                                .renderingMode(.original)
                                                .resizable()
                                                .frame(width: 30, height: 30)
                                        Spacer()
                                        Text("자유게시판")
                                                .fontWeight(.semibold)
                                                .foregroundColor(.black)
                                                .opacity(0.6)
                                                .padding(.bottom, 20)
                                    }
                                            .frame(width: self.getItemWidth(containerWidth: geometry.size.width), height: self.getItemWidth(containerWidth: geometry.size.width))
                                            .background(Color.white)
                                }
                                        .border(Color.gray.opacity(0.2), width: 0.5)
                                Button(action: {}) {
                                    VStack{
                                        Spacer()
                                        Image("board_recruit")
                                                .renderingMode(.original)
                                                .resizable()
                                                .frame(width: 30, height: 30)
                                        Spacer()
                                        Text("취업게시판")
                                                .fontWeight(.semibold)
                                                .foregroundColor(.black)
                                                .opacity(0.6)
                                                .padding(.bottom, 20)
                                    }
                                            .frame(width: self.getItemWidth(containerWidth: geometry.size.width), height: self.getItemWidth(containerWidth: geometry.size.width))
                                            .background(Color.white)
                                }
                                        .border(Color.gray.opacity(0.2), width: 0.5)
                                Button(action: {}) {
                                    VStack{
                                        Spacer()
                                        Image("board_secret")
                                                .renderingMode(.original)
                                                .resizable()
                                                .frame(width: 30, height: 30)
                                        Spacer()
                                        Text("익명게시판")
                                                .fontWeight(.semibold)
                                                .foregroundColor(.black)
                                                .opacity(0.6)
                                                .padding(.bottom, 20)
                                    }
                                            .frame(width: self.getItemWidth(containerWidth: geometry.size.width), height: self.getItemWidth(containerWidth: geometry.size.width))
                                            .background(Color.white)
                                }
                                        .border(Color.gray.opacity(0.2), width: 0.5)
                            }
                        }
                                .background(Color.white)
                                .frame(maxWidth: .infinity)
                    }
                            .clipped()
                            .shadow(color: Color.black.opacity(0.3), radius: 3, x: 5, y: 5)
                            .padding(.bottom, 50)
                }

            }
        }

    }
}