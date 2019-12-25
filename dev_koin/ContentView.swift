//
//  ContentView.swift
//  dev_koin
//
//  Created by 정태훈 on 2019/12/08.
//  Copyright © 2019 정태훈. All rights reserved.
//

import SwiftUI

struct MenuContent: View {

    init() {
      UITableView.appearance().separatorColor = .clear
    }

    var body: some View {
        return VStack {
                HStack {
                    Text("홍길동")
                        .font(.system(size: 20))
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                    Text("님,안녕하세요!")
                        .font(.system(size: 15))
                        .foregroundColor(.blue)
                    Spacer()
                    Image("img_menu_logo")
                }
                .padding([.leading, .trailing, .top], 20)
                List {
                    HStack {
                        Image(systemName: "person")
                        Text("내정보")
                            .font(.subheadline)
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
                .edgesIgnoringSafeArea(.all)
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
                    .edgesIgnoringSafeArea(.top)
                Spacer()
            }
        }
    }
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
        }
        .listStyle(GroupedListStyle())
    }
}

struct HomeView: View {
    let rows: CGFloat = 3
    let columns: CGFloat = 3
    
    var horizontalEdges: CGFloat {
        return columns - 1
    }

    var verticalEdges: CGFloat {
        return rows - 1
    }

    func getItemWidth(containerWidth: CGFloat) -> CGFloat {
        return (containerWidth - 50) / columns
    }

    func getItemHeight(containerHeight: CGFloat) -> CGFloat {
        return (containerHeight) / rows
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                Rectangle()
                    .fill(Color("squash"))
                    .frame(width: geometry.size.width, height: 350)
                    .zIndex(-10)
                    .edgesIgnoringSafeArea(.top)
                Image("img_bg")
                    .renderingMode(.original)
                    .resizable()
                    .frame(width: geometry.size.width, height: 350)
                    .zIndex(-5)
                    .edgesIgnoringSafeArea(.top)
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
            }
            .zIndex(-1)
            .frame(maxWidth: .infinity, maxHeight: 200, alignment: .leading)
            .padding(.top,50)
            .padding(.leading, 25)
            VStack() {
                Spacer()
                VStack(alignment: .center) {
                    HStack(alignment: .center) {
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
                    HStack(alignment: .center) {
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
                        .border(Color.gray.opacity(0.2), width: 0.5)

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
                    HStack(alignment: .center) {
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
                .padding(.bottom, 40)
            }
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
                                    self.openMenu()
                                }
                            Spacer()
                            Spacer()
                                VStack {
                                    Image("bottom_myinfo")
                                        .resizable()
                                        .renderingMode(.template)
                                        .frame(width:45, height: 30)
                                    Text("내정보")
                                        .font(.system(size: 12))
                                        .fontWeight(.medium)
                                    }
                                    .onTapGesture {
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
                    }
                }
    }
}

struct ContentView: View {
    var body: some View {
        MainView()
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
    

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


