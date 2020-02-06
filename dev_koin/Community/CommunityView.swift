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
    @ObservedObject var communityData = CommunityController()
    
    init() {
        self.communityData.community_session()
    }
    
    
    var body: some View {
        return List {
            ForEach(self.communityData.get_articles(), id:\.self) { l in
                NavigationLink(destination: CommunityDetailView(community_id: l.id)) {
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
            }, trailing: NavigationLink(destination: AddCommunityView().environmentObject(communityData)) { //네비게이션바 오른쪽엔 내정보를 수정할 수 있는 뷰로, 내정보 오브젝트랑 같이 이동한다.
            Text("추가")
        })

    }
}

struct CommunityView_Previews: PreviewProvider {
    static var previews: some View {
        CommunityView()
    }
}
