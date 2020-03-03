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
    //DiningRequest의 배열 형식(한식, 일품식, 능수관 등 다양한 식단이 포함되어있음)
    @Published var meals = [DiningRequest]()

    //클래스를 생성할 때, Date를 기준으로 dining 데이터를 가져온다.
    init(date: Date) {
        meal_session(date: date)
    }

    //dining 데이터 가져오는 함수
    func meal_session(date: Date) {
        //date 포맷 설정하는 오브젝트 불러오기
        let dateFormatter = DateFormatter()
        // 시간대 설정
        dateFormatter.locale = Locale(identifier: "ko_kr")
        // date 포맷 설정
        dateFormatter.dateFormat = "yyMMdd"
        // date 포맷에 맞춰 Date에서 String으로 변경
        let dateString: String = dateFormatter.string(from: date)

        // 데이터 라이브러리를 사용하여
        AF
                // 해당 날짜의 dining 데이터를 요청하고
        .request("http://api.koreatech.in/dinings?date=\(dateString)", method: .get, encoding: JSONEncoding.default)
                // response를 받으면
        .response { response in
            guard let data = response.data else {
                return
            } // response에서 데이터만 가져와서
            do {
                //JSON 디코더를 가져와서
                let decoder = JSONDecoder()
                // DiningRequest 클래스 형식에 맞게 데이터를 가공해주면
                if let loaded = try? decoder.decode([DiningRequest].self, from: data) {
                    //해당 값을 meals 함수에 넣어주고
                    self.meals = loaded
                    //한식이 맨 위, 2캠퍼스가 맨 아래로 가게 순서를 거꾸로 바꿔준다.
                    self.meals.reverse()
                } else {
                }
            } catch let error {

            }
        }
    }
    
  
    
}
