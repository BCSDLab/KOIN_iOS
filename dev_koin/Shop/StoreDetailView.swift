//
//  StoreDetailView.swift
//  dev_koin
//
//  Created by 정태훈 on 2020/01/15.
//  Copyright © 2020 정태훈. All rights reserved.
//

import SwiftUI
import SDWebImageSwiftUI

extension String{
    func getArrayAfterRegex(regex: String) -> [String] {
        
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: self,
                                        range: NSRange(self.startIndex..., in: self))
            return results.map {
                String(self[Range($0.range, in: self)!])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
}


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
        var store_event: [StoreEvent] = []
        var store_eventThumbnail: [String] = []
        var store_eventThumbnailType: String = ""
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
            if let eventArticles = info.eventArticles {
                for event in eventArticles {
                    var changed_event = event
                    changed_event.content = event.content.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
                    if let thumbnail = event.thumbnail {
                        store_eventThumbnail = [thumbnail]
                    } else {
                        let reg = "\"([^\"]+)\""
                        store_eventThumbnail = event.content.getArrayAfterRegex(regex: reg)
                    }
                    store_event.append(changed_event)
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
                ForEach(store_event, id: \.self) { event in
                VStack {
                        Text(event.eventTitle)
                    Text(event.content)
                    ForEach(store_eventThumbnail, id: \.self) { thumbnail in
                        WebImage(url: URL(string: thumbnail.replacingOccurrences(of: "\"", with: "")))
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
                    HStack {
                        Spacer()
                        Text("\(event.startDate) ~ \(event.endDate)")
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
        }.onAppear() {
            print("StoreDetailView Appeared")
        }.onDisappear() {
            print("StoreDetailView Disappeared")
        }
    }
}

struct StoreDetailView_Previews: PreviewProvider {
    static var previews: some View {
        StoreDetailView(store_id: 96)
        //40, 96
    }
}
