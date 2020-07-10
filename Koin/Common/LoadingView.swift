//
//  LoadingView.swift
//  Koin
//
//  Created by 정태훈 on 2020/04/21.
//  Copyright © 2020 정태훈. All rights reserved.
//

import Foundation
import SwiftUI

struct LoadingView<Content>: View where Content: View {
    
    @Binding var isShowing: Bool
    var content: () -> Content
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                
                self.content()
                    .disabled(self.isShowing)
                    .blur(radius: self.isShowing ? 3 : 0)
                
                VStack {
                    LottieView(filename: "data")
                        .edgesIgnoringSafeArea(.all)
                }
                    .opacity(self.isShowing ? 1 : 0)
                
            }
        }
    }
    
}
