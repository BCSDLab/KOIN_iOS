//
// Created by 정태훈 on 2020/01/12.
// Copyright (c) 2020 정태훈. All rights reserved.
//

import Foundation
import SwiftUI
import PKHUD

struct MenuContent: View {
    // 유저 정보가 들어있는 오브젝트
    @EnvironmentObject var settings: UserSettings
    // 탭 정보가 들어있는 오브젝트
    @EnvironmentObject var viewRouter: ViewRouter

    init() {
        // 리스트의 구분선을 투명하게 변경
        UITableView.appearance().separatorColor = .clear
    }
    
    func prepare_project() {
        // 에러 HUD를 위한 임의의 뷰 객체
        let uiview = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 100))
        // 에러 HUD 내에서의 에러 문자 뷰 객체
        let yourLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
        yourLabel.center = CGPoint(x: uiview.frame.size.width  / 2,
        y: uiview.frame.size.height / 2)
        yourLabel.textAlignment = .center
        
        yourLabel.text = "서비스 준비중입니다."
        uiview.addSubview(yourLabel)
        PKHUD.sharedHUD.contentView = uiview
        PKHUD.sharedHUD.show()
        PKHUD.sharedHUD.hide(afterDelay: 1.0)
    }

    var body: some View {
        VStack {
            HStack {
                Text(self.settings.get_nickname())
                        .font(.system(size: 15))
                        .fontWeight(.medium)
                        .foregroundColor(Color("light_navy"))
                Text("님,안녕하세요!")
                        .font(.system(size: 13))
                        .foregroundColor(Color("light_navy"))
                Spacer()
                Image("img_menu_logo")
            }
                    .padding(.leading, CGFloat(20))
                    .padding(.trailing, CGFloat(20))
                    .padding(.top, CGFloat(50))
            List {
                /*
                HStack {
                    Image(systemName: "person")
                    Text("내정보")
                            .font(.subheadline)
                }.onTapGesture { // 내정보 누를 시
                    // 현재 view를 myinfo로 변경
                    self.viewRouter.currentView = "myinfo"
                    // 메뉴 닫음
                    self.viewRouter.dismiss_menu()
                }
*/
                Section(header:
                Text("학교정보")
                        .font(.system(size: 13))
                        .foregroundColor(Color("warm_grey_two"))) {
                    Text("주변 상점")
                            .font(.system(size: 15))
                            .foregroundColor(self.viewRouter.currentView == "store" ? Color("squash"): Color("black"))
                            .onTapGesture {
                                self.viewRouter.currentView = "store"
                                self.viewRouter.dismiss_menu()
                            }
                    Text("버스 / 교통")
                        .font(.system(size: 15))
                        .foregroundColor(self.viewRouter.currentView == "bus" ? Color("squash"): Color("black"))
                        .onTapGesture { // 식단 누를 시
                            // 현재 view를 dining으로 변경
                            self.viewRouter.currentView = "bus"

                            // 메뉴 닫음
                            self.viewRouter.dismiss_menu()
                        }
                    Text("식단")
                        .font(.system(size: 15))
                        .foregroundColor(self.viewRouter.currentView == "dining" ? Color("squash"): Color("black"))
                            .onTapGesture { // 식단 누를 시
                                // 현재 view를 dining으로 변경
                                self.viewRouter.currentView = "dining"

                                // 메뉴 닫음
                                self.viewRouter.dismiss_menu()
                            }

                    Text("동아리")
                        .font(.system(size: 15))
                        .foregroundColor(Color("black"))
                        .onTapGesture { // 식단 누를 시
                            // 현재 view를 dining으로 변경
                            self.prepare_project()

                            // 메뉴 닫음
                            self.viewRouter.dismiss_menu()
                        }
                }
                Section(header:
                Text("커뮤니티")
                        .font(.system(size: 13))
                        .foregroundColor(Color("warm_grey_two"))) {
                    Text("익명게시판")
                        .font(.system(size: 15))
                        .foregroundColor(self.viewRouter.currentView == "board_secret" ? Color("squash"): Color("black"))
                        .onTapGesture { // 식단 누를 시
                                                    // 현재 view를 dining으로 변경
                        self.viewRouter.currentView = "board_secret"
                        //board_recruit
                                                    // 메뉴 닫음
                        self.viewRouter.dismiss_menu()
                                                }
                    Text("자유게시판")
                        .font(.system(size: 15))
                        .foregroundColor(self.viewRouter.currentView == "board_free" ? Color("squash"): Color("black"))
                        .onTapGesture { // 식단 누를 시
                            // 현재 view를 dining으로 변경
                            self.viewRouter.currentView = "board_free"
//board_recruit
                            // 메뉴 닫음
                            self.viewRouter.dismiss_menu()
                        }
                    Text("취업게시판")
                        .font(.system(size: 15))
                        .foregroundColor(self.viewRouter.currentView == "board_recruit" ? Color("squash"): Color("black"))
                        .onTapGesture { // 식단 누를 시
                                                    // 현재 view를 dining으로 변경
                                                    self.viewRouter.currentView = "board_recruit"
                                                    // 메뉴 닫음
                                                    self.viewRouter.dismiss_menu()
                                                }
                    Text("분실물")
                        .font(.system(size: 15))
                        .foregroundColor(Color("black"))
                        .onTapGesture { // 식단 누를 시
                            // 현재 view를 dining으로 변경
                            self.prepare_project()

                            // 메뉴 닫음
                            self.viewRouter.dismiss_menu()
                        }
                    Text("중고장터")
                        .font(.system(size: 15))
                        .foregroundColor(Color("black"))
                        .onTapGesture { // 식단 누를 시
                            // 현재 view를 dining으로 변경
                            self.prepare_project()

                            // 메뉴 닫음
                            self.viewRouter.dismiss_menu()
                        }
                }
                Section(header:
                Text("고객지원")
                        .font(.system(size: 13))
                        .foregroundColor(Color("warm_grey_two"))) {
                    HStack {
                        Text("카카오톡 1:1 대화")
                                .font(.system(size: 15))
                                .foregroundColor(Color("black"))
                        Spacer()
                        Image("kakaotalk")
                                .renderingMode(.template)
                                .foregroundColor(.gray)
                                .opacity(0.5)
                    }.onTapGesture {
                        let url: NSURL = URL(string: "http://pf.kakao.com/_twMBd")! as NSURL

                        UIApplication.shared.open(url as URL)
                            }

                    HStack {
                        Text("만든이")
                                .font(.system(size: 15))
                                .foregroundColor(Color("black"))
                        Spacer()
                        Image("logo_white")
                            .renderingMode(.original)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 16)
                        .opacity(0.5)
                    }
                }
            }

        }
    }
}
