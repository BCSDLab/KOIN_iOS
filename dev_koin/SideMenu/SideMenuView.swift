//
// Created by 정태훈 on 2020/01/12.
// Copyright (c) 2020 정태훈. All rights reserved.
//

import Foundation
import SwiftUI


struct SideMenu: View {
    let width: CGFloat
    @EnvironmentObject var tabData: ViewRouter

    var body: some View {
        ZStack {
            GeometryReader { _ in
                EmptyView()
            }
                    .background(Color.gray.opacity(0.3))
                    .opacity(self.tabData.isCustomItemSelected ? 1.0 : 0.0)
                    .animation(Animation.easeIn.delay(0.25))
                    .edgesIgnoringSafeArea(.top)
                    .onTapGesture {
                        self.tabData.dismiss_menu()
                    }
            HStack {
                MenuContent()
                        .frame(width: self.width)
                        .background(Color.white)
                        .offset(x: self.tabData.isCustomItemSelected ? 0 : -self.width)
                        .animation(.default).edgesIgnoringSafeArea(.top)
                Spacer()
            }
        }
    }
}