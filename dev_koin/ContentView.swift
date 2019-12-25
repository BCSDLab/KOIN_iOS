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

struct HomeView: View {
    let rows: CGFloat = 3
    let columns: CGFloat = 3
    let spacing: CGFloat = 0
    
    var horizontalEdges: CGFloat {
        return columns - 1
    }

    var verticalEdges: CGFloat {
        return rows - 1
    }

    func getItemWidth(containerWidth: CGFloat) -> CGFloat {
        return (containerWidth - 50 - spacing * horizontalEdges) / columns
    }

    func getItemHeight(containerHeight: CGFloat) -> CGFloat {
        return (containerHeight - spacing * verticalEdges) / rows
    }
    
    var body: some View {
        ZStack {
            
            GeometryReader { geometry in
            Rectangle()
                .fill(Color("squash"))
                .frame(width: geometry.size.width, height: 350)
                .zIndex(-3)
            Image("img_bg")
                .renderingMode(.original)
                .resizable()
                .frame(width: geometry.size.width, height: 350)
                .zIndex(-2)
            VStack(alignment: .leading) {
                Image("logo_footer")
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60)
                Text("\'코인\' ios앱 출시")
                    .fontWeight(.light)
                    .foregroundColor(Color.white.opacity(0.5))
                    .font(.system(size: 15))
                    .padding(.top, 20)
                Text("코리아텍 학생들이\n함께 만들어가는 커뮤니티")
                    .font(.system(size: 25))
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, maxHeight:70, alignment: .leading)
                    
                }.zIndex(-1)
                .frame(maxWidth: .infinity, maxHeight: 200, alignment: .leading)
                    .padding(.top,50)
                    .padding(.leading, 25)
                
                
                
                VStack() {
                    Spacer()
                    VStack(alignment: .center, spacing: self.spacing) {
                            HStack(alignment: .center, spacing: self.spacing) {
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
                                }.border(Color.gray.opacity(0.2), width: 0.5)

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
                                    }.border(Color.gray.opacity(0.2), width: 0.5)

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
                                    }.border(Color.gray.opacity(0.2), width: 0.5)
                                }

                            HStack(alignment: .center, spacing: self.spacing) {
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
                                }.border(Color.gray.opacity(0.2), width: 0.5)

                                Button(action: {}) {
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
                                }.border(Color.gray.opacity(0.2), width: 0.5)

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
                                }.border(Color.gray.opacity(0.2), width: 0.5)
                            }

                            HStack(alignment: .center, spacing: self.spacing) {
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
                                }.border(Color.gray.opacity(0.2), width: 0.5)

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
                                }.border(Color.gray.opacity(0.2), width: 0.5)

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
                                }.border(Color.gray.opacity(0.2), width: 0.5)
                            }

                        }.background(Color.white)
                            .frame(maxWidth: .infinity)
                            }
                        .clipped()
                        .shadow(color: Color.black.opacity(0.3), radius: 3, x: 5, y: 5)
                .padding(.bottom, 40)
                    }
                }.zIndex(0)
                    
                
    
        
        
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
                    Spacer()
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
                    Spacer()
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
    @ObservedObject var viewRouter = ViewRouter()
    
    @State var showSideMenu = false
    
    
    var body: some View {
        return GeometryReader { geometry in
            VStack {
                if self.viewRouter.currentView == "home" {
                    HomeView()
                } else if self.viewRouter.currentView == "info" {
                    NavigationView{
                        MyInfoView()
                    }
                }
                ZStack {
                    HStack {
                        Spacer()
                        VStack {
                            Spacer()
                            Image("bottom_home")
                                .resizable()
                                .renderingMode(.template)
                                .frame(width:45, height: 30)
                                .aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
                            Text("홈")
                            .font(.system(size: 12))
                            .fontWeight(.medium)
                            Spacer()
                                }.onTapGesture {
                                    self.viewRouter.currentView = "home"
                                }
                        .foregroundColor(self.viewRouter.currentView == "home" ? .blue : Color.black.opacity(0.7))
                        .accentColor(self.viewRouter.currentView == "hone" ? .blue : Color.black.opacity(0.7))
                        .padding()
                        Spacer()
                        VStack {
                        Image("bottom_category")
                            .resizable()
                            .renderingMode(.template)
                            .frame(width:45, height: 30)
                        Text("카테고리")
                            .font(.system(size: 12))
                            .fontWeight(.medium)
                            }
                        .padding()
                            .foregroundColor(Color.black.opacity(0.7))
                            .accentColor(Color.black.opacity(0.7))
                        .onTapGesture {
                                
                            }
                        Spacer()
                        VStack {
                        Image("bottom_myinfo")
                            .resizable()
                            .renderingMode(.template)
                            .frame(width:45, height: 30)
                            
                        Text("내정보")
                            .font(.system(size: 12))
                            .fontWeight(.medium)
                            }.onTapGesture {
                                self.viewRouter.currentView = "info"
                            }
                            .foregroundColor(self.viewRouter.currentView == "info" ? .blue : Color.black.opacity(0.7))
                        .accentColor(self.viewRouter.currentView == "info" ? .blue : Color.black.opacity(0.7))
                        .padding()
                        Spacer()
                    }
                        .frame(width: geometry.size.width, height: geometry.size.height/11)
                    .background(Color.white.shadow(radius: 2))
                }
            }.edgesIgnoringSafeArea(.bottom)
        }
            
           
    }
    
}
    
    /*
               TabView(selection: $selection){
                   HomeView()
                       .background(Color.white)
                   .tabItem {
                           VStack {
                               Image("bottom_home")
                                   .renderingMode(.template)
                                   .font(.subheadline)
                                   .accentColor(.blue)
                               Text("홈")
                           }
                       }.accentColor(.blue)
                       .tag(0)
                   Text("카테고리")
                       .font(.title)
                       .tabItem {
                           VStack {
                               Image("bottom_category")
                                   .renderingMode(.template)
                                   .font(.subheadline)
                                   .accentColor(.blue)
                               Text("카테고리")
                           }
                       }.accentColor(.blue)
                       .tag(1)
                   NavigationView {
                   MyInfoView()
                   }
                       .tabItem {
                       VStack {
                           Image("bottom_myinfo")
                               .renderingMode(.template)
                               .font(.subheadline)
                               .accentColor(.blue)
                           Text("내정보")
                       }
                   }.accentColor(.blue)
                   .tag(2)
               }
               
           }
           
           */

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
