//
//  StoreMenuRow.swift
//  Koin
//
//  Created by 정태훈 on 2020/05/19.
//  Copyright © 2020 정태훈. All rights reserved.
//

import SwiftUI

struct StoreMenuRow: View {

    let viewModel: StoreMenuRowViewModel

    init(viewModel: StoreMenuRowViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        return HStack {
            Text(self.viewModel.name)
                    .font(.system(size: 15))
                    .fontWeight(.medium)
                    .foregroundColor(Color("black"))
            Spacer()
            VStack {
                ForEach(self.viewModel.priceType, id: \.self) { price in
                    HStack {
                        if (price.size != "기본") {
                            Text(price.size)
                                    .font(.system(size: 15))
                                    .fontWeight(.medium)
                                    .foregroundColor(Color("black"))
                                    .frame(width: 40, alignment: .leading)
                        }
                        Text("\(price.price)원")
                                .font(.system(size: 15))
                                .fontWeight(.medium)
                                .foregroundColor(Color("light_navy"))
                                .frame(width: 70, alignment: .trailing)
                    }.frame(width: 110, alignment: .trailing)

                }
            }
        }.padding(.horizontal, 16)
                .padding(.vertical, 24)
                .background(Color.white)
                .frame(maxWidth: .infinity)
                .border(Color("store_menu_border"))


    }
}
