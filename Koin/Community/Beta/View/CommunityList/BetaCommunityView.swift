//
//  BetaCommunityView.swift
//  Koin
//
//  Created by 정태훈 on 2020/04/06.
//  Copyright © 2020 정태훈. All rights reserved.
//

import Foundation
import SwiftUI
import SwiftUIPullToRefresh



struct BetaCommunityView<T: CommonArticle, C: CommonComment>: View{
    @EnvironmentObject var tabData: ViewRouter
    //@EnvironmentObject var user: UserSettings
    @EnvironmentObject var config: UserConfig
    @ObservedObject var viewModel: CommunityViewModel<T>
    
    
    init(viewModel: CommunityViewModel<T>) {
        self.viewModel = viewModel
        
    }
    var body: some View {
        print(config.hasUser)
        return LoadingView(isShowing: self.$viewModel.progress) {
            List {
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
            }
        }
            // TempRichEditor(is_edit: false)
        .navigationBarItems(leading: Button(action: self.tabData.go_home) {
            HStack {
                Image(systemName: "chevron.left")
                Text("홈")
            }
            }, trailing: NavigationLink(destination: T.self == Article.self ? AnyView(RichEditor(is_edit: false, board_id: viewModel.boardId, token: self.config.token).onDisappear{
                self.viewModel.fetchCommunity()
            }) : AnyView(TempRichEditor(is_edit: false).environmentObject(self.viewModel).onDisappear{
                self.viewModel.fetchTempCommunity()
            })) {Text("작성")}.disabled(T.self == Article.self ? !self.config.hasUser : false)
                )
    }
    
    
}
