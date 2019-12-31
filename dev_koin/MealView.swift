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


//[data, type, place, priceCard, priceCash, kcal, menu]
struct MealView: View {
    var meals: [[String]] = load_meal()
    
    var body: some View {
        NavigationView{
    /*
            HStack{
                Button(action: {}) {
                    Text("아침")
                }
                Spacer()
                Button(action: {}) {
                    Text("점심")
                }
                Spacer()
                Button(action: {}) {
                    Text("저녁")
                }
            }.frame(minWidth: 120, idealWidth: 150,maxWidth: 180)
            */
            List {
                VStack {
                    ForEach(meals, id: \.self) {meal in
                        CardView(place: meal[2], priceCard: meal[3], priceCash: meal[4], kcal: meal[5], menu: meal[6])
                    }
                }
            }
            
            
            
            
            
            
        }.navigationBarTitle("식단")
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
                        Text("캐시비 \(priceCard)원 / 현금 \(priceCash)원")
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
