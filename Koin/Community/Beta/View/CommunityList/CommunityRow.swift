//
//  CommunityRow.swift
//  Koin
//
//  Created by 정태훈 on 2020/04/06.
//  Copyright © 2020 정태훈. All rights reserved.
//

import Foundation
import SwiftUI

struct CommunityRow<T: CommonArticle, C: CommonComment>: View{
    //@EnvironmentObject var user: UserSettings
    @EnvironmentObject var config: UserConfig
    @EnvironmentObject var parentViewModel: CommunityViewModel<T>
    let viewModel: CommunityRowViewModel<T>
    
    init(viewModel: CommunityRowViewModel<T>) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack{
            VStack(alignment: .leading) {
                HStack {
                    Text("\(viewModel.title)")
                        .font(.system(size: 16))
                        .foregroundColor(Color("black"))
                        .lineLimit(nil)
                    Text("(\(viewModel.commentCount))")
                        .font(.system(size: 16))
                        .foregroundColor(Color("light_navy"))
                }.padding(.vertical, 10)
                HStack {
                    Text("조회\(viewModel.hit) · \(viewModel.nickname)")
                        .font(.system(size: 12))
                        .foregroundColor(Color("warm_grey"))
                        .lineLimit(nil)
                    Spacer()
                    Text("\(viewModel.createdAt)")
                        .font(.system(size: 12))
                        .foregroundColor(Color("warm_grey"))
                }
            }
            NavigationLink(destination: CommunityDetailView<T,C>(viewModel: CommunityDetailViewModel(communityFetcher: CommunityFetcher(), token: self.config.token, articleId: viewModel.id, userId: -1)).onDisappear {
                if (T.self == Article.self) {
                    self.parentViewModel.fetchCommunity()
                } else {
                    self.parentViewModel.fetchTempCommunity()
                }
            }) {
                EmptyView()
            }
        }
        
    }
}
