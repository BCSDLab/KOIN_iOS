//
//  RectGetter.swift
//  Koin
//
//  Created by 정태훈 on 2020/08/26.
//  Copyright © 2020 정태훈. All rights reserved.
//

import Foundation
import SwiftUI

struct RectGetter: View {
    @Binding var rect: CGRect
    @EnvironmentObject var tabData: ViewRouter
    
    var body: some View {
        GeometryReader { proxy in
            self.createView(proxy: proxy)
        }
    }
    
    func createView(proxy: GeometryProxy) -> some View {
        if(self.tabData.currentView == "timetable") {
            DispatchQueue.main.async {
                self.rect = proxy.frame(in: .global)
            }
        }
        
        return Rectangle().fill(Color.clear)
    }
}
