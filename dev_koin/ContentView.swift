//
//  ContentView.swift
//  dev_koin
//
//  Created by 정태훈 on 2019/12/08.
//  Copyright © 2019 정태훈. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State var signInSuccess = false
    @EnvironmentObject var userData: UserDownloader
    
    
    
    var body: some View {

        Group {
            if (userData.isUser()) {
            MainView()
          } else {
            UserLoginView()
          }
        }

    }
}

struct MenuView: View {
    var body: some View {
        
        EmptyView()
    }
}

struct HomeView: View {
    var body: some View {
        return NavigationView {
            
            VStack {
                HStack {
                    Spacer()
                    NavigationLink(destination: MealView()) {
                            Text("test")
                    }.frame(minWidth: 0, maxWidth: 100, minHeight: 0, maxHeight: 100, alignment: .center).padding().background(Color.white)
                    Spacer()
                    NavigationLink(destination: MealView()) {
                        Text("meal")
                    }.frame(minWidth: 0, maxWidth: 100, minHeight: 0, maxHeight: 100, alignment: .center).padding()
                    Spacer()
                    NavigationLink(destination: MealView()) {
                        Text("meal")
                    }.frame(minWidth: 0, maxWidth: 100, minHeight: 0, maxHeight: 100, alignment: .center).padding()
                    Spacer()
                }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 100, alignment: .topLeading).padding([.leading,.trailing], 10)
                
                HStack {
                Spacer()
                NavigationLink(destination: MealView()) {
                    Text("meal")
                }.frame(minWidth: 0, maxWidth: 100, minHeight: 0, maxHeight: 100, alignment: .center).padding().background(Color.white)
                Spacer()
                NavigationLink(destination: MealView()) {
                    Text("meal")
                }.frame(minWidth: 0, maxWidth: 100, minHeight: 0, maxHeight: 100, alignment: .center).padding()
                Spacer()
                NavigationLink(destination: MealView()) {
                    Text("meal")
                }.frame(minWidth: 0, maxWidth: 100, minHeight: 0, maxHeight: 100, alignment: .center).padding()
                Spacer()
                }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 100, alignment: .topLeading).padding([.leading,.trailing], 10)
                
                HStack {
                Spacer()
                NavigationLink(destination: MealView()) {
                    Text("meal")
                }.frame(minWidth: 0, maxWidth: 100, minHeight: 0, maxHeight: 100, alignment: .center).padding()
                Spacer()
                NavigationLink(destination: MealView()) {
                    Text("meal")
                }.frame(minWidth: 0, maxWidth: 100, minHeight: 0, maxHeight: 100, alignment: .center).padding()
                Spacer()
                NavigationLink(destination: MealView()) {
                    Text("meal")
                }.frame(minWidth: 0, maxWidth: 100, minHeight: 0, maxHeight: 100, alignment: .center).padding()
                Spacer()
                }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 100, alignment: .topLeading).padding([.leading,.trailing], 10)
            }

        }.background(Color.orange)
    }
}

struct MyInfoView: View {
    @EnvironmentObject var userData: UserDownloader
    
    var body: some View {
        
        List {
            Section(header: Text("기본정보")) {
                Text("test")
            }
        }.listStyle(GroupedListStyle())
    }
}

struct MainView: View {
    @State private var selection = 0
    @EnvironmentObject var userData: UserDownloader
    
    
    var body: some View {
        
        return ZStack {
            
            TabView(selection: $selection){
                HomeView()
                    .tabItem {
                        VStack {
                            Image(systemName: "house")
                            Text("홈")
                        }
                    }
                    .tag(0)
                Text("카테고리")
                    .font(.title)
                    .tabItem {
                        VStack {
                            Image(systemName: "list.dash")
                            Text("카테고리")
                        }
                    }
                    .tag(1)
                MyInfoView()
                .font(.title)
                .tabItem {
                    VStack {
                        Image(systemName: "person")
                        Text("내정보")
                    }
                }
                .tag(2)
            }.accentColor(.blue)
            
        }
        
        
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
