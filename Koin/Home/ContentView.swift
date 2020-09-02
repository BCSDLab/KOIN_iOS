//
//  ContentView.swift
//  dev_koin
//
//  Created by 정태훈 on 2019/12/08.
//  Copyright © 2019 정태훈. All rights reserved.
//

import SwiftUI
import PKHUD

// MARK: 커스텀 탭바 구현
// 버튼 클릭 시 이동 방법 재구성


struct ContentView: View {
    // 탭과 관련된 데이터를 가지고 있는 오브젝트
    @EnvironmentObject var tabData: ViewRouter
    // 유저와 관련된 데이터를 가지고 있는 오브젝트
    @EnvironmentObject var config: UserConfig
    
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @State var pushActive = false
    
    @State var currentView = AnyView(Text(""))
    @State var testIndex: Int = 1
    
    func getView(current: String) -> AnyView {
        /*if current == "home" { // 현재 뷰가 home이면 HomeView를 보여준다.
            return AnyView(HomeView().environmentObject(self.tabData).navigationBarTitle("홈").navigationBarHidden(true))
                //.environmentObject(self.tabData)
                //.navigationBarTitle("") //네비게이션바의 제목은 없고
                //.navigationBarHidden(true)
            //네비게이션바를 숨긴다.
        } else */if current == "dining" { // 현재 뷰가 dining이면 MealView를 보여준다.
            //NavigationView{
            return AnyView(
                    MealView()
                         // 네비게이션바의 제목은 식단이며, 한줄로 표시
                        /*
                        .navigationBarItems(leading: Button(action: self.tabData.go_home) { //네비게이션바 왼쪽엔 홈으로 가는 버튼을
                            HStack {
                                Image(systemName: "chevron.left")
                                Text("홈")
                            }.accentColor(.white)
                        }, trailing: EmptyView())*/
            )
                //네비게이션바 오른쪽엔 아무것도 설정하지 않는다.
            //}
        } else if current == "myinfo" { // 현재 뷰가 myinfo이면 MyInfoView를 보여준다.
            //NavigationView{
            return AnyView(MyInfoView()
                .navigationBarTitle("내정보", displayMode: .inline)
                 // 네비게이션바의 제목은 내정보이며, 한줄로 표시
                    /*
                    .navigationBarItems(leading: Button(action: self.tabData.go_home) { //네비게이션바 왼쪽엔 홈으로 가는 버튼을
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("홈")
                        }
                    })*/
                
            )
                
                
            //}.accentColor(.white)
            
        } else if current == "store" {
            //NavigationView{
            return AnyView(BetaStoreView()
                
                
                    /*.navigationBarItems(leading: Button(action: self.tabData.go_home) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("홈")
                        }
                    }, trailing: EmptyView())*/
            )
                
            //}.accentColor(.white)
        } else if current == "board_free" {
            //NavigationView{
            return AnyView(
                CommunityView<Article,Comment>(boardId: 1)
                    
                    //.navigationBarTitle("자유게시판", displayMode: .inline)
            )
                
            //}.accentColor(.white)
        } else if current == "board_recruit" {
            //NavigationView{
            return AnyView(
                CommunityView<Article,Comment>(boardId: 2)
                    
                    //.navigationBarTitle("취업게시판", displayMode: .inline)
            )
                //
                //
            //}
        } else if current == "board_secret" {
            //NavigationView{
            return AnyView(CommunityView<TempArticle,TempComment>(boardId: -2)
                
                //.navigationBarTitle("익명게시판", displayMode: .inline)
            )
                //
                //
            //}.accentColor(.white)
        }  else if current == "bus" {
            //NavigationView{
            return AnyView(
                BusView()
                    .navigationBarTitle("버스", displayMode: .inline)
                    
                        /*.navigationBarItems(leading: Button(action: self.tabData.go_home) {
                            HStack {
                                Image(systemName: "chevron.left")
                                Text("홈")
                            }
                        }, trailing: EmptyView())*/
            )
                
            //}.accentColor(.white)
        } else if current == "circle" {
            //NavigationView{
            return AnyView(
                CircleView()
                    
                    
                        /*.navigationBarItems(leading: Button(action: self.tabData.go_home) {
                            HStack {
                                Image(systemName: "chevron.left")
                                Text("홈")
                            }
                        }, trailing: EmptyView())*/
            )
                
            //}.accentColor(.white)
        }
        return AnyView(HomeView().environmentObject(self.tabData).navigationBarTitle("홈").navigationBarHidden(true))
    }
    
    
    init() {
        
        // 네비게이션 바 색 설정
        UINavigationBar.appearance().barTintColor = UIColor(named: "squash")
        UINavigationBar.appearance().backgroundColor = UIColor(named: "squash")
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        //UINavigationBar.appearance().isTranslucent = false
        UIBarButtonItem.appearance().tintColor = UIColor.white
        /*
        // 네비게이션 바 글자색 설정(흰색)
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
        //UINavigationBar.appearance().layer.backgroundColor = UIColor.clear.cgColor
        UINavigationBar.appearance().layer.shadowColor = UIColor.clear.cgColor
        //UITabBar.appearance().sizeToFit()
        */
        
        //UIApplication.shared.statusBarUIView?.backgroundColor = UIColor.clear
    }
    // onreceive될 때 해당 view를 읽어서 이동
    
