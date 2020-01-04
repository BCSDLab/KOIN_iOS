//
//  MealView.swift
//  dev_koin
//
//  Created by 정태훈 on 2019/12/29.
//  Copyright © 2019 정태훈. All rights reserved.
//

import SwiftUI
import Alamofire
import ObjectMapper
import AlamofireObjectMapper

struct MealView: View {
    @ObservedObject var diningViewRouter = DiningViewRouter()
    @ObservedObject var observed = DiningFetcher(date: Date())
    @State var date: Date = Date()
    @State var dateString: String = dateToString(date: Date())
    
    init() {
      UITableView.appearance().separatorColor = .clear
    }
    
    var body: some View {
            VStack {
                VStack {
                    HStack{
                        Spacer()
                        Text("<").onTapGesture {
                            self.date = Date(timeInterval: -86400, since: self.date)
                            self.dateString = dateToString(date: self.date)
                            self.observed.meal_session(date: self.date)
                        }
                        Spacer()
                        Text(dateString)
                        Spacer()
                        Text(">").onTapGesture {
                            self.date = Date(timeInterval: 86400, since: self.date)
                            self.dateString = dateToString(date: self.date)
                            self.observed.meal_session(date: self.date)
                        }
                        Spacer()
                    }.padding(.bottom, 40)
                HStack {
                Spacer()
                Text("아침").onTapGesture {
                        self.diningViewRouter.currentView = "breakfast"
                    }
                    .foregroundColor(self.diningViewRouter.currentView == "breakfast" ? .blue : Color.black.opacity(0.7))
                    .accentColor(self.diningViewRouter.currentView == "breakfast" ? .blue : Color.black.opacity(0.7))
                Spacer()
                Text("점심").onTapGesture {
                    self.diningViewRouter.currentView = "lunch"
                }
                .foregroundColor(self.diningViewRouter.currentView == "lunch" ? .blue : Color.black.opacity(0.7))
                .accentColor(self.diningViewRouter.currentView == "lunch" ? .blue : Color.black.opacity(0.7))
                Spacer()
                    Text("저녁").onTapGesture {
                        self.diningViewRouter.currentView = "dinner"
                    }
                    .foregroundColor(self.diningViewRouter.currentView == "dinner" ? .blue : Color.black.opacity(0.7))
                    .accentColor(self.diningViewRouter.currentView == "dinner" ? .blue : Color.black.opacity(0.7))
                    Spacer()
                }
                }
                
            if self.diningViewRouter.currentView == "breakfast" {
                MenuView(menu_type: 0, observed: self.observed)
            } else if self.diningViewRouter.currentView == "lunch" {
                MenuView(menu_type: 1, observed: self.observed)
            } else if self.diningViewRouter.currentView == "dinner" {
                MenuView(menu_type: 2, observed: self.observed)
            }
            }.padding(.top, 20)
        .navigationBarTitle(Text("식단"), displayMode: .inline)
        .onAppear {
            print("MealView appeared!")
        }.onDisappear {
            print("MealView disappeared!")
        }
                
        
    }
}

// 0: BREAKFAST, 1: LUNCH, 2: DINNER
struct MenuView: View {
    var menu_type: Int
    let menu_switch: Array<String> = ["BREAKFAST", "LUNCH", "DINNER"]
    @ObservedObject var observed: DiningFetcher
    
    var body: some View {
        List {
            
            ForEach(observed.meals) { meal in
                if(meal.type == self.menu_switch[self.menu_type]) {
                    CardView(place: meal.place, priceCard: meal.priceCard, priceCash: meal.priceCash, kcal: meal.kcal, menu: meal.menu)
                }
            }
            
        }
    }
}





struct CardView: View{
    var place: String
    var priceCard: Int?
    var priceCash: Int?
    var kcal: Int?
    var menu: [String]
    
    
    
    var body: some View{
                VStack(alignment: .leading){
                    HStack {
                        Text(place)
                        .font(.headline)
                            .fontWeight(.medium)
                        .foregroundColor(.primary)
                        Spacer()
                        Text("캐시비 \(convertPrice(price: priceCard))원 / 현금 \(convertPrice(price: priceCash))원")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                    Divider()
                        .foregroundColor(Color("squash"))
                    Text("\(convertPrice(price: kcal))Kcal")
                    .font(.caption)
                    .foregroundColor(.secondary)
                        .padding(.bottom, 10)
                    
                    Text(menu.joined(separator: "\n"))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(nil)
          
        }
                
                    .fixedSize(horizontal: false,vertical: true)
                    
                    .frame(maxWidth: .infinity)
                .padding()
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 1)
                .stroke(Color(.sRGB,red: 150/255, green: 150/255, blue: 150/255, opacity: 0.5), lineWidth: 0.7)
        )
        .padding([.top, .horizontal])
        
    }
 
    
}

func dateToString(date: Date)->String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy년 MM월 dd일"
    let dateString = dateFormatter.string(from: date)
    return dateString
}

func convertPrice(price:Int?) -> String {
    //let stringPrice: String
    let formatter = NumberFormatter()
    formatter.locale = Locale.current
    formatter.numberStyle = .currency
    formatter.currencySymbol = ""
    formatter.numberStyle = .decimal
    
    
    if let intPrice = price {
        if let formattedPrice = formatter.string(from: intPrice as NSNumber) {
            return formattedPrice
        }
    }
    
    return "0"
}

struct MealView_Previews: PreviewProvider {
    static var previews: some View {
        MealView()
    }
}
