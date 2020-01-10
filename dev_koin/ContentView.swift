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
    //@EnvironmentObject var viewRouter: ViewRouter

    init() {
      UITableView.appearance().separatorColor = .clear
    }

    var body: some View {
        return
            VStack {
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
                .padding(.leading, CGFloat(20))
                .padding(.trailing, CGFloat(20))
                .padding(.top, CGFloat(50))
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
            
        }.onAppear {
                print("MenuContent appeared!")
            }.onDisappear {
                print("MenuContent disappeared!")
            }
    }
}


struct SideMenu: View {
    let width: CGFloat
    @EnvironmentObject var tabData: ViewRouter
    
    var body: some View {
        ZStack {
            GeometryReader { _ in
                EmptyView()
            }
                .background(Color.gray.opacity(0.3))
                .opacity(self.tabData.isCustomItemSelected ? 1.0 : 0.0)
                .animation(Animation.easeIn.delay(0.25))
                .edgesIgnoringSafeArea(.top)
                .onTapGesture {
                    self.tabData.dismiss_menu()
                    print(self.tabData.isCustomItemSelected)
                }
            HStack {
                MenuContent()
                    .frame(width: self.width)
                    .background(Color.white)
                    .offset(x: self.tabData.isCustomItemSelected ? 0 : -self.width)
                    .animation(.default).edgesIgnoringSafeArea(.top)
                Spacer()
            }
        }.onAppear {
            print("SideMenu appeared!")
        }.onDisappear {
            print("SideMenu disappeared!")
        }
    }
}


struct EditModalView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var settings: UserSettings
    @State var updated_password: String = ""
    @State var updated_name: String = ""
    @State var updated_nickname: String = ""
    @State var updated_gender: Int = -1
    @State var updated_studentNumber: String = ""
    @State var updated_phoneNumber: String = ""
    var disableName: Bool = false
    var disableGender: Bool = false
    var disablePhoneNumber: Bool = false
    var disableStudentNumber: Bool = false
    
    init() {
        if let data = UserDefaults.standard.object(forKey:"user") as? Data {
            let decoder = JSONDecoder()
            if let loaded = try? decoder.decode(UserRequest.self, from: data) {
                print(loaded.user)
        if let userInfo = loaded.user {
                    
                    if let infoName = userInfo.name { print(infoName)
                        if !infoName.isEmpty {
                            print("not empty")
                            _updated_name = State(initialValue: infoName)
                        self.disableName = true
                        }}
            print(self.disableName)
                    if let infoNickname = userInfo.nickname { print(infoNickname)
                        if !infoNickname.isEmpty {
                            print("not empty")
                    //self.updated_nickname = infoNickname
                            _updated_nickname = State(initialValue: infoNickname)
                        //중복 여부 체크
                    }}
            print(updated_nickname)
                    if let infoPhoneNumber = userInfo.phoneNumber { print(infoPhoneNumber)
                        if !infoPhoneNumber.isEmpty {
                            print("not empty")
                    //self.updated_phoneNumber = infoPhoneNumber
                            _updated_phoneNumber = State(initialValue: infoPhoneNumber)
                    self.disablePhoneNumber = true
                    }}
            print(self.disablePhoneNumber)
                    if let infoGender = userInfo.gender { print(infoGender)
                        if infoGender != -1 {
                            print("not empty")
                    _updated_gender = State(initialValue: infoGender)
                    self.disableGender = true
                    }}
            print(self.disableGender)
                    if let infoStudentNumber = userInfo.studentNumber {print(infoStudentNumber)
                        if !infoStudentNumber.isEmpty {
                            print("not empty")
                    _updated_studentNumber = State(initialValue: infoStudentNumber)
                    self.disableStudentNumber = true
                    } }
            print(self.disableStudentNumber)
                    
                    
                }
            }
        }
    }
    
    func putUserData() {
        var changedNickname: Bool = false
        var token: String = ""
        print("start userData")
        if let data = UserDefaults.standard.object(forKey:"user") as? Data {
            print("userdefaults")
            let decoder = JSONDecoder()
            if let loaded = try? decoder.decode(UserRequest.self, from: data) {
                if let token_data = loaded.token {
                    token = token_data
                }
        if let userInfo = loaded.user {
            print(userInfo.nickname)
            print(updated_nickname)
            if userInfo.nickname != updated_nickname {
                print("changed Nickname")
                changedNickname = true
            }
            
                }
            }
        }
        
        
        
        self.settings.update_session(token: token, updated_password: updated_password, updated_name: updated_name, updated_nickname: updated_nickname, updated_gender: updated_gender, updated_isGraduated: false, updated_studentNumber: updated_studentNumber, updated_phoneNumber: updated_phoneNumber, changed_name: !self.disableName, changed_gender: !self.disableGender, changed_phoneNumber: !self.disablePhoneNumber, changed_studentNumber: !self.disableStudentNumber, changed_nickname: changedNickname) { result in
            if result {
                self.presentationMode.wrappedValue.dismiss()
            }
        }
    }
    

    var body: some View {
        let someNumberProxy = Binding<String>(
            get: { String(format: "%d", Int(self.updated_gender)) },
            set: {
                if let value = NumberFormatter().number(from: $0) {
                    self.updated_gender = value.intValue
                }
            }
        )
        
    return VStack{
        SecureField("비밀번호", text: $updated_password)
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
                .font(.subheadline)
        TextField("이름", text: $updated_name)
        .disabled(disableName)
        .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
        .font(.subheadline)
        TextField("닉네임", text: $updated_nickname)
        .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
        .font(.subheadline)
        
        TextField("성별", text: someNumberProxy)
            .disabled(disableGender)
        .keyboardType(.decimalPad)
        .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
        .font(.subheadline)
        
        TextField("학번", text: $updated_studentNumber)
            .disabled(disableStudentNumber)
        .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
        .font(.subheadline)
        TextField("핸드폰 번호", text: $updated_phoneNumber)
            .disabled(disablePhoneNumber)
        .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
        .font(.subheadline)
        
        
        Button(action: putUserData){
            Text("보내기")
        }
    }.onAppear {
        print("EditUserView appeared!")
    }.onDisappear {
        print("EditUserView disappeared!")
    }
}
}


