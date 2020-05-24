//
//  StoreRow.swift
//  Koin
//
//  Created by 정태훈 on 2020/05/19.
//  Copyright © 2020 정태훈. All rights reserved.
//

import SwiftUI

struct StoreRow: View {
    let viewModel: StoreRowViewModel

    init(viewModel: StoreRowViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        return NavigationLink(destination: BetaStoreDetailView(viewModel: StoreDetailViewModel(id: self.viewModel.id))) {
            HStack {
                Text(self.viewModel.storeName)
                        .font(.system(size: 15))
                        .fontWeight(.medium)
                        .foregroundColor(Color("black"))
                if (self.viewModel.isEvent) {
                    Image("event")
                            .renderingMode(.original)
                            .resizable()
                            .frame(width: 12, height: 17)
                }

                Spacer()
                HStack {
                    Text("배달")
                            .foregroundColor(self.viewModel.isDelivery ? Color("squash") : Color("cloudy_blue"))
                            .font(.system(size: 12))

                    Text("카드결제")
                            .foregroundColor(self.viewModel.isCard ? Color("squash") : Color("cloudy_blue"))
                            .font(.system(size: 12))

                    Text("계좌이체")
                            .foregroundColor(self.viewModel.isBank ? Color("squash") : Color("cloudy_blue"))
                            .font(.system(size: 12))
                }
            }.padding(.horizontal, 16)
                    .padding(.vertical, 24)
                    .background(Color.white)
                    .frame(maxWidth: .infinity)
                    .border(Color("cloudy_blue"))
        }.padding(.bottom, 8)
                .padding(.horizontal, 16)

    }
}
