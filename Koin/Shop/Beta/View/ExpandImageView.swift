//
//  ExpandImageView.swift
//  Koin
//
//  Created by 정태훈 on 2020/05/21.
//  Copyright © 2020 정태훈. All rights reserved.
//

import SwiftUI
import SDWebImageSwiftUI

/*
struct ExpandImageView: View {
    @EnvironmentObject var ImageData: StoreController
    var index: Int = 0
    
    var body: some View {
        ZStack {
            GeometryReader { _ in
                EmptyView()
            }
            .background(Color.gray.opacity(0.3))
            .opacity(self.ImageData.isImageClicked ? 1.0 : 0.0)
            .onTapGesture {
                self.ImageData.dismiss_image()
            }
            GeometryReader { geometry in
                if self.ImageData.isImageClicked {
                    VStack(alignment: .center) {
                        Spacer()
                        HStack(alignment: .center) {
                            Spacer()
                            WebImage(url: URL(string: self.ImageData.expandImage))
                                .onSuccess { image, cacheType in
                                    // Success
                            }
                                .resizable() // Resizable like SwiftUI.Image
                                .placeholder(Image(systemName: "photo")) // Placeholder Image
                                // Supports ViewBuilder as well
                                .placeholder {
                                    Rectangle().foregroundColor(.gray)
                            }
                                .animation(.easeInOut(duration: 0.5)) // Animation Duration
                                .transition(.fade) // Fade Transition
                                .scaledToFit()
                                .frame(width: geometry.size.width - 50, alignment: .center)
                                .onTapGesture {
                                    self.ImageData.dismiss_image()
                            }
                            
                            
                            Spacer()
                        }
                        Spacer()
                    }
                }
                
                
            }
        }
    }
}
*/
