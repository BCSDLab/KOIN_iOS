//
//  BetaHomeView.swift
//  Koin
//
//  Created by 정태훈 on 2020/06/23.
//  Copyright © 2020 정태훈. All rights reserved.
//

import SwiftUI
import PKHUD

struct HomeView: View {
    @EnvironmentObject var tabData: ViewRouter
    @EnvironmentObject var config: UserConfig
    
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @State var pushActive = false
    
    @State var currentView = AnyView(Text(""))
    
    let coloredNavAppearance = UINavigationBarAppearance()

    init() {
        UIBarButtonItem.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().barTintColor = UIColor(named: "light_navy")
        
    }
    
    var icons: Array<String> = ["circles", "bus", "timetable","store", "restaurant", "market", "board_free", "board_recruit","board_secret"]
    
    var titles: Array<String> = ["동아리", "버스/교통", "시간표","주변상점", "식단", "중고장터", "자유게시판", "취업게시판","익명게시판"]
    
    func getView(current: String) -> some View {
        if (current != "home") {
            coloredNavAppearance.backgroundColor = UIColor(named: "light_navy")
        }
        if current == "dining" {
            return AnyView(MealView())
        } else if current == "myinfo" {
            return AnyView(MyInfoView()
                .navigationBarTitle("내정보", displayMode: .inline))
        } else if current == "store" {
            return AnyView(StoreView())
        } else if current == "board_free" {
            return AnyView(
                CommunityView<Article,Comment>(boardId: 1).environmentObject(self.config))
        } else if current == "board_recruit" {
            return AnyView(
                CommunityView<Article,Comment>(boardId: 2).environmentObject(self.config))
        } else if current == "board_secret" {
            return AnyView(CommunityView<TempArticle,TempComment>(boardId: -2).environmentObject(self.config))
        }  else if current == "bus" {
            return AnyView(BusView())
        } else if current == "circle" {
            return AnyView(CircleView())
        } else if current == "search" {
            return AnyView(SearchView().environmentObject(self.tabData).environment(\.managedObjectContext, self.managedObjectContext))
        } else if current == "home" {
            return AnyView(ContentView())
        }
        return AnyView(Text("준비중입니다."))
    }
    
    func setLink(index: Int) -> String {
        switch(index) {
            case 0:
                return "circle"
            case 1:
                return "bus"
            case 3:
                return "store"
            case 4:
                return "dining"
            case 6:
                return "board_free"
            case 7:
                return "board_recruit"
            case 8:
                return "board_secret"
            default:
                return ""
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            //MARK:- 버튼
            VStack(alignment: .center){
                Spacer()
                VStack(alignment: .center){
                    GridView(rows: 3, columns: 3) { index in
                        Button(action: {
                            if ([0,1,3,4,6,7,8].contains(index)) {
                                self.tabData.currentView = self.setLink(index: index)
                            } else {
                                prepare_project()
                            }
                        }) {
                            VStack{
                                Image(self.icons[index])
                                    .renderingMode(.original)
                                    .resizable()
                                    .frame(width: 24, height: 24, alignment: .center)
                                    .padding(.bottom, 13)
                                Text(self.titles[index])
                                    .font(.system(size: 15))
                                    .fontWeight(.medium)
                                    .foregroundColor(Color(red: 112/255, green: 112/255, blue: 112/255))
                            }.frame(width: (geometry.size.width - 54)/3, height: (geometry.size.width - 54)/3, alignment: .center)
                                .background(Color.white)
                        }
                    }
                }.frame(width: geometry.size.width - 52, height: geometry.size.width - 52, alignment: .center)
                    .background(Color(hex: 0xf2f2f2))
                    .padding(.bottom, 26)
                //.padding(.bottom, UIDevice.current.NotchBottomHeight)
                
                //MARK: 사이드메뉴용 navigation링크
                NavigationLink(destination: self.currentView, isActive: self.$pushActive) {
                    EmptyView()
                }.hidden()
                    .onReceive(self.tabData.currentViewChange) { current in
                        if (current != "home") {
                            self.coloredNavAppearance.backgroundColor = UIColor(named: "light_navy")
                            self.currentView = self.getView(current: current) as! AnyView
                            self.pushActive = true
                        }
                }
                    
                .navigationBarHidden(true)
            }.background(
                // MARK:- 배경
                VStack{
                    VStack{
                        VStack(alignment: .leading, spacing: 0){
                            Image("logo_footer")
                                .renderingMode(.original)
                                .resizable()
                                .frame(width: 70, height: 40)
                                .padding(.bottom, 30)
                                .padding(.top,0 + UIDevice.current.NotchTopHeight)
                                .padding(.leading, 25)
                            Text("\'코인\' ios앱 출시")
                                .fontWeight(.medium)
                                .foregroundColor(Color.white.opacity(0.6))
                                .font(.system(size: 15))
                                .padding(.bottom, 10)
                                .padding(.leading, 25)
                            Text("코리아텍 학생들이\n함께 만들어가는 커뮤니티")
                                .font(.system(size: 24))
                                .fontWeight(.medium)
                                .lineSpacing(5)
                                .foregroundColor(.white)
                                .frame(height: 72, alignment: .leading)
                                .padding(.leading, 25)
                        }.frame(width: geometry.size.width, height: 300 + UIDevice.current.NotchTopHeight, alignment: .leading)
                            .background(Image("img_bg").resizable().frame(width: geometry.size.width, height: 300))
                    }.frame(width: geometry.size.width, height: 376 + UIDevice.current.NotchTopHeight, alignment: .top)
                        .background(Color("squash"))
                        .navigationBarHidden(true)
                    Spacer()
                }.frame(width: geometry.size.width, height: geometry.size.height, alignment: .top)
                    .edgesIgnoringSafeArea(.top).background(Color(red: 247/255, green: 247/255, blue: 247/255))).padding(.horizontal, 50)
        }
    }
}

struct BetaHomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
