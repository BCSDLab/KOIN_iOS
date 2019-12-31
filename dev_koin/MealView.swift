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
            NavigationView{
                
            VStack {
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
                
                
            if self.diningViewRouter.currentView == "breakfast" {
                BreakfastView()
            } else if self.diningViewRouter.currentView == "lunch" {
                Text("lunch")
            } else if self.diningViewRouter.currentView == "dinner" {
                Text("dinner")
            }
            }
            }
        
    }
}

struct BreakfastView: View {
    var meals: [[String]] = load_meal()
    
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

func load_meal(date: Date = Date()) -> [[String]] {
    meal_session(date: date)
    var t: [[String]] = []
    
    if let data = UserDefaults.standard.object(forKey:"meal") as? Data {
        let decoder = JSONDecoder()
        if let loaded = try? decoder.decode([DiningRequest].self, from: data) {
            for i in loaded {
                var a: Array<String> = Array()
                if let data = i.data {a.append(data)} else{a.append("")}
                if let type = i.type {a.append(type)} else{a.append("")}
                if let place = i.place {a.append(place)} else{a.append("")}
                if let priceCard = i.priceCard {a.append(String(priceCard))} else{a.append("")}
                if let priceCash = i.priceCash {a.append(String(priceCash))} else{a.append("")}
                if let kcal = i.kcal {a.append(String(kcal))} else{a.append("")}
                if let menu = i.menu {
                    let stringMenu = menu.joined(separator: "\n")
                    a.append(stringMenu)
                } else{a.append("")}
                t.append(a)
            }
            return t
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