    var body: some View {
        //현재 화면의 가로, 세로 넓이를 인식할 수 있게 해주는 뷰
        return GeometryReader { geometry in
            // 레이어 맨 위에 SideMenu가 오도록 배치
            ZStack {
                // SideMenu의 가로 길이는 현재 화면의 2/3 차지할 수 있게
                SideMenu(width: geometry.size.width * 2 / 3)
            }.zIndex(99)
            
            // 탭 기능을 구현하게 해주는 뷰, selection에 따라 보여주는 뷰가 달라진다.
            TabView(selection: self.$testIndex) {
                
                NavigationView {
                    VStack {
                        HomeView()
                            //.environmentObject(self.tabData)
                            .navigationBarTitle("")
                            .navigationBarHidden(true)
                        
                        NavigationLink(destination: self.currentView, isActive: self.$pushActive) {
                            Text("")
                        }.hidden()
                        
                    }
                    .onReceive(self.tabData.currentViewChange) { current in
                        self.currentView = self.getView(current: current)
                        self.pushActive = true
                    }
                        /*
                    .onReceive(self.tabData.currentView) { current in
                        if current == "home" { // 현재 뷰가 home이면 HomeView를 보여준다.
                            HomeView()
                                //.environmentObject(self.tabData)
                                .navigationBarTitle("") //네비게이션바의 제목은 없고
                                .navigationBarHidden(true)
                            //네비게이션바를 숨긴다.
                        } else if current == "dining" { // 현재 뷰가 dining이면 MealView를 보여준다.
                            //NavigationView{
                            MealView()
                                .navigationBarTitle("식단", displayMode: .inline).accentColor(.white) // 네비게이션바의 제목은 식단이며, 한줄로 표시
                                .navigationBarItems(leading: Button(action: self.tabData.go_home) { //네비게이션바 왼쪽엔 홈으로 가는 버튼을
                                    HStack {
                                        Image(systemName: "chevron.left")
                                        Text("홈")
                                    }.accentColor(.white)
                                }, trailing: EmptyView()) //네비게이션바 오른쪽엔 아무것도 설정하지 않는다.
                            //}
                        } else if current == "myinfo" { // 현재 뷰가 myinfo이면 MyInfoView를 보여준다.
                            //NavigationView{
                            MyInfoView(viewModel: MyInfoViewModel(userFetcher: UserFetcher(), user: self.config.user))
                                .navigationBarTitle("내정보", displayMode: .inline) // 네비게이션바의 제목은 내정보이며, 한줄로 표시
                                .navigationBarItems(leading: Button(action: self.tabData.go_home) { //네비게이션바 왼쪽엔 홈으로 가는 버튼을
                                    HStack {
                                        Image(systemName: "chevron.left")
                                        Text("홈")
                                    }
                                })
                            //}.accentColor(.white)
                            
                        } else if current == "store" {
                            //NavigationView{
                            BetaStoreView(viewModel: StoreViewModel())
                                .navigationBarTitle("주변식당", displayMode: .inline)
                                .navigationBarItems(leading: Button(action: self.tabData.go_home) {
                                    HStack {
                                        Image(systemName: "chevron.left")
                                        Text("홈")
                                    }
                                }, trailing: EmptyView())
                            //}.accentColor(.white)
                        } else if current == "board_free" {
                            
                            //NavigationView{
                            CommunityView<Article,Comment>(viewModel: CommunityViewModel(communityFetcher: CommunityFetcher(), boardId: 1, userId: -1))
                                //.environmentObject(self.tabData)
                                .navigationBarTitle("자유게시판", displayMode: .inline)
                            //}.accentColor(.white)
                        } else if current == "board_recruit" {
                            //NavigationView{
                            CommunityView<Article,Comment>(viewModel: CommunityViewModel(communityFetcher: CommunityFetcher(), boardId: 2, userId:-1))
                                //.environmentObject(self.tabData)
                                .navigationBarTitle("취업게시판", displayMode: .inline)
                            //}
                        } else if current == "board_secret" {
                            //NavigationView{
                            CommunityView<TempArticle,TempComment>(viewModel: CommunityViewModel(communityFetcher: CommunityFetcher(), boardId: -2, userId:-1))
                                //.environmentObject(self.tabData)
                                .navigationBarTitle("익명게시판", displayMode: .inline)
                            //}.accentColor(.white)
                        }  else if current == "bus" {
                            //NavigationView{
                            BusView()
                                .navigationBarTitle("버스", displayMode: .inline)
                                .navigationBarItems(leading: Button(action: self.tabData.go_home) {
                                    HStack {
                                        Image(systemName: "chevron.left")
                                        Text("홈")
                                    }
                                }, trailing: EmptyView())
                            //}.accentColor(.white)
                        } else if current == "circle" {
                            //NavigationView{
                            CircleView(viewModel: CircleViewModel())
                                .navigationBarTitle(Text("동아리"), displayMode: .inline)
                                .navigationBarItems(leading: Button(action: self.tabData.go_home) {
                                    HStack {
                                        Image(systemName: "chevron.left")
                                        Text("홈")
                                    }
                                }, trailing: EmptyView())
                            //}.accentColor(.white)
                        }
                        
                    }*/
                }.environmentObject(self.tabData)
                    .tabItem {  // 첫번째 탭에 해당되는 아이템 레이아웃
                        VStack {
                            VStack {
                                Image("home")
                                    .resizable()
                                    .renderingMode(.template)
                                    .font(.system(size: 20))
                                Text("홈")
                                    .font(.system(size: 15))
                                    .fontWeight(.medium)
                            }.frame(height: 60, alignment: .top)
                            
                            Spacer()
                        }
                }.tag(1)
                
                Text("Custom Action") // 임의의 뷰(아무 기능 없으며, 해당 탭 클릭시 ViewRouter에서 SideMenu를 여는 기능 작동)
                    .tabItem { // 두번째 탭에 해당되는 아이템 레이아웃
                        VStack {
                            VStack {
                                Image("menu")
                                    .resizable()
                                    .renderingMode(.template)
                                    .font(.system(size: 20))
                                Text("카테고리")
                                    .font(.system(size: 15))
                                    .fontWeight(.medium)
                            }.frame(height: 60, alignment: .top)
                            Spacer()
                        }
                }
                .tag(2)
                
                /*NavigationView { // 세번째 탭으로, 네비게이션 뷰를 통해 네이게이션 바를 생성해준다.
                    
                        
                            .navigationBarTitle(Text(""), displayMode: .inline)
                        
                    
                 }*/TestSearchView().environmentObject(self.tabData).environment(\.managedObjectContext, self.managedObjectContext)
                    .navigationBarTitle("", displayMode: .inline)
                    .tabItem { // 세번째 탭에 해당되는 아이템 레이아웃
                        VStack(spacing: 0) {
                            VStack{
                                Image(systemName: "magnifyingglass")
                                    .resizable()
                                    .renderingMode(.template)
                                    .font(.system(size: 20))
                                Text("검색")
                                    .font(.system(size: 15))
                                    .fontWeight(.medium)
                            }.frame(height: 60, alignment: .top)
                            Spacer()
                        }
                        
                        
                }.tag(3)
                
            }
            .font(.headline)
            //.edgesIgnoringSafeArea(.top)
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


