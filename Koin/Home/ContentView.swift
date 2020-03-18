//
//  ContentView.swift
//  dev_koin
//
//  Created by 정태훈 on 2019/12/08.
//  Copyright © 2019 정태훈. All rights reserved.
//

import SwiftUI
import PKHUD

extension UIDevice {
    var hasNotch: Bool {
        print(UIApplication.shared.keyWindow?.safeAreaInsets.bottom)
        let bottom = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
        return bottom > 0
    }
}

extension UITabBar {
    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        super.sizeThatFits(size)
        var sizeThatFits = super.sizeThatFits(size)
        if UIDevice.current.hasNotch {
            sizeThatFits.height = 90
        } else {
            sizeThatFits.height = 56
        }
        
        return sizeThatFits
    }
}

struct ContentView: View {
    // 탭과 관련된 데이터를 가지고 있는 오브젝트
    @EnvironmentObject var tabData: ViewRouter
    // 유저와 관련된 데이터를 가지고 있는 오브젝트
    @EnvironmentObject var settings: UserSettings

    init() {
        // 네비게이션 바 색 설정
        UINavigationBar.appearance().barTintColor = UIColor(named: "light_navy")
        // 네비게이션 바 글자색 설정(흰색)
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
    }


    var body: some View {
        //현재 화면의 가로, 세로 넓이를 인식할 수 있게 해주는 뷰
        GeometryReader { geometry in
            // 레이어 맨 위에 SideMenu가 오도록 배치
            ZStack {
                // SideMenu의 가로 길이는 현재 화면의 2/3 차지할 수 있게
                SideMenu(width: geometry.size.width * 2 / 3)
            }.zIndex(99)

            // 탭 기능을 구현하게 해주는 뷰, selection에 따라 보여주는 뷰가 달라진다.
            TabView(selection: self.$tabData.itemSelected) {

                NavigationView { // 네비게이션 바를 만들어주는 뷰

                    if self.tabData.currentView == "home" { // 현재 뷰가 home이면 HomeView를 보여준다.
                        HomeView()
                                .navigationBarTitle("") //네비게이션바의 제목은 없고
                                .navigationBarHidden(true) //네비게이션바를 숨긴다.
                    } else if self.tabData.currentView == "dining" { // 현재 뷰가 dining이면 MealView를 보여준다.
                        MealView()
                                .navigationBarTitle("식단", displayMode: .inline) // 네비게이션바의 제목은 식단이며, 한줄로 표시
                                .navigationBarItems(leading: Button(action: self.tabData.go_home) { //네비게이션바 왼쪽엔 홈으로 가는 버튼을
                                    HStack {
                                        Image(systemName: "chevron.left")
                                        Text("홈")
                                    }
                                }, trailing: EmptyView()) //네비게이션바 오른쪽엔 아무것도 설정하지 않는다.
                    } else if self.tabData.currentView == "myinfo" { // 현재 뷰가 myinfo이면 MyInfoView를 보여준다.
                        MyInfoView()
                                .navigationBarTitle("내정보", displayMode: .inline) // 네비게이션바의 제목은 내정보이며, 한줄로 표시
                                .navigationBarItems(leading: Button(action: self.tabData.go_home) { //네비게이션바 왼쪽엔 홈으로 가는 버튼을
                                    HStack {
                                        Image(systemName: "chevron.left")
                                        Text("홈")
                                    }
                                }, trailing: NavigationLink(destination: EditUserView().environmentObject(self.settings)) { //네비게이션바 오른쪽엔 내정보를 수정할 수 있는 뷰로, 내정보 오브젝트랑 같이 이동한다.
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
                    } else if self.tabData.currentView == "board_free" {
                        CommunityList(board_id: 1)
                                .navigationBarTitle("자유게시판", displayMode: .inline)
                            .environmentObject(self.tabData)
                    } else if self.tabData.currentView == "board_recruit" {
                        CommunityList(board_id: 2)
                                .navigationBarTitle("취업게시판", displayMode: .inline)
                            .environmentObject(self.tabData)
                    } else if self.tabData.currentView == "board_secret" {
                        TempCommunityList()
                                .navigationBarTitle("익명게시판", displayMode: .inline)
                            .environmentObject(self.tabData)
                    }  else if self.tabData.currentView == "bus" {
                        BusView()
                                .navigationBarTitle("버스", displayMode: .inline)
                                .navigationBarItems(leading: Button(action: self.tabData.go_home) {
                                    HStack {
                                        Image(systemName: "chevron.left")
                                        Text("홈")
                                    }
                                }, trailing: EmptyView())
                    }
                }

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

                NavigationView { // 세번째 탭으로, 네비게이션 뷰를 통해 네이게이션 바를 생성해준다.
                    MyInfoView()
                            .navigationBarTitle("내정보", displayMode: .inline) // 네비게이션바의 제목은 내정보이며, 한줄로 표시
                            .navigationBarItems(leading: Button(action: self.tabData.go_home) { //네비게이션바 왼쪽엔 홈으로 가는 버튼을
                                HStack {
                                    Image(systemName: "chevron.left")
                                    Text("홈")
                                }
                            })
                }
                        .tabItem { // 세번째 탭에 해당되는 아이템 레이아웃
                            VStack(spacing: 0) {
                                VStack{
                                Image("info")
                                        .resizable()
                                        .renderingMode(.template)
                                        .font(.system(size: 20))
                                Text("내정보")
                                        .font(.system(size: 15))
                                        .fontWeight(.medium)
                                }.frame(height: 60, alignment: .top)
                                Spacer()
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


