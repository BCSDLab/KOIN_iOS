//
//  BetaStoreDetailView.swift
//  Koin
//
//  Created by 정태훈 on 2020/05/19.
//  Copyright © 2020 정태훈. All rights reserved.
//

import SwiftUI
import SDWebImageSwiftUI

struct BetaStoreDetailView: View {
    @ObservedObject var viewModel: StoreDetailViewModel
    
    init(viewModel: StoreDetailViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {

        return ZStack{
            ZStack {
                GeometryReader { _ in
                    EmptyView()
                }
                .background(Color.black.opacity(0.5))
                .opacity(self.viewModel.showImage ? 1.0 : 0.0)
                GeometryReader { geometry in
                    if self.viewModel.showImage {
                        VStack(alignment: .center) {
                            HStack{
                                Spacer()
                                Button(action: {
                                    self.viewModel.showImage.toggle()
                                }) {
                                    Image(systemName: "xmark")
                                        .accentColor(.white)
                                        .frame(width: 24, height: 24)
                                }
                            }.padding(.all, 16)
                            Spacer()
                            HStack(alignment: .center) {
                                Spacer()
                                Button(action: {
                                    if (self.viewModel.images.count != 1) {
                                        if (self.viewModel.imageId == 0) {
                                            self.viewModel.imageId = self.viewModel.images.count - 1
                                        } else {
                                            self.viewModel.imageId -= 1
                                        }
                                    }
                                }) {
                                    Image(systemName: "chevron.left")
                                        .accentColor(.white)
                                        .frame(width: 24, height: 24)
                                }
                                Spacer()
                                WebImage(url: URL(string: self.viewModel.images[self.viewModel.imageId]))
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
                                    .frame(width: geometry.size.width - 100, alignment: .center)
                                
                                Spacer()
                                Button(action: {
                                    if (self.viewModel.images.count != 1) {
                                    if (self.viewModel.imageId == self.viewModel.images.count - 1) {
                                        self.viewModel.imageId = 0
                                    } else {
                                        self.viewModel.imageId += 1
                                    }
                                    }
                                }) {
                                    Image(systemName: "chevron.right")
                                        .accentColor(.white)
                                        .frame(width: 24, height: 24)
                                }
                                Spacer()
                            }
                            Spacer()
                        }
                    }
                    
                    
                }
            }.zIndex(99)
            ScrollView(.vertical) {
                VStack(alignment: .leading) {
                    Text(self.viewModel.name)
                        .font(.system(size: 20))
                        .fontWeight(.medium)
                        .padding(.vertical, 20)
                        .padding(.horizontal, 16)
                    
                    Group {
                        HStack(alignment: .top){
                            Text("전화번호")
                                .font(.system(size: 15))
                                .foregroundColor(Color("warm_grey_two"))
                            Text(self.viewModel.phone)
                                .font(.system(size: 15))
                                .foregroundColor(Color("black"))
                                .lineSpacing(6)
                        }.padding(.vertical, 6)
                            .padding(.horizontal, 16)
                        
                        HStack(alignment: .top){
                            Text("운영시간")
                                .font(.system(size: 15))
                                .foregroundColor(Color("warm_grey_two"))
                            Text("\(self.viewModel.openTime) ~ \(self.viewModel.closeTime)")
                                .font(.system(size: 15))
                                .foregroundColor(Color("black"))
                                .lineSpacing(6)
                        }.padding(.vertical, 6)
                            .padding(.horizontal, 16)
                        HStack(alignment: .top){
                            Text("주소정보")
                                .font(.system(size: 15))
                                .foregroundColor(Color("warm_grey_two"))
                            Text(self.viewModel.address)
                                .font(.system(size: 15))
                                .foregroundColor(Color("black"))
                                .lineSpacing(6)
                        }.padding(.vertical, 6)
                            .padding(.horizontal, 16)
                        HStack(alignment: .top){
                            Text("배달금액")
                                .font(.system(size: 15))
                                .foregroundColor(Color("warm_grey_two"))
                            Text("\(self.viewModel.deliveryPrice)원")
                                .font(.system(size: 15))
                                .foregroundColor(Color("black"))
                                .lineSpacing(6)
                        }.padding(.vertical, 6)
                            .padding(.horizontal, 16)
                        HStack(alignment: .top){
                            Text("기타정보")
                                .font(.system(size: 15))
                                .foregroundColor(Color("warm_grey_two"))
                            Text(self.viewModel.description)
                                .font(.system(size: 15))
                                .foregroundColor(Color("black"))
                                .lineSpacing(6)
                        }.padding(.vertical, 6)
                            .padding(.horizontal, 16)
                    }
                    
                    HStack {
                        if self.viewModel.isDelivery {
                            Text("#배달가능")
                                .font(.system(size: 13))
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .padding(.all, 5)
                                .background(RoundedRectangle(cornerRadius: 20).foregroundColor(Color("squash")))
                        }
                        if self.viewModel.isCard {
                            Text("#카드가능")
                                .font(.system(size: 13))
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .padding(.all, 5)
                                .background(RoundedRectangle(cornerRadius: 20).foregroundColor(Color("squash")))
                        }
                        if self.viewModel.isBank {
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
                                self.viewModel.phone.trimmingCharacters(in: dash)
                            
                            let formattedString = "tel://" + cleanString
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
                            ForEach(self.viewModel.images, id: \.self) { image in
                                WebImage(url: URL(string: image))
                                    .onSuccess { image, cacheType in
                                }
                                .resizable()
                                .placeholder {
                                    Rectangle().foregroundColor(.gray)
                                }
                                .indicator(.activity)
                                .onTapGesture {
                                    self.viewModel.showImage.toggle()
                                }
                                .animation(.easeInOut(duration: 0.5))
                                .transition(.fade)
                                .scaledToFit()
                                .frame(height: 150, alignment: .center)
                                
                                
                            }
                        }
                    }.padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .navigationBarTitle(self.viewModel.name)
                    
                    ForEach(self.viewModel.menuViewModel) { c in
                        StoreMenuRow(viewModel: c)
                            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16)).padding(.bottom, 8)
                            .padding(.horizontal, 16)
                    }

                }
            }
        }
    }
    
}

