//
//  CommunityView.swift
//  dev_koin
//
//  Created by 정태훈 on 2020/01/22.
//  Copyright © 2020 정태훈. All rights reserved.
//

import SwiftUI
import PKHUD

struct CommunityView: View {
    @ObservedObject var communityData: CommunityController
    
    init() {
        communityData = CommunityController()
        
    }
    
    var body: some View {
        List {
            ForEach(self.communityData.get_articles(), id:\.self) { l in
                VStack(alignment: .leading) {
                    HStack {
                        Text("\(l.title)")
                        Text(" (\(l.commentCount))")
                    }
                    HStack {
                        Text("조회\(l.hit).\(l.nickname)")
                        Spacer()
                        Text(l.createdAt)
                    }
                }
            }
        }.onAppear() {
            HUD.show(.progress)
            DispatchQueue.main.async {
                self.communityData.community_session()
                HUD.hide()
            }
            print("StoreView Appeared")
        }
    }
}

struct CommunityView_Previews: PreviewProvider {
    static var previews: some View {
        CommunityView()
    }
}
