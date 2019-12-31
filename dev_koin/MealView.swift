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

func convertPrice(price:String) -> String {
    let formatter = NumberFormatter()
    formatter.locale = Locale.current
    formatter.numberStyle = .currency
    formatter.currencySymbol = ""
    formatter.numberStyle = .decimal
    if let intPrice = Int(price) {
        if let formattedPrice = formatter.string(from: intPrice as NSNumber) {
            return formattedPrice
        }
    }
    return price
}


//[data, type, place, priceCard, priceCash, kcal, menu]
struct MealView: View {
    @State private var selectedTab: Int = 0
    @ObservedObject var diningViewRouter = DiningViewRouter()
    
    var body: some View {
                
            VStack {
                VStack {
                    HStack{
                        Spacer()
                        Text("<")
                        Spacer()
                        Text("2020년 01월 01일")
                        Spacer()
                        Text(">")
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
                MenuView(menu_type: 0)
            } else if self.diningViewRouter.currentView == "lunch" {
                MenuView(menu_type: 1)
            } else if self.diningViewRouter.currentView == "dinner" {
                MenuView(menu_type: 2)
            }
            }.padding(.top, 20)
                
        
    }
}

struct MenuView: View {
    var menu_type: Int
    var meals: [[String]]
    init(menu_type: Int) {
        self.menu_type = menu_type
        self.meals = load_meal(menu_type: menu_type, date: Date())
    }
    var body: some View {
        List {
            VStack {
                ForEach(meals, id: \.self) {meal in
                    CardView(place: meal[2], priceCard: meal[3], priceCash: meal[4], kcal: meal[5], menu: meal[6])
                }
            }
        }
    }
}





struct CardView: View{
    var place: String
    var priceCard: String
    var priceCash: String
    var kcal: String
    var menu: String
    
    
    
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
                    Text("\(kcal)Kcal")
                    .font(.caption)
                    .foregroundColor(.secondary)
                        .padding(.bottom, 10)
                    
                    Text(menu)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(nil)
          
        }
                
                    .fixedSize(horizontal: false,vertical: true)
                    
                    .frame(maxWidth: .infinity)
                .padding()
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(.sRGB,red: 150/255, green: 150/255, blue: 150/255, opacity: 0.5), lineWidth: 1)
        )
        .padding([.top, .horizontal])
        
    }
 
    
}

func load_meal(menu_type: Int = 0, date: Date = Date()) -> [[String]] {
    // 0: breakfast, 1: lunch, 2: dinner
    meal_session(date: date)
    var breakfast: [[String]] = []
    var lunch: [[String]] = []
    var dinner: [[String]] = []
    
    if let data = UserDefaults.standard.object(forKey:"meal") as? Data {
        let decoder = JSONDecoder()
        if let loaded = try? decoder.decode([DiningRequest].self, from: data) {
            for i in loaded {
                var a: Array<String> = Array()
                var menu_type: String = ""
                if let diningDate = i.date {a.append(diningDate)} else{a.append("")}
                if let diningType = i.type {
                    menu_type = diningType
                    a.append(diningType)
                } else{a.append("")}
                if let diningPlace = i.place {a.append(diningPlace)} else{a.append("")}
                if let diningPriceCard = i.priceCard {a.append(String(diningPriceCard))} else{a.append("")}
                if let diningPriceCash = i.priceCash {a.append(String(diningPriceCash))} else{a.append("")}
                if let diningKcal = i.kcal {a.append(String(diningKcal))} else{a.append("")}
                if let diningMenu = i.menu {
                    let stringMenu = diningMenu.joined(separator: "\n")
                    a.append(stringMenu)
                } else{a.append("")}
                if menu_type == "BREAKFAST" {
                    breakfast.append(a)
                } else if menu_type == "LUNCH" {
                    lunch.append(a)
                } else if menu_type == "DINNER" {
                    dinner.append(a)
                }
                
            }
            if menu_type == 0 {
                return breakfast
            } else if menu_type == 1 {
                return lunch
            } else if menu_type == 2 {
                return dinner
            }
            
        }
    }
    return [[""]]
}

func meal_session(date: Date = Date()) {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyMMdd"
    let dateString:String = dateFormatter.string(from: date)
    
        Alamofire
            .request("http://api.koreatech.in/dinings?date=\(dateString)", method: .get, encoding: JSONEncoding.default)
            .response{ response in
                guard let data = response.data else { return }
                do {
                    UserDefaults.standard.set(data, forKey: "meal")
                } catch let error {
                    print(error)
                }
            }
}

struct MealView_Previews: PreviewProvider {
    static var previews: some View {
        MealView()
    }
}
