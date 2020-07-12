//
//  MealView.swift
//  dev_koin
//
//  Created by 정태훈 on 2019/12/29.
//  Copyright © 2019 정태훈. All rights reserved.
//

import SwiftUI
import Alamofire

struct MealView: View {
    //정 선택된 탭을 가져오는 오브젝트
    @ObservedObject var diningViewRouter = DiningViewRouter()
    // 식단 정보를 가져오는 오브젝트
    @ObservedObject var observed = DiningFetcher(date: Date())
    // 날짜 정보를 가지고 있는 변수(어제 또는 다음 식단으로 이동, 시간대를 확인할 때 사용)
    @State var date: Date = Date()
    // 날짜 정보를 출력하기 위해 만든 변수(Date -> String)
    @State var dateString: String = dateToString(date: Date())
    
    @EnvironmentObject var tabData: ViewRouter
    
    init() {
        // List의 separator 색을 투명하게 만들어줌
        UITableView.appearance().separatorColor = .clear
    }
    
    var body: some View {
        // 오른쪽, 왼쪽으로 드래그하는 것을 인식하는 오브젝트
        let drag = DragGesture()
                .onEnded {  // 드래그가 종료될 때
                    if $0.translation.width > 100 {  // 오른쪽으로 100만큼 이동했다면
                        // 날짜를 어제로 바꾸기
                        self.date = Date(timeInterval: -86400, since: self.date)
                        // 그 값을 String으로 바꿔주기
                        self.dateString = dateToString(date: self.date)
                        // 어제의 식단 데이터를 불러오기
                        self.observed.meal_session(date: self.date)
                        print(self.observed.meals)
                    } else if $0.translation.width < -100 { // 왼쪽으로 100만큼 이동했다면
                        // 날짜를 내일로 바꾸기
                        self.date = Date(timeInterval: 86400, since: self.date)
                        // 그 값을 String으로 바꿔주기
                        self.dateString = dateToString(date: self.date)
                        // 내일의 식단 데이터를 불러오기
                        self.observed.meal_session(date: self.date)
                        print(self.observed.meals)
                    }
        }
        
        return VStack {
            VStack {
                HStack {
                    
                    Image(systemName: "chevron.left").onTapGesture { // 왼쪽 화살표를 클릭시
                        // 날짜를 어제로 바꾸기
                        self.date = Date(timeInterval: -86400, since: self.date)
                        // 그 값을 String으로 바꿔주기
                        self.dateString = dateToString(date: self.date)
                        // 어제의 식단 데이터를 불러오기
                        self.observed.meal_session(date: self.date)
                    }.padding(.leading, 52)
                    Spacer()
                    Text(dateString)
                        .font(.system(size: 15, weight: .medium))
                    Spacer()
                    Image(systemName: "chevron.right").onTapGesture { //오른쪽 화살표를 클릭 시
                        //날짜를 내일로 바꾸기
                        self.date = Date(timeInterval: 86400, since: self.date)
                        // 그 값을 String으로 바꿔주기
                        self.dateString = dateToString(date: self.date)
                        // 내일의 식단 데이터를 불러오기
                        self.observed.meal_session(date: self.date)
                    }.padding(.trailing, 52)
                    
                }.padding(.bottom, 30)
                HStack(alignment: .center, spacing: 40) {
                    Spacer()
                    Text("아침")
                        .font(.system(size: 15, weight: .regular))
                        .onTapGesture { //이 탭을 누르면
                            //선택된 탭을 "breakfast"로 변경
                            self.diningViewRouter.currentView = "breakfast"
                    }
                    .foregroundColor(self.diningViewRouter.currentView == "breakfast" ? Color("squash") : Color.black.opacity(0.7))
                    .accentColor(self.diningViewRouter.currentView == "breakfast" ? Color("squash") : Color.black.opacity(0.7))
                    
                    Text("점심")
                        .font(.system(size: 15, weight: .regular))
                        .onTapGesture { //이 탭을 누르면
                            //선택된 탭을 "lunch"로 변경
                            self.diningViewRouter.currentView = "lunch"
                    }
                    .foregroundColor(self.diningViewRouter.currentView == "lunch" ? Color("squash") : Color.black.opacity(0.7))
                    .accentColor(self.diningViewRouter.currentView == "lunch" ? Color("squash") : Color.black.opacity(0.7))
                    
                    Text("저녁")
                        .font(.system(size: 15, weight: .regular))
                        .onTapGesture {//이 탭을 누르면
                            //선택된 탭을 "dinner"로 변경
                            self.diningViewRouter.currentView = "dinner"
                    }
                    .foregroundColor(self.diningViewRouter.currentView == "dinner" ? Color("squash") : Color.black.opacity(0.7))
                    .accentColor(self.diningViewRouter.currentView == "dinner" ? Color("squash") : Color.black.opacity(0.7))
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
            
            
        }.padding(.top, 32)
            .navigationBarTitle("식단", displayMode: .inline)
            .accentColor(.white)
            .gesture(drag)
            .onAppear {
                
                // 현재 시간
                let hour = Calendar.current.component(.hour, from: self.date)
                // 현재 분
                let minute = Calendar.current.component(.minute, from: self.date)
                
                if (hour >= 0 && hour < 9) { // 0 ~ 9시까지 아침
                    self.diningViewRouter.currentView = "breakfast"
                } else if (hour >= 9 && hour < 14) { // 9시부터 13시 반까지 점심
                    if (hour == 13 && minute > 30) { // 13시 반을 넘으면 저녁
                        self.diningViewRouter.currentView = "dinner"
                    } else {
                        self.diningViewRouter.currentView = "lunch"
                    }
                } else if (hour >= 14 && hour < 19) { // 14시부터 18시 반까지 저녁
                    if (hour == 18 && minute > 30) { // 18시 반을 넘으면 다음 날로 이동해서 아침
                        self.date = Date(timeInterval: 86400, since: self.date)
                        self.dateString = dateToString(date: self.date)
                        self.observed.meal_session(date: self.date)
                        self.diningViewRouter.currentView = "breakfast"
                    } else {
                        self.diningViewRouter.currentView = "dinner"
                    }
                } else if (hour >= 19 && hour < 24) { // 19시부터 24시까지 다음날로 이동해서 아침
                    self.date = Date(timeInterval: 86400, since: Date())
                    self.dateString = dateToString(date: self.date)
                    self.observed.meal_session(date: self.date)
                    self.diningViewRouter.currentView = "breakfast"
                }
        }
    }
}

struct MenuView: View {
    //menu_type: 0: 아침, 1: 점심, 2: 저녁
    var menu_type: Int
    let menu_switch: Array<String> = ["BREAKFAST", "LUNCH", "DINNER"]

    //식단 정보가 저장된 오브젝트
    @ObservedObject var observed: DiningFetcher

    var body: some View {
        let data = self.observed.get_meal(type: self.menu_type)
        return Group {
            if (data.isEmpty) {
                List {
                    EmptyCardView()
                }
            } else {
                List {
                    ForEach(observed.meals) { meal in
                        if (meal.type == self.menu_switch[self.menu_type]) { // 해당 메뉴일 경우 표시하기
                            CardView(place: meal.place, priceCard: meal.priceCard, priceCash: meal.priceCash, kcal: meal.kcal, menu: meal.menu)

                        }
                    }
                    
                }
            }
        }
    }
}


struct EmptyCardView: View{

    
    var body: some View{
                VStack(alignment: .leading){
                    
                    
                    Text("메뉴 정보가 없습니다.")
                    .font(.system(size: 12, weight: .regular))
                        .lineSpacing(6)
                        .foregroundColor(Color("black"))
          
        }
                
                    .fixedSize(horizontal: false,vertical: true)
                    .frame(maxWidth: .infinity)
                .padding()
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 1)
                .stroke(Color("cloudy_blue"), lineWidth: 1)
        )
        .background(Color.white)
        .padding([.top, .horizontal], 16)
        .clipped()
        .shadow(color: Color.black.opacity(0.25), radius: 6, x: 0, y: 0)
        
        
    }
 
    
}


