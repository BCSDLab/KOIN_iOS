//
//  ContentView.swift
//  dev_koin
//
//  Created by 정태훈 on 2019/12/08.
//  Copyright © 2019 정태훈. All rights reserved.
//

import SwiftUI

struct MenuContent: View {
    @EnvironmentObject var settings: UserSettings

    init() {
      UITableView.appearance().separatorColor = .clear
    }

    var body: some View {
        return VStack {
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
                .padding([.leading, .trailing, .top], 20)
                List {
                    HStack {
                        Image(systemName: "person")
                        Text("내정보")
                            .font(.subheadline)
                        
                        
                        }.onTapGesture {
                            UserDefaults.standard.removeObject(forKey: "user")
                            //UserDefaults.standard.synchronize()
                            self.settings.logout_session()
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
            }.onAppear {
                print("MenuContent appeared!")
            }.onDisappear {
                print("MenuContent disappeared!")
            }
    }
}


struct SideMenu: View {
    let width: CGFloat
    let isOpen: Bool
    let menuClose: () -> Void
    
    var body: some View {
        ZStack {
            GeometryReader { _ in
                EmptyView()
            }
                .background(Color.gray.opacity(0.3))
                .opacity(self.isOpen ? 1.0 : 0.0)
                .animation(Animation.easeIn.delay(0.25))
                .onTapGesture {
                    self.menuClose()
                }
            HStack {
                MenuContent()
                    .frame(width: self.width)
                    .background(Color.white)
                    .offset(x: self.isOpen ? 0 : -self.width)
                    .animation(.default)
                Spacer()
            }
        }.onAppear {
            print("SideMenu appeared!")
        }.onDisappear {
            print("SideMenu disappeared!")
        }
    }
}


struct MyInfoView: View {
    var listData: [[[String]]] = []
    //@EnvironmentObject var settings: UserSettings
    
    init() {
        loadUserInfo()
    }
    
    mutating func loadUserInfo(){
        if let data = UserDefaults.standard.object(forKey:"user") as? Data {
            let decoder = JSONDecoder()
            if let loaded = try? decoder.decode(UserRequest.self, from: data) {
                if let userInfo = loaded.user {
                    listData =  [[["아이디",userInfo.portalAccount], ["이름",userInfo.name], ["닉네임",userInfo.nickname], ["익명닉네임",userInfo.anonymousNickname], ["휴대전화",userInfo.phoneNumber], ["성별",userInfo.gender == 0 ? "남자":"여자"]], [["학번",userInfo.studentNumber], ["전공",userInfo.major]]]
                    
                }
            }
        }
    }
    
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
     
                HStack {
                    Spacer()
                    Text("회원탈퇴").onTapGesture {
                        
                    }
                    Spacer()
                    Divider()
                    Spacer()
                    Text("로그아웃").onTapGesture {
                        //UserDefaults.standard.set(false, forKey: "Loggedin")
                        //UserDefaults.standard.removeObject(forKey: "user")
                        //UserDefaults.standard.synchronize()
                        //StartView()
                    }
                    Spacer()
                }
                
            }
            .listStyle(GroupedListStyle())
        .onAppear {
            print("MyInfoView appeared!")
        }.onDisappear {
            print("MyInfoView disappeared!")
        }
            
            
            
        
        
        
    }
}


struct HomeView: View {
    
    func getItemWidth(containerWidth: CGFloat) -> CGFloat {
        return (containerWidth - 50) / 3
    }

    func getItemHeight(containerHeight: CGFloat) -> CGFloat {
        return (containerHeight) / 3
    }
    
    var body: some View {
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
                .padding(.top, 80)
                
                
                Spacer()
            }.frame(width: geometry.size.width, height: geometry.size.height, alignment: .leading)
                
          
            
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

                        NavigationLink(destination: MealView().navigationBarTitle(Text("식단"), displayMode: .inline)) {
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
                .padding(.bottom, 70)
            }
            
        }.onAppear {
            print("HomeView appeared!")
        }.onDisappear {
            print("HomeView disappeared!")
        }
    }
}

struct MainView: View {
    @ObservedObject var viewRouter = ViewRouter()
    @State var menuOpen: Bool = false
    
    func openMenu() {
        self.menuOpen.toggle()
    }
    
    var body: some View {
        return GeometryReader { geometry in
                ZStack {
                    SideMenu(width: geometry.size.width/3*2, isOpen: self.menuOpen, menuClose: self.openMenu)
                }.zIndex(99)
                VStack {
                    VStack {
                        if self.viewRouter.currentView == 0 {
                            NavigationView{
                                HomeView()
                                .navigationBarTitle("")
                                .navigationBarHidden(true)
                            }
                            
                        } else {
                            
                            NavigationView{
                                MyInfoView()
                                .navigationBarTitle("내 정보")
                            }
                            
                        }
                    }.frame(width: geometry.size.width, height: geometry.size.height-56)
                    ZStack {
                        HStack {
                            Spacer()
                            VStack {
                                Spacer()
                                Image("bottom_home")
                                    .resizable()
                                    .renderingMode(.template)
                                    .frame(width:38, height: 24)
                                    .aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
                                Text("홈")
                                    .font(.system(size: 12))
                                    .fontWeight(.medium)
                                Spacer()
                                }.onTapGesture {
                                    self.viewRouter.currentView = 0
                                }
                                .foregroundColor(self.viewRouter.currentView == 0 ? .blue : Color.black.opacity(0.7))
                                .accentColor(self.viewRouter.currentView == 0 ? .blue : Color.black.opacity(0.7))
                                .padding()
                            Spacer()
                            Spacer()
                            VStack {
                                Image("bottom_category")
                                    .resizable()
                                    .renderingMode(.template)
                                    .frame(width:38, height: 24)
                                Text("카테고리")
                                    .font(.system(size: 12))
                                    .fontWeight(.medium)
                                }
                                .padding()
                                .foregroundColor(Color.black.opacity(0.7))
                                .accentColor(Color.black.opacity(0.7))
                                .onTapGesture {
                                    self.openMenu()
                                }
                            Spacer()
                            Spacer()
                                VStack {
                                    Image("bottom_myinfo")
                                        .resizable()
                                        .renderingMode(.template)
                                        .frame(width:38, height: 24)
                                    Text("내정보")
                                        .font(.system(size: 12))
                                        .fontWeight(.medium)
                                    }
                                    .onTapGesture {
                                        print(self.viewRouter.currentView)
                                        self.viewRouter.currentView = 1
                                        print(self.viewRouter.currentView)
                                        
                                    }
                                    .foregroundColor(self.viewRouter.currentView == 1 ? .blue : Color.black.opacity(0.7))
                                    .accentColor(self.viewRouter.currentView == 1 ? .blue : Color.black.opacity(0.7))
                                    .padding()
                                Spacer()
                            }
                            .frame(width: geometry.size.width, height: 56)
                            .background(Color.white.shadow(radius: 2))
                        }
                    }
                }.onAppear {
                    print("MainView appeared!")
                }.onDisappear {
                    print("MainView disappeared!")
                }
    }
}

struct ContentView: View {
    var body: some View {
        MainView()
    }
}
    

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


