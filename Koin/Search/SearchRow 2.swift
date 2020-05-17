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
    
    init(viewModel: SearchRowViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack{
                Text("[\(viewModel.serviceName)]")
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: 0x252525))
                    .fontWeight(.bold)
                Text(viewModel.title)
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: 0x252525))
                .lineLimit(1)
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