struct MyInfoView: View {
    @EnvironmentObject var settings: UserSettings
    @State private var show_modal: Bool = false

    func loadUserInfo() -> [[[String]]] {
        var listData: [[[String]]] = []
        if let data = UserDefaults.standard.object(forKey:"user") as? Data {
            let decoder = JSONDecoder()
            if let loaded = try? decoder.decode(UserRequest.self, from: data) {
                if let userInfo = loaded.user {
                    var name: String = "이름 없음"
                    var nickname: String = "닉네임 없음"
                    var phoneNumber: String = "휴대폰 번호 없음"
                    var gender: String = "성별 없음"
                    var studentNumber: String = "학번 없음"
                    var major: String = "전공 없음"

                    if let infoName = userInfo.name { name = infoName }
                    if let infoNickname = userInfo.nickname {nickname = infoNickname}
                    if let infoPhoneNumber = userInfo.phoneNumber {phoneNumber = infoPhoneNumber}
                    if let infoGender = userInfo.gender {
                        gender = infoGender == 0 ? "남자":"여자"
                    }
                    if let infoStudentNumber = userInfo.studentNumber {studentNumber = infoStudentNumber}
                    if let infoMajor = userInfo.major {major = infoMajor}

                    listData = [[["아이디", userInfo.portalAccount], ["이름", name], ["닉네임", nickname], ["익명닉네임", userInfo.anonymousNickname], ["휴대전화", phoneNumber], ["성별", gender]], [["학번",studentNumber], ["전공",major]]]


                }
            }
        }
        return listData
    }
    
    var body: some View {
        var listData = loadUserInfo()

        return List{
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
            ForEach(listData[1], id: \.self) { school in
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
                        self.settings.delete_session(token: self.settings.get_token())
                    }
                    Spacer()
                    Divider()
                    Spacer()
                    Text("로그아웃").onTapGesture {
                        self.settings.logout_session()
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
    
    init() {
        UINavigationBar.appearance().barTintColor = UIColor(named: "light_navy")
        UINavigationBar.appearance().tintColor = UIColor.white
        //Use this if NavigationBarTitle is with Large Font
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.white]

        //Use this if NavigationBarTitle is with displayMode = .inline
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

                        NavigationLink(destination: MealView()) {
                        //Button(action: {}) {
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
        .onAppear {
            print("HomeView appeared!")
        }.onDisappear {
            print("HomeView disappeared!")
        }
    }
}

struct ContentTabView: View {
    @EnvironmentObject var tabData: ViewRouter
    @EnvironmentObject var settings: UserSettings
    @State private var show_modal: Bool = false
    
    init() {
        UINavigationBar.appearance().barTintColor = UIColor(named: "light_navy")
        //Use this if NavigationBarTitle is with Large Font
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.white]

        //Use this if NavigationBarTitle is with displayMode = .inline
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
    }
    

        var body: some View {
            GeometryReader { geometry in
            ZStack {
                SideMenu(width: geometry.size.width/3*2)
                
            }.zIndex(99)
                TabView (selection: self.$tabData.itemSelected){

            // First Secection
            NavigationView{
                HomeView()
                .navigationBarTitle("")
                .navigationBarHidden(true)
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

            // Add Element
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

            // Events
            NavigationView{
                MyInfoView()
                .navigationBarTitle("내 정보")
                .navigationBarItems(trailing: Button(action: {
                    print("put modal on")
                    self.show_modal = true
                }) {
                    Text("정보 수정")
                }.sheet(isPresented: self.$show_modal) {
                    EditModalView().environmentObject(self.settings)
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
        }.onAppear {
            print("ContentTabView appeared!")
        }.onDisappear {
            print("ContentTabView disappeared!")
        }
    }
    }

struct ContentView: View {
    
    var body: some View {
        ContentTabView()
    }
}
    

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


