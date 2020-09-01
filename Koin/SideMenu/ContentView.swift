//
//  BetaContentView.swift
//  Koin
//
//  Created by 정태훈 on 2020/06/27.
//  Copyright © 2020 정태훈. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var tabData: ViewRouter
    @EnvironmentObject var config: UserConfig
    @Environment(\.managedObjectContext) var managedObjectContext
    @State var isLoading:Bool = false
    
    @State var isHome:Bool = true
    @State var isCategory:Bool = false
    @State var isSearch:Bool = false
    
    @State var isHomeClicked: Bool = false
    @State var isCategoryClicked: Bool = false
    @State var isSearchClicked: Bool = false
    
    
    
    var body: some View {
        GeometryReader { geometry in
            
            //MARK:- 사이드메뉴
            ZStack {
                SideMenu(width: geometry.size.width)
                    .edgesIgnoringSafeArea(.top)
            }.zIndex(50)
            
            //MARK:- 홈
            NavigationView{
                HomeView()
                    .navigationBarHidden(true)
                    .disabled(self.isLoading)
                    .blur(radius: self.isLoading ? 3 : 0)
            }.padding(.bottom, 70 + UIDevice.current.NotchBottomHeight)
            .edgesIgnoringSafeArea(.bottom)
            
            
            //MARK:- 로딩화면
            ZStack(alignment: .center) {
                LottieView(filename: "data")
                    .edgesIgnoringSafeArea(.all)
                    .opacity(self.isLoading ? 1 : 0)
            }.zIndex(150)
            
            
            // MARK:- 탭바
            ZStack(alignment: .bottom){
                VStack {
                    Spacer()
                    VStack(spacing: 0){
                        Divider()
                        HStack{
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    self.isHomeClicked.toggle()
                                    NotificationCenter.default.post(name: Notification.Name("popToRoot"), object: nil)
                                    self.tabData.currentView = "home"
                                }
                                self.isHomeClicked.toggle()
                            }) {
                                VStack {
                                    Image("home")
                                        .renderingMode(.template)
                                        .scaledToFit()
                                        .font(.system(size: 18))
                                        .padding(.bottom, 4)
                                        .padding(.top, 16)
                                        .foregroundColor(self.isHome ? Color(hex: 0x175c8e) : Color(hex: 0x252525))
                                    
                                    Text("홈")
                                        .font(.system(size: 12))
                                        .fontWeight(.regular)
                                        .foregroundColor(self.isHome ? Color(hex: 0x175c8e) : Color(hex: 0x252525))
                                }.frame(maxWidth: .infinity,minHeight: 60)
                                
                            }.scaleEffect(self.isHomeClicked ? 1.15 : 1)
                            
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    self.isCategoryClicked.toggle()
                                    if(self.tabData.isCustomItemSelected) {
                                        self.tabData.dismiss_menu()
                                    } else {
                                        self.tabData.open_menu()
                                    }
                                    
                                }
                                self.isCategoryClicked.toggle()
                            }) {
                                VStack {
                                    Image("menu")
                                        .renderingMode(.template)
                                        .scaledToFit()
                                        .font(.system(size: 18))
                                        .padding(.bottom, 4)
                                        .padding(.top, 16)
                                        .foregroundColor(self.isCategory ? Color(hex: 0x175c8e) : Color(hex: 0x252525))
                                    Text("카테고리")
                                        .font(.system(size: 12))
                                        .fontWeight(.regular)
                                        .foregroundColor(self.isCategory ? Color(hex: 0x175c8e) : Color(hex: 0x252525))
                                }.frame(maxWidth: .infinity,minHeight: 60)
                            }.scaleEffect(self.isCategoryClicked ? 1.15 : 1)
                            
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    self.isSearchClicked.toggle()
                                    self.tabData.currentView = "search"
                                }
                                self.isSearchClicked.toggle()
                            }) {
                                VStack{
                                    Image(systemName: "magnifyingglass")
                                        .renderingMode(.template)
                                        .scaledToFit()
                                        .font(.system(size: 18))
                                        .padding(.bottom, 4)
                                        .padding(.top, 16)
                                        .foregroundColor(self.isSearch ? Color(hex: 0x175c8e) : Color(hex: 0x252525))
                                    Text("검색")
                                        .font(.system(size: 12))
                                        .fontWeight(.regular)
                                        .foregroundColor(self.isSearch ? Color(hex: 0x175c8e) : Color(hex: 0x252525))
                                }.frame(maxWidth: .infinity,minHeight: 60)
                            }.scaleEffect(self.isSearchClicked ? 1.15 : 1)
                            
                        }.frame(alignment: .center)
                        .padding(.bottom, 16)
                        .background(Color(red: 253/255, green: 254/255, blue: 255/255).edgesIgnoringSafeArea(.bottom))
                        .edgesIgnoringSafeArea(.bottom)
                    }
                    
                }.frame(width: geometry.size.width, height: geometry.size.height, alignment: .bottom)
                    .onReceive(self.tabData.currentViewChange) { current in
                        if(current != "home") {
                            self.isHome = false
                        } else {
                            self.isHome = true
                        }
                        if(current == "search") {
                            self.isSearch = true
                        } else {
                            self.isSearch = false
                        }
                }
            }.frame(alignment: .bottom).zIndex(99)
            
        }.onReceive(self.tabData.loadingChange) { loading in
            self.isLoading = loading
        }.onReceive(self.tabData.customItemSelectedChange) { category in
            self.isCategory = category
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
