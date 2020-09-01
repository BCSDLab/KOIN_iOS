//
//  HomeViewModel.swift
//  Koin
//
//  Created by 정태훈 on 2020/08/27.
//  Copyright © 2020 정태훈. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

class HomeViewModel: ObservableObject {
    //@Published var data = [CircleCellViewModel]()
    let homeFetcher: HomeFetcher = HomeFetcher()
    
    @Published var progress: Bool = true
    
    private var disposables = Set<AnyCancellable>()
    
    
    // koreatech, station, terminal
    @Published var isChange: Bool = false {
        // 값이 설정되었을 때
        didSet {
            // 오브젝트가 바뀌었다고 알려준다.
            //currentViewChange.send(currentView)
            //objectWillChange.send(self)
            if (isChange) {
                self.expressTime = homeFetcher.getExpress(depart: "terminal", arrival: "koreatech")
                self.shuttleTime = homeFetcher.getShuttle(depart: "terminal", arrival: "koreatech")
                self.getCityBus(depart: "terminal", arrival: "koreatech")
            } else {
                self.expressTime = homeFetcher.getExpress(depart: "koreatech", arrival: "terminal")
                self.shuttleTime = homeFetcher.getShuttle(depart: "koreatech", arrival: "terminal")
                self.getCityBus(depart: "koreatech", arrival: "terminal")
            }
        }
    }
    
    @Published var expressTime: Date = Date()
    @Published var shuttleTime: Date = Date()
    @Published var cityBusTime: Date = Date()
    
    // MARK:- 식단
    @Published var currentMealTime: String = "breakfast"
    @Published var selectedPlace: String = ""
    @Published var currentMeal: [DiningRequest] = []
    
    init() {
        self.loadMeal()
        self.expressTime = homeFetcher.getExpress(depart: "koreatech", arrival: "terminal")
        self.shuttleTime = homeFetcher.getShuttle(depart: "koreatech", arrival: "terminal")
        self.getCityBus(depart: "koreatech", arrival: "terminal")
    }
    
    deinit {
        disposables.removeAll()
    }
    
    func setMealPlace(place: String) {
        selectedPlace = place
    }
    
    func changeBusPlace() {
        self.isChange.toggle()
    }
    
    func getCityBus(depart: String, arrival: String) {
        self.homeFetcher.getCityBus(depart: depart, arrival: arrival)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { value in
                switch value {
                    case .failure:
                        self.cityBusTime = Date()
                    case .finished:
                        break
                }
            }, receiveValue: { cityBus in
                print(Date(timeIntervalSinceNow: TimeInterval(cityBus.remainTime ?? 0)))
                
                self.cityBusTime = Date(timeIntervalSinceNow: TimeInterval(cityBus.remainTime ?? 0))
                
            })
            .store(in: &disposables)
    }
    
    func loadMeal() {
        // 현재 시간
        let date = Date()
        
        let hour = Calendar.current.component(.hour, from: date)
        // 현재 분
        let minute = Calendar.current.component(.minute, from: date)
        
        if (hour >= 0 && hour < 9) { // 0 ~ 9시까지 아침
            self.currentMealTime = "BREAKFAST"
        } else if (hour >= 9 && hour < 14) { // 9시부터 13시 반까지 점심
            if (hour == 13 && minute > 30) { // 13시 반을 넘으면 저녁
                self.currentMealTime = "DINNER"
            } else {
                self.currentMealTime = "LUNCH"
            }
        } else if (hour >= 14 && hour < 19) { // 14시부터 18시 반까지 저녁
            if (hour == 18 && minute > 30) { // 18시 반을 넘으면 다음 날로 이동해서 아침
                self.currentMealTime = "BREAKFAST"
            } else {
                self.currentMealTime = "DINNER"
            }
        } else if (hour >= 19 && hour < 24) { // 19시부터 24시까지 다음날로 이동해서 아침
            self.currentMealTime = "BREAKFAST"
        }

        
        self.homeFetcher.getMeal()
        .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: { value in
            switch value {
                case .failure:
                    self.currentMeal = []
                case .finished:
                    break
            }
        }, receiveValue: { meal in
            
            self.currentMeal = meal
            self.selectedPlace = meal.filter { (m: DiningRequest) in
                m.type == self.currentMealTime
                }.first?.place ?? ""
            print(meal)
        })
            .store(in: &disposables)
    }
    
    
}
