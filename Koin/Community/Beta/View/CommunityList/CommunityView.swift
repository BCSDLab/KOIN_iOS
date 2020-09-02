//
//  BetaCommunityView.swift
//  Koin
//
//  Created by 정태훈 on 2020/04/06.
//  Copyright © 2020 정태훈. All rights reserved.
//

import Foundation
import SwiftUI
//import SwiftUIPullToRefresh
import PKHUD


struct CommunityView<T: CommonArticle, C: CommonComment>: View{
    @EnvironmentObject var config: UserConfig
    @EnvironmentObject var tabData: ViewRouter
    @ObservedObject var viewModel: CommunityViewModel<T>
    var boardId: Int = -1
    @State var isLoading: Bool = false
    
    
    init(boardId:Int) {
        self.boardId = boardId
        self.viewModel = CommunityViewModel(communityFetcher: CommunityFetcher(), boardId: boardId, userId:-1)
    }
    

    var body: some View {
        List{
            ForEach(self.viewModel.dataSource) { r in
                    CommunityRow<T,C>(viewModel: r).environmentObject(self.viewModel)
                        .onAppear{
                            if(r.id == self.viewModel.dataSource.last?.id) {
                                if (T.self == Article.self) {
                                    self.viewModel.reloadCommunity()
                                } else {
                                    self.viewModel.reloadTempCommunity()
                                }
                            }
                }
            }
        }.onPull(perform: {
            if (T.self == Article.self) {
                self.viewModel.fetchCommunity()
            } else {
                self.viewModel.fetchTempCommunity()
            }
        }, isLoading: self.isLoading)
            .onAppear {
                self.tabData.openLoading()
                if (T.self == Article.self) {
                    self.viewModel.fetchCommunity()
                } else {
                    self.viewModel.fetchTempCommunity()
                }
        }
        .onReceive(self.viewModel.result) { result in
            self.tabData.closeLoading()
            self.isLoading = false
        }
        .navigationBarTitle("커뮤니티", displayMode: .inline)
            .navigationBarItems(trailing: NavigationLink(destination: T.self == Article.self ? AnyView(RichEditor(is_edit: false, board_id: viewModel.boardId, token: self.config.token).onDisappear{
                    self.viewModel.fetchCommunity()
                }) : AnyView(TempRichEditor(is_edit: false).environmentObject(self.viewModel).onDisappear{
                    self.viewModel.fetchTempCommunity()
                })) {
                    Text("작성")
                        .foregroundColor(.white)
            }.disabled(T.self == TempArticle.self || T.self == Article.self && self.config.hasUser ? false : true)
        )
            
    }
    
    
}
