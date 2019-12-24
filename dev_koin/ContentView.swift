//
//  ContentView.swift
//  dev_koin
//
//  Created by 정태훈 on 2019/12/08.
//  Copyright © 2019 정태훈. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    
    
    var body: some View {

        MainView()

    }
}

struct MenuView: View {
    var body: some View {
        
        EmptyView()
    }
}

struct HomeView: View {
    var body: some View {
        return EmptyView()
    }
}

func loadUserInfo() -> [[[String]]] {
    
    if let data = UserDefaults.standard.object(forKey:"user") as? Data {
        let decoder = JSONDecoder()
        if let loaded = try? decoder.decode(UserRequest.self, from: data) {
            if let userInfo = loaded.user {
                let userInfoData = [[["아이디",userInfo.portalAccount], ["이름",userInfo.name], ["닉네임",userInfo.nickname], ["익명닉네임",userInfo.anonymousNickname], ["휴대전화",userInfo.phoneNumber], ["성별",userInfo.gender == 0 ? "남자":"여자"]], [["학번",userInfo.studentNumber], ["전공",userInfo.major]]]
                return userInfoData
            }
        }
    }
    return []
}



struct MyInfoView: View {
    var listData: [[[String]]] = loadUserInfo()

    
    
    var body: some View {
        
        List {
            Section(header: Text("기본정보")) {
                ForEach(listData[0], id:\.self) { general in
                    HStack {
                    Text(general[0])
                        .font(.headline)
                        .fontWeight(.semibold)
                    Text(general[1])
                        .font(.subheadline)
                        .fontWeight(.light)

                    }
                    
                }
                
                
            }
            Section(header: Text("학교정보")) {
                ForEach(listData[1], id:\.self) { school in
                    HStack {
                    Text(school[0])
                        .font(.headline)
                        .fontWeight(.semibold)
                    Text(school[1])
                        .font(.subheadline)
                        .fontWeight(.light)

                    }
                    
                }
                
            }
        }.listStyle(GroupedListStyle())
    }
}

struct MainView: View {
    @State private var selection = 0
    
    
    var body: some View {
        
        return ZStack {
            
            TabView(selection: $selection){
                Text("홈")
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
                NavigationView {
                MyInfoView()
                }
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
