//
//  BetaHomeView.swift
//  Koin
//
//  Created by 정태훈 on 2020/08/18.
//  Copyright © 2020 정태훈. All rights reserved.
//

import SwiftUI
import FirebaseRemoteConfig

struct BetaContentView: View {
    @EnvironmentObject var tabData: ViewRouter
    @EnvironmentObject var config: UserConfig
    @Environment(\.managedObjectContext) var managedObjectContext
    @State var isLoading:Bool = false
    
    @State var isHome:Bool = true
    @State var isCategory:Bool = false
    
    @State var isHomeClicked: Bool = false
    @State var isCategoryClicked: Bool = false
    @State var pushActive = false
    @State var currentView = AnyView(Text(""))
    
    //@State var isUpdate: Bool = false
    //@State var isForce: Bool = false
    
    init() {
        /*UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)*/
        UIBarButtonItem.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().barTintColor = UIColor(named: "light_navy")
        
        
    }
    
    
    
    func getView(current: String) -> some View {
        if (current != "home") {
            UINavigationBar.appearance().barTintColor = UIColor(named: "light_navy")
        } else {
            UINavigationBar.appearance().barTintColor = UIColor.white
        }
        
        if current == "dining" {
            return AnyView(MealView())
        } else if current == "myinfo" {
            return AnyView(MyInfoView()
                .navigationBarTitle("내정보", displayMode: .inline)
                .navigationBarItems(trailing: Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        if(self.tabData.isCustomItemSelected) {
                            self.tabData.dismiss_menu()
                        } else {
                            self.tabData.open_menu()
                        }
                        
                    }
                }) {
                    Image("menu")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24)
                        .foregroundColor(.white)
                }))
        } else if current == "store" {
            return AnyView(StoreView(category: self.tabData.storeCategory))
        } else if current == "timetable" {
            return AnyView(TimeTableView())
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
            return AnyView(BetaContentView())
        }
        return AnyView(Text("준비중입니다."))
    }
    
    var body: some View {
        GeometryReader { geometry in
            
            //MARK:- 사이드메뉴
            ZStack {
                SideMenu(width: geometry.size.width)
                    .edgesIgnoringSafeArea(.top)
            }.zIndex(50)

            ZStack{
                VStack{
                    HStack(alignment:.center){
                        Image("logo3X")
                            .renderingMode(.original)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 58)
                        Spacer()
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                if(self.tabData.isCustomItemSelected) {
                                    self.tabData.dismiss_menu()
                                } else {
                                    self.tabData.open_menu()
                                }
                                
                            }
                        }) {
                            Image("menu")
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20)
                                .foregroundColor(.white)
                        }
                    }
                    .frame(alignment: .bottom)
                    .padding(EdgeInsets(top: 20, leading: 20, bottom: 23, trailing: 20))
                    .background(RoundedCorners(color:Color("light_navy"),tl: 0, tr: 0, bl: 20, br: 20)
                    .frame(height: (UIDevice.current.hasNotch ? 110 : 90) + UIDevice.current.NotchTopHeight)
                        .edgesIgnoringSafeArea(.top)
                        .shadow(color: Color.black.opacity(0.34), radius: 4, x: 0, y: 2))
                    .offset(y: self.isHome ? 0: -160)
                        .animation(.easeInOut(duration: 0.3))
                    Spacer()
                }
            }.zIndex(10)
            
            //MARK:- 홈
            ZStack{
                NavigationView{
                    VStack{
                        BetaHomeView()
                            
                            .disabled(self.isLoading)
                            .blur(radius: self.isLoading ? 3 : 0)
                        //MARK: 사이드메뉴용 navigation링크
                        NavigationLink(destination: self.currentView.onAppear {
                            self.tabData.closeNavigationBar()
                        }, isActive: self.$pushActive) {
                            EmptyView()
                        }.hidden()
                            .onReceive(self.tabData.currentViewChange) { current in
                                if (current != "home") {
                                    self.currentView = self.getView(current: current) as! AnyView
                                    self.pushActive = true
                                }
                        }
                    }.navigationBarTitle("",displayMode: .inline)
                }
            }.zIndex(5)
                
            
            
            //MARK:- 로딩화면
            ZStack(alignment: .center) {
                LottieView(filename: "data")
                    .edgesIgnoringSafeArea(.all)
                    .opacity(self.isLoading ? 1 : 0)
            }.zIndex(150)
            
            
        }.onReceive(self.tabData.loadingChange) { loading in
            self.isLoading = loading
        }.onReceive(self.tabData.customItemSelectedChange) { category in
            self.isCategory = category
        }.onReceive(self.tabData.isNavigationBarChange) { isNavigationBar in
            self.isHome = isNavigationBar
        }
        
    }
}

struct BetaContentView_Previews: PreviewProvider {
    static var previews: some View {
        BetaContentView()
    }
}
