//
//  ContentView.swift
//  dev_koin
//
//  Created by 정태훈 on 2019/12/08.
//  Copyright © 2019 정태훈. All rights reserved.
//

import SwiftUI
import PKHUD

struct ContentView: View {
    @EnvironmentObject var tabData: ViewRouter
    @EnvironmentObject var settings: UserSettings
    @State private var show_modal: Bool = false

    init() {
        UINavigationBar.appearance().barTintColor = UIColor(named: "light_navy")
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
    }


    var body: some View {
        GeometryReader { geometry in
            ZStack {
                SideMenu(width: geometry.size.width/3*2)

            }.zIndex(99)
            TabView (selection: self.$tabData.itemSelected){

                NavigationView {
                    if self.tabData.currentView == "home" {
                        HomeView()
                                .navigationBarTitle("")
                                .navigationBarHidden(true)
                    } else if self.tabData.currentView == "dining" {
                        MealView()
                                .navigationBarTitle("식단", displayMode: .inline)
                                .navigationBarItems(leading: Button(action: self.tabData.go_home) {
                                    HStack {
                                        Image(systemName: "chevron.left")
                                        Text("홈")
                                    }
                                }, trailing: EmptyView())
                    } else if self.tabData.currentView == "myinfo" {
                        MyInfoView()
                                .navigationBarTitle("내정보", displayMode: .inline)
                                .navigationBarItems(leading: Button(action: self.tabData.go_home) {
                                    HStack {
                                        Image(systemName: "chevron.left")
                                        Text("홈")
                                    }
                                }, trailing: NavigationLink(destination: EditUserView().environmentObject(self.settings)) {
                                    Text("수정")
                                })

                    } else if self.tabData.currentView == "store" {
                        StoreView()
                                .navigationBarTitle("주변식당", displayMode: .inline)
                                .navigationBarItems(leading: Button(action: self.tabData.go_home) {
                                    HStack {
                                        Image(systemName: "chevron.left")
                                        Text("홈")
                                    }
                                }, trailing: EmptyView())
                    }
                }

                        .tabItem {
                            VStack {
                                Image("bottom_home")
                                        .resizable()
                                        .renderingMode(.template)
                                        .frame(width:38, height: 24)
                                Text("홈")
                                        .font(.system(size: 12))
                                        .fontWeight(.medium)
                                Spacer()
                            }
                        }.tag(1)

                Text("Custom Action")
                        .tabItem {
                            VStack {
                                Image("bottom_category")
                                        .resizable()
                                        .renderingMode(.template)
                                        .frame(width:38, height: 24)
                                Text("카테고리")
                                        .font(.system(size: 12))
                                        .fontWeight(.medium)
                            }
                        }
                        .tag(2)

                NavigationView{
                    MyInfoView()
                            .navigationBarTitle("내정보", displayMode: .inline)
                            .navigationBarItems(leading: Button(action: self.tabData.go_home) {
                                HStack {
                                    Image(systemName: "chevron.left")
                                    Text("홈")
                                }
                            }, trailing: NavigationLink(destination: EditUserView().environmentObject(self.settings).navigationBarTitle("내정보 수정", displayMode: .inline)) {
                                Text("수정")
                            })
                }
                        .tabItem {
                            VStack {
                                Image("bottom_myinfo")
                                        .resizable()
                                        .renderingMode(.template)
                                        .frame(width:38, height: 24)
                                Text("내정보")
                                        .font(.system(size: 12))
                                        .fontWeight(.medium)
                            }
                        }.tag(3)

            }
                    .font(.headline)
                    .edgesIgnoringSafeArea(.top)
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


