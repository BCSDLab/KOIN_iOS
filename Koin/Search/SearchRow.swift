//
//  SearchRow.swift
//  Koin
//
//  Created by 정태훈 on 2020/05/01.
//  Copyright © 2020 정태훈. All rights reserved.
//

import SwiftUI

struct SearchRow: View {
    private let viewModel: SearchRowViewModel
    @EnvironmentObject var config: UserConfig
    
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(fetchRequest: RecentSearch.allRecentFetchRequest()) var recentSearch: FetchedResults<RecentSearch>
    
    init(viewModel: SearchRowViewModel) {
        self.viewModel = viewModel
    }
    
    var link: AnyView {
        switch self.viewModel.tableId {
            case 5:
            return AnyView(CommunityDetailView<Article,Comment>(viewModel: CommunityDetailViewModel(communityFetcher: CommunityFetcher(), token: self.config.token, articleId: viewModel.id, userId: -1)).navigationBarTitle(viewModel.title))
            case 7:
               return AnyView(
                    CommunityDetailView<TempArticle,TempComment>(viewModel: CommunityDetailViewModel(communityFetcher: CommunityFetcher(), token: self.config.token, articleId: viewModel.id, userId: -1)).navigationBarTitle(viewModel.title))
            case 10:
                return AnyView(
                    MarketDetailView(viewModel: MarketDetailViewModel(marketFetcher: MarketFetcher(), token: self.config.token, articleId: viewModel.id, userId: -1)).navigationBarTitle(viewModel.title))
            default:
            return AnyView(PrepareView())
        }
    }
    
    
    var body: some View {
        
        NavigationLink(destination: link) {
            
            Button(action: {
                
            }) {
                VStack(alignment: .leading) {
                    HStack{
                        Text("[\(viewModel.serviceName)]")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: 0x252525))
                            .fontWeight(.bold)
                        TextWithAttributedString(attributedString: self.viewModel.attributedTitle)
                        
                        Spacer()
                        if (viewModel.commentCount != 0) {
                            Text("(\(viewModel.commentCount))")
                                .font(.system(size: 14))
                                .foregroundColor(Color("light_navy"))
                        }
                    }.padding(.bottom, 6)
                    HStack {
                        Text("조회\(viewModel.hit) · \(viewModel.nickname)")
                            .font(.system(size: 13))
                            .foregroundColor(Color("warm_grey"))
                            .lineLimit(nil)
                        Spacer()
                        Text("\(viewModel.createdAt)")
                            .font(.system(size: 12))
                            .fontWeight(.light)
                            .foregroundColor(Color("warm_grey"))
                    }
                }.padding(.all, 6)
            }
            
        }
        
    }
}
