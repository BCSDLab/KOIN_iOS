//
//  StoreDetailView.swift
//  dev_koin
//
//  Created by 정태훈 on 2020/01/15.
//  Copyright © 2020 정태훈. All rights reserved.
//
import SwiftUI
import SDWebImageSwiftUI
import PKHUD

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

struct ExpandImageView: View {
    @EnvironmentObject var ImageData: StoreController

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
                                    .animated() // Supports Animated Image
                                    .indicator(.activity) // Activity Indicator
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

struct StoreDetailView: View {
    @ObservedObject var controller: StoreController = StoreController()
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var store_id: Int
    
    init(store_id: Int) {
        self.store_id = store_id
        self.controller.load_store(store_id: self.store_id)
    }
    
    var body: some View {
        var storeName: String = "가게이름"
        var store_phone: String = "폰"
        var store_openTime: String = "오픈시간"
        var store_closeTime: String = "종료시간"
        var store_deliveryPrice: Int = 0
        var store_delivery: Bool = false
        var store_payCard: Bool = false
        var store_payBank: Bool = false
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
            store_payBank = info.payBank
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


        return ZStack{
            ExpandImageView().environmentObject(self.controller).zIndex(99)
            ScrollView(.vertical) {
                VStack(alignment: .leading) {
                    Text(storeName)
                        .font(.system(size: 28))
                            .fontWeight(.bold)
                        .padding(.vertical)
                    HStack {
                        Text("전화번호")
                            .fontWeight(.light)
                        Text(store_phone)
                                .foregroundColor(Color("warm_grey_two"))
                        .fontWeight(.light)
                    }.padding(.vertical, 3)
                    HStack {
                        Text("운영시간")
                        .fontWeight(.light)
                        Text("\(store_openTime) ~ \(store_closeTime)")
                                .foregroundColor(Color("warm_grey_two"))
                        .fontWeight(.light)
                    }.padding(.vertical, 3)
                    HStack {
                        Text("기타정보")
                        .fontWeight(.light)

                        VStack {
                            if (store_deliveryPrice != 0) {
                                Text("배달료 \(store_deliveryPrice)원")
                                    .fontWeight(.light)
                                        .foregroundColor(Color("warm_grey_two"))
                            }

                        }

                    }.padding(.vertical, 3)
                    HStack {
                        if store_delivery {
                            Text("#배달 가능")
                                    .font(.caption)
                                    .fontWeight(.light)
                                    .foregroundColor(.white)
                                    .padding(.all, 5)
                                    .background(RoundedRectangle(cornerRadius: 20).foregroundColor(Color("squash")))
                        }
                        if store_payCard {
                            Text("#카드 가능")
                                    .font(.caption)
                                    .fontWeight(.light)
                                    .foregroundColor(.white)
                                    .padding(.all, 5)
                                    .background(RoundedRectangle(cornerRadius: 20).foregroundColor(Color("squash")))
                        }
                        if store_payBank {
                            Text("#계좌이체 가능")

                                    .font(.caption)
                                    .fontWeight(.light)
                                    .foregroundColor(.white)
                                    .padding(.all, 5)
                                    .background(RoundedRectangle(cornerRadius: 20).foregroundColor(Color("squash")))

                        }

                    }.padding(.vertical, 10)

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
                                    .foregroundColor(Color.white)
                                    .padding(.all, 10)
                                    .background(Color("light_navy"))
                        }
                        Button(action: { self.presentationMode.wrappedValue.dismiss() }) {
                            Text("상점목록")
                                    .foregroundColor(Color.white)
                                    .padding(.all, 10)
                                    .background(Color("warm_grey_two"))
                        }
                    }.padding(.vertical, 10)

                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(store_images, id: \.self) { image in
                                WebImage(url: URL(string: image))
                                        .onSuccess { image, cacheType in
                                        }
                                        .resizable()
                                        .placeholder {
                                            Rectangle().foregroundColor(.gray)
                                        }
                                        .indicator(.activity)
                                        .onTapGesture {
                                            self.controller.open_image(image: image)
                                        }
                                        .animation(.easeInOut(duration: 0.5))
                                        .transition(.fade)
                                        .scaledToFit()
                                        .frame(height: 160, alignment: .center)
                                
                                        
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
                                        .frame(height: 160)

                            }
                            HStack {
                                Spacer()
                                Text("\(event.startDate) ~ \(event.endDate)")
                            }
                        }
                    }

                    VStack {
                        Text("메뉴")
                                .font(.title)
                                .padding(.bottom)
                        ForEach(store_menus, id: \.self) { menus in
                            StoreMenuCellView(menus: menus)
                        }
                    }
                            .navigationBarTitle(storeName)

                }.padding()
            }
            }.onAppear() {
                print("StoreDetailView Appeared")
            }.onDisappear() {
                print("StoreDetailView Disappeared")
            }
        }

}

struct StoreMenuCellView: View {

    let menus: Menus

    init(menus: Menus) {
        self.menus = menus
    }

    var body: some View {
        return HStack {
            Text(menus.name)
            Spacer()
            VStack {
                ForEach(menus.priceType, id: \.self) { price in
                    HStack {
                        if (price.size != "기본") {
                            Text(price.size)
                        }
                        Text(price.price)
                                .foregroundColor(Color("light_navy"))
                    }

                }
            }
        }.frame(maxWidth: .infinity)
                .padding()
                .overlay(
                        Rectangle()
                                .stroke(Color("menu_border"), lineWidth: 1)
                )
                .background(Color("white_two"))
                .padding([.vertical], 10)
                .clipped()
    }
}

struct StoreDetailView_Previews: PreviewProvider {
    static var previews: some View {
        StoreDetailView(store_id: 3)
        //40, 96
    }
}
