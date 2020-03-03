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
        var store_address: String = ""
        var store_description: String = ""
        if let info = self.controller.detail_store {
            storeName = info.name

            if let images = info.imageUrls {
                for image in images {
                    store_images.append(image)
                }
            }
            if let description = info.description {
                store_description = description
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
            if let address = info.address {
                store_address = address
            }
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
let a = ["전화번호","운영시간","주소정보","배달금액", "기타정보"]
let b = [store_phone, "\(store_openTime) ~ \(store_closeTime)", store_address, "\(store_deliveryPrice)원", store_description]

        return ZStack{
            ExpandImageView().environmentObject(self.controller).zIndex(99)
            ScrollView(.vertical) {
                VStack(alignment: .leading) {
                    Text(storeName)
                        .font(.system(size: 20))
                        .fontWeight(.medium)
                        .padding(.vertical, 20)
                        .padding(.horizontal, 16)
                    
                    ForEach(0 ..< 5) { i in
                        HStack(alignment: .top){
                            Text(a[i])
                                .font(.system(size: 15))
                                .foregroundColor(Color("warm_grey_two"))
                            Text(b[i])
                                .font(.system(size: 15))
                                .foregroundColor(Color("black"))
                                .lineSpacing(6)
                        }.padding(.vertical, 6)
                        .padding(.horizontal, 16)
                    }
                    
                    HStack {
                        if store_delivery {
                            Text("#배달가능")
                                    .font(.system(size: 13))
                                    .fontWeight(.medium)
                                    .foregroundColor(.white)
                                    .padding(.all, 5)
                                    .background(RoundedRectangle(cornerRadius: 20).foregroundColor(Color("squash")))
                        }
                        if store_payCard {
                            Text("#카드가능")
                                    .font(.system(size: 13))
                                    .fontWeight(.medium)
                                    .foregroundColor(.white)
                                    .padding(.all, 5)
                                    .background(RoundedRectangle(cornerRadius: 20).foregroundColor(Color("squash")))
                        }
                        if store_payBank {
                            Text("#계좌이체가능")
                                    .font(.system(size: 13))
                                    .fontWeight(.medium)
                                    .foregroundColor(.white)
                                    .padding(.all, 5)
                                    .background(RoundedRectangle(cornerRadius: 20).foregroundColor(Color("squash")))

                        }

                    }.padding(.vertical, 10)
                    .padding(.horizontal, 16)

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
                                .font(.system(size: 15))
                                .fontWeight(.medium)
                                .frame(width: 88, height: 36, alignment: .center)
                                    .foregroundColor(Color.white)
                                    .background(Color("light_navy"))
                        }
                    }.padding(.all, 16)
                    
                    HStack {
                        Text("메뉴소개")
                            .fontWeight(.medium)
                            .padding(.leading)
                            .foregroundColor(Color("warm_grey"))
                        .font(.system(size: 15))
                        Spacer()
                    }.frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color("store_list_title"))

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
                                        .frame(height: 150, alignment: .center)
                                
                                        
                            }
                        }
                    }.padding(.horizontal, 16)
                        .padding(.vertical, 8)
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
                                        .frame(height: 150)

                            }
                            HStack {
                                Spacer()
                                Text("\(event.startDate) ~ \(event.endDate)")
                            }
                        }
                    }

                    VStack {
                        ForEach(store_menus, id: \.self) { menus in
                            StoreMenuCellView(menus: menus)
                        }
                    }
                            .navigationBarTitle(storeName)

                }//.padding()
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
                .font(.system(size: 15))
                .fontWeight(.medium)
                .foregroundColor(Color("black"))
            Spacer()
            VStack {
                ForEach(menus.priceType, id: \.self) { price in
                    HStack {
                        if (price.size != "기본") {
                            Text(price.size)
                        }
                        Spacer()
                        Text(price.price)
                                .font(.system(size: 15))
                                .fontWeight(.medium)
                                .foregroundColor(Color("light_navy"))
                    }.frame(width: 100, alignment: .trailing)

                }
            }
        }.frame(maxWidth: .infinity)
            
                .padding()
                .overlay(
                        Rectangle()
                                .stroke(Color("store_menu_border"), lineWidth: 1)
                )
            .background(Color.white)
            .padding(.horizontal, 16.5)
                .padding(.vertical, 10)
                .clipped()
    }
}

struct StoreDetailView_Previews: PreviewProvider {
    static var previews: some View {
        StoreDetailView(store_id: 3)
    }
}
