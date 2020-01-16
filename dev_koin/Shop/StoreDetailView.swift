//
//  StoreDetailView.swift
//  dev_koin
//
//  Created by 정태훈 on 2020/01/15.
//  Copyright © 2020 정태훈. All rights reserved.
//

import SwiftUI
import SDWebImageSwiftUI

struct StoreDetailView: View {
    @ObservedObject var controller: StoreController
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var store_id: Int
    
    init(store_id: Int) {
        self.store_id = store_id
        controller = StoreController(store_id: store_id)
    }
    
    var body: some View {
        var storeName: String = "가게이름"
        var store_phone: String = "폰"
        var store_openTime: String = "오픈시간"
        var store_closeTime: String = "종료시간"
        var store_deliveryPrice: Int = 0
        var store_delivery: Bool = false
        var store_payCard: Bool = false
        var store_menus: [Menus] = []
        var store_images: [String] = []
        if let info = self.controller.detail_store {
            storeName = info.name
            
            if let images = info.imageUrls {
                for image in images {
                    store_images.append(image)
                }
            }
            
            if let phone = info.phone {
                store_phone = phone
            }
            if let openTime = info.openTime {
                store_openTime = openTime
            }
            if let closeTime = info.closeTime {
                store_closeTime = closeTime
            }
            store_deliveryPrice = info.deliveryPrice
            store_delivery = info.delivery
            store_payCard = info.payCard
            if let menus = info.menus {
                for menu in menus {
                    store_menus.append(menu)
                }
            }
            
        }
        
        
        return ScrollView(.vertical){
            VStack(alignment: .leading) {
            Text(storeName).font(.title)
            HStack {
                Text("전화번호")
            Text(store_phone)

            }
            HStack {
                Text("운영시간")
            Text("\(store_openTime) ~ \(store_closeTime)")
            }
            HStack {
                Text("기타 정보")
                
                VStack {
                    Text("배달료 \(store_deliveryPrice)원")
                }

            }
            HStack {
                Text(store_delivery ? "배달 가능" : "배달 불가능")
                Text(store_payCard ? "카드 가능" : "카드 불가능")
            }
            HStack {
                Spacer()
                Button(action: {

                    // validation of phone number not included
                    let dash = CharacterSet(charactersIn: "-")

                    let cleanString =
                    store_phone.trimmingCharacters(in: dash)

                    let tel = "tel://"
                    let formattedString = tel + cleanString
                    let url: NSURL = URL(string: formattedString)! as NSURL

                    UIApplication.shared.open(url as URL)

                }) {
                    Text("전화하기")
                }
                Button(action: {self.presentationMode.wrappedValue.dismiss()}) {
                    Text("상점목록")
                }
            }
            
            ScrollView(.horizontal){
            HStack{
            ForEach(store_images, id: \.self) { image in
                WebImage(url: URL(string: image))
                .onSuccess { image, cacheType in
                    // Success
                }
                .resizable() // Resizable like SwiftUI.Image
                .placeholder(Image(systemName: "photo")) // Placeholder Image
                // Supports ViewBuilder as well
                .placeholder {
                    Rectangle().foregroundColor(.gray)
                }
                .animated() // Supports Animated Image
                .indicator(.activity) // Activity Indicator
                .animation(.easeInOut(duration: 0.5)) // Animation Duration
                .transition(.fade) // Fade Transition
                .scaledToFit()
                .frame(width: 300, height: 300, alignment: .center)
            }
            }
            }
            

                VStack{
            ForEach(store_menus, id: \.self) { menus in
                HStack{
                Text(menus.name)
                    Spacer()
                    VStack {
                    ForEach(menus.priceType, id: \.self) { price in
                        HStack {
                            Text(price.size)
                        Text(price.price)
                        }
                        
                        }
                    }
                }
            }
                }
            

        }
        }
    }
}

struct StoreDetailView_Previews: PreviewProvider {
    static var previews: some View {
        StoreDetailView(store_id: 2)
    }
}