struct CardView: View{
    // 식단 위치
    var place: String
    // 식단 캐시비 가격
    var priceCard: Int?
    // 식단 현금 가격
    var priceCash: Int?
    // 식단 칼로리
    var kcal: Int?
    // 식단 메뉴
    var menu: [String]
    
    
    
    var body: some View{
                VStack(alignment: .leading){
                    HStack {
                        Text(place)
                        .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.black)
                        Spacer()
                        Text("캐시비 \(convertPrice(price: priceCard))원 / 현금 \(convertPrice(price: priceCash))원")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(Color("warm_grey"))
                    }.padding(.top, 8)
                    if (place == "능수관") {
                        Rectangle()
                        .fill(Color("squash"))
                        .frame(height: 1)
                    } else {
                        Rectangle()
                        .fill(Color("light_navy"))
                        .frame(height: 1)
                    }
                    
                    Text("\(convertPrice(price: kcal))Kcal")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color("warm_grey"))
                        .padding(.bottom, 16)
                    
                    Text(menu.joined(separator: "\n"))
                    .font(.system(size: 12, weight: .regular))
                        .lineSpacing(6)
                        .foregroundColor(Color("black"))
                    .lineLimit(nil)
          
        }
                
                    .fixedSize(horizontal: false,vertical: true)
                    .frame(maxWidth: .infinity)
                .padding()
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 1)
                .stroke(Color("cloudy_blue"), lineWidth: 1)
        )
        .background(Color.white)
        .padding([.top, .horizontal], 16)
        .clipped()
        .shadow(color: Color.black.opacity(0.25), radius: 6, x: 0, y: 0)
        
        
    }
 
    
}

// Date를 String으로 변환해주는 함수
func dateToString(date: Date)->String {
    // Date 포맷을 설정해주는 오브젝트
    let dateFormatter = DateFormatter()
    // Date 포맷 설정
    dateFormatter.dateFormat = "yyyy-MM-dd"
    //Date 포맷에 따라 String으로 변환해주기
    let dateString = dateFormatter.string(from: date)
    return dateString
}

// Int를 가격 형식의 String으로 변환해주는 함수
func convertPrice(price:Int?) -> String {
    // 숫자 포맷을 설정해주는 오브젝트
    let formatter = NumberFormatter()
    // 숫자 포맷의 지역을 현재 지역으로 설정
    formatter.locale = Locale.current
    // 숫자 포맷을 가격으로 설정
    formatter.numberStyle = .currency
    // 통화 기호($) 지우기
    formatter.currencySymbol = ""

    if let intPrice = price { // price값이 nil이 아닐 경우
        if let formattedPrice = formatter.string(from: intPrice as NSNumber) { // 숫자 포맷에 따라 Int를 String으로 변환
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
