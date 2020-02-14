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


struct CommunityView: View {
    @EnvironmentObject var tabData: ViewRouter
    @EnvironmentObject var user: UserSettings
    @ObservedObject var communityData:CommunityController
    var board_id: Int
    //board_id == -2 temp로 작업되게
    init(board_id: Int) {
        print(board_id)
        self.communityData = CommunityController(board_id: board_id)
        self.board_id = board_id
        if(board_id == -2) {
            self.communityData.temp_community_session()
        } else {
            self.communityData.community_session()
        }
        
    }
    
    
    var body: some View {
        return Group {
            if self.board_id == -2 {
                List {
                    ForEach(self.communityData.get_temp_articles(), id:\.self) { l in
                        // communitydetailview 방식 변경
                        NavigationLink(destination: CommunityDetailView(community_id: l.id)) {
                            VStack(alignment: .leading) {
                                HStack {
                                    Text("\(l.id)")
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
                    }, trailing: NavigationLink(destination: AddCommunityView(board_id: self.board_id).environmentObject(communityData)) { //네비게이션바 오른쪽엔 내정보를 수정할 수 있는 뷰로, 내정보 오브젝트랑 같이 이동한다.
                    Text("추가")
                })
            } else {
                List {
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
                    }, trailing: NavigationLink(destination: AddCommunityView(board_id: self.board_id).environmentObject(communityData)) { //네비게이션바 오른쪽엔 내정보를 수정할 수 있는 뷰로, 내정보 오브젝트랑 같이 이동한다.
                    Text("추가")
                })
            }
        }

    }
}

struct CommunityView_Previews: PreviewProvider {
    static var previews: some View {
        CommunityView(board_id: -2)
    }
}
