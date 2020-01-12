//
//  DiningFetcher.swift
//  dev_koin
//
//  Created by 정태훈 on 2020/01/02.
//  Copyright © 2020 정태훈. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import Alamofire

public class DiningFetcher: ObservableObject {
    @Published var meals = [DiningRequest]()
    
    init(date: Date) {
        meal_session(date: date)
    }
    
    func meal_session(date: Date){
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_kr")
        dateFormatter.dateFormat = "yyMMdd"

        let dateString:String = dateFormatter.string(from: date)

        Alamofire
        .request("http://api.koreatech.in/dinings?date=\(dateString)", method: .get, encoding: JSONEncoding.default)
        .response{ response in
            guard let data = response.data else { return }
            do {
                let decoder = JSONDecoder()
                if let loaded = try? decoder.decode([DiningRequest].self, from: data) {
                    self.meals = loaded
                    self.meals.reverse()
                } else { }
            } catch let error {

            }
        }
    }
    
  
    
}
