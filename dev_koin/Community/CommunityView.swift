//
//  CommunityView.swift
//  dev_koin
//
//  Created by 정태훈 on 2020/01/22.
//  Copyright © 2020 정태훈. All rights reserved.
//

import SwiftUI
import PKHUD

func dateToString(string_date: String) -> String {
    let dateFormat = DateFormatter()
    dateFormat.dateFormat = "yyyy-MM-dd HH:mm:ss"
    let date = dateFormat.date(from: string_date)
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy.MM.dd"
    let dateString = dateFormatter.string(from: date!)
    return dateString
}

struct TempCommunityList: View {
    @EnvironmentObject var tabData: ViewRouter
    @EnvironmentObject var user: UserSettings
    @ObservedObject var communityData:CommunityController
    
    init() {
        self.communityData = CommunityController(board_id: -2)
        self.communityData.temp_community_session()
        print(self.communityData.temp_articles)
    }
    
    var body: some View {
        var temp_rich_editor = TempRichEditor(is_edit: false)
                return List {
                ForEach(self.communityData.get_temp_articles(), id:\.self) { l in
                    // communitydetailview 방식 변경
                    NavigationLink(destination: CommunityDetailView(community_id: l.id)) {
                        VStack(alignment: .leading) {
                            HStack {
                                Text("\(l.title)")
                                Text("(\(l.commentCount ?? 0))")
                                .foregroundColor(Color("light_navy"))
                            }
                            HStack {
                                Text("조회\(l.hit)·\(l.nickname)")
                                    .foregroundColor(Color("warm_grey"))
                                Spacer()
                                Text(dateToString(string_date: l.createdAt))
                                    .foregroundColor(Color("warm_grey"))
                            }
                        }
                    }.onAppear {
                        if l == self.communityData.get_temp_articles().last && self.communityData.get_temp_articles().count != 1 {
                            self.communityData.reload_temp_articles()
                    }
                    }
                    
                }
            }.onAppear() {
                print("CommunityView Appeared")
            }.navigationBarItems(leading: Button(action: self.tabData.go_home) {
                HStack {
                    Image(systemName: "chevron.left")
                    Text("홈")
                }
                }, trailing: NavigationLink(destination:
                    temp_rich_editor
                    )
                    { //네비게이션바 오른쪽엔 내정보를 수정할 수 있는 뷰로, 내정보 오브젝트랑 같이 이동한다.
                Text("추가")
            })
        }
}

struct CommunityList: View {
    @EnvironmentObject var tabData: ViewRouter
    @EnvironmentObject var user: UserSettings
    @ObservedObject var communityData:CommunityController
    var board_id: Int
    init(board_id: Int) {
        self.board_id = board_id
        self.communityData = CommunityController(board_id: board_id)
        self.communityData.community_session()
        print(self.communityData.articles)
    }
    
    var body: some View {
        return List {
            ForEach(self.communityData.get_articles(), id:\.self) { l in
                NavigationLink(destination: CommunityDetailView(community_id: l.id, board_id: self.board_id, user_id: l.userId!)) {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("\(l.title)")
                            Text("(\(l.commentCount))")
                            .foregroundColor(Color("light_navy"))
                        }
                        HStack {
                            Text("조회\(l.hit)·\(l.nickname)")
                                .foregroundColor(Color("warm_grey"))
                            Spacer()
                            Text(dateToString(string_date: l.createdAt))
                                .foregroundColor(Color("warm_grey"))
                        }
                    }
                }.onAppear {
                    if l == self.communityData.get_articles().last && self.communityData.get_articles().count != 1 {
                        self.communityData.reload_articles()
                }
                }
                
            }
        }.onAppear() {
            print("CommunityView Appeared")
        }.navigationBarItems(leading: Button(action: self.tabData.go_home) {
            HStack {
                Image(systemName: "chevron.left")
                Text("홈")
            }
            }, trailing: NavigationLink(destination: RichEditor(is_edit: false, board_id: self.board_id, token: self.user.get_token()))
            //NavigationLink(destination: AddCommunityView(board_id: self.board_id).environmentObject(self.communityData)
             { //네비게이션바 오른쪽엔 내정보를 수정할 수 있는 뷰로, 내정보 오브젝트랑 같이 이동한다.
            Text("추가")
        })
    }
}


struct CommunityView: View {
    @EnvironmentObject var tabData: ViewRouter
    @EnvironmentObject var user: UserSettings
    
    var board_id: Int
    //board_id == -2 temp로 작업되게
    init(board_id: Int) {
        print(board_id)
        self.board_id = board_id
    }
    
    
    var body: some View {
            if (self.board_id == -2) {
                return AnyView(TempCommunityList())
            }else {
                print("open communityList")
                return AnyView(CommunityList(board_id: self.board_id))
        }
        

    }
}

struct CommunityView_Previews: PreviewProvider {
    static var previews: some View {
        CommunityView(board_id: -2)
    }
}
