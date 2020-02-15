//
//  BusView.swift
//  dev_koin
//
//  Created by 정태훈 on 2020/02/08.
//  Copyright © 2020 정태훈. All rights reserved.
//

import SwiftUI

struct BusSearchView: View {
    let controller: BusController = BusController()
    var station = ["koreatech", "station", "terminal"]
    var showStation = ["한기대", "천안역","야우리"]
    @State private var isDepartActionSheet = false
    @State private var isArrivalActionSheet = false
    @State var selectedDepart = 0
    @State var selectedArrival = 2
    @State private var currentDate = Date()
    
    var departActionSheet: ActionSheet {
        ActionSheet(title: Text("출발"), buttons: [
            .default(Text("한기대"), action: {self.selectedDepart = 0}),
            .default(Text("천안역"), action: {self.selectedDepart = 1}),
            .default(Text("야우리"), action: {self.selectedDepart = 2}),
            .destructive(Text("취소"), action: {self.isDepartActionSheet.toggle()})
        ])
    }
    
    var arrivalActionSheet: ActionSheet {
        ActionSheet(title: Text("도착"), buttons: [
            .default(Text("한기대"), action: {self.selectedArrival = 0}),
            .default(Text("천안역"), action: {self.selectedArrival = 1}),
            .default(Text("야우리"), action: {self.selectedArrival = 2}),
            .destructive(Text("취소"), action: {self.isArrivalActionSheet.toggle()})
        ])
    }
    
    var body: some View {
            var shuttleTime: [Int] = self.controller.getRemainShuttleTimeToInt(depart: station[selectedDepart], arrival: station[selectedArrival], isNow: true)
            var expressTime: [Int] = self.controller.getRemainExpressTimeToInt(depart: station[selectedDepart], arrival: station[selectedArrival], isNow: true)
            var nearShuttle: String = self.controller.getNearShuttleTimeToString(depart: station[selectedDepart], arrival: station[selectedArrival], isNow: true)
            var nearExpressTime : String =
                self.controller.getNearExpressTimeToString(depart: station[selectedDepart], arrival: station[selectedArrival], isNow: true)
            var nextShuttleTime: [Int] = self.controller.getRemainShuttleTimeToInt(depart: station[selectedDepart], arrival: station[selectedArrival], isNow: false)
            var nextExpressTime: [Int] = self.controller.getRemainExpressTimeToInt(depart: station[selectedDepart], arrival: station[selectedArrival], isNow: false)
            var nextShuttle: String = self.controller.getNearShuttleTimeToString(depart: station[selectedDepart], arrival: station[selectedArrival], isNow: false)
            var nextExpress : String =
                self.controller.getNearExpressTimeToString(depart: station[selectedDepart], arrival: station[selectedArrival], isNow: false)
            
            return VStack {
                HStack {
                    Text(showStation[selectedDepart])
                        .actionSheet(isPresented: $isDepartActionSheet) {
                            self.departActionSheet
                    }
                        .onTapGesture {
                            self.isDepartActionSheet.toggle()
                    }
                    Text("에서")
                    Text(showStation[selectedArrival])
                    .onTapGesture {
                            self.isArrivalActionSheet.toggle()
                    }.actionSheet(isPresented: $isArrivalActionSheet) {
                            self.arrivalActionSheet
                    }
                    Text("갑니다")
                    }
                Section(header: Text("날짜 선택")) {
                    DatePicker("", selection: $currentDate, displayedComponents: .date)
                        .labelsHidden()
                }
                Section(header: Text("시간 선택")) {
                    DatePicker("", selection: $currentDate, displayedComponents: .hourAndMinute).labelsHidden()
                }
                    
                
            }
        }
    }

struct BusInfoView: View {
    let controller: BusController = BusController()
    var station = ["koreatech", "station", "terminal"]
    var showStation = ["한기대", "천안역","야우리"]
    @State private var isDepartActionSheet = false
    @State private var isArrivalActionSheet = false
    @State var selectedDepart = 0
    @State var selectedArrival = 2
    
    var departActionSheet: ActionSheet {
        ActionSheet(title: Text("출발"), buttons: [
            .default(Text("한기대"), action: {self.selectedDepart = 0}),
            .default(Text("천안역"), action: {self.selectedDepart = 1}),
            .default(Text("야우리"), action: {self.selectedDepart = 2}),
            .destructive(Text("취소"), action: {self.isDepartActionSheet.toggle()})
        ])
    }
    
    var arrivalActionSheet: ActionSheet {
        ActionSheet(title: Text("도착"), buttons: [
            .default(Text("한기대"), action: {self.selectedArrival = 0}),
            .default(Text("천안역"), action: {self.selectedArrival = 1}),
            .default(Text("야우리"), action: {self.selectedArrival = 2}),
            .destructive(Text("취소"), action: {self.isArrivalActionSheet.toggle()})
        ])
    }
    
    var body: some View {
        var shuttleTime: [Int] = self.controller.getRemainShuttleTimeToInt(depart: station[selectedDepart], arrival: station[selectedArrival], isNow: true)
        var expressTime: [Int] = self.controller.getRemainExpressTimeToInt(depart: station[selectedDepart], arrival: station[selectedArrival], isNow: true)
        var nearShuttle: String = self.controller.getNearShuttleTimeToString(depart: station[selectedDepart], arrival: station[selectedArrival], isNow: true)
        var nearExpressTime : String =
            self.controller.getNearExpressTimeToString(depart: station[selectedDepart], arrival: station[selectedArrival], isNow: true)
        var nextShuttleTime: [Int] = self.controller.getRemainShuttleTimeToInt(depart: station[selectedDepart], arrival: station[selectedArrival], isNow: false)
        var nextExpressTime: [Int] = self.controller.getRemainExpressTimeToInt(depart: station[selectedDepart], arrival: station[selectedArrival], isNow: false)
        var nextShuttle: String = self.controller.getNearShuttleTimeToString(depart: station[selectedDepart], arrival: station[selectedArrival], isNow: false)
        var nextExpress : String =
            self.controller.getNearExpressTimeToString(depart: station[selectedDepart], arrival: station[selectedArrival], isNow: false)
        
        return VStack {
            HStack {
                Text(showStation[selectedDepart])
                    .actionSheet(isPresented: $isDepartActionSheet) {
                        self.departActionSheet
                }
                    .onTapGesture {
                        self.isDepartActionSheet.toggle()
                }
                Text("에서")
                Text(showStation[selectedArrival])
                .onTapGesture {
                        self.isArrivalActionSheet.toggle()
                }.actionSheet(isPresented: $isArrivalActionSheet) {
                        self.arrivalActionSheet
                }
                Text("갑니다")
                }
                
            VStack {
                HStack {
                    Text(showStation[selectedDepart])
                    Spacer()
                    Text("학교셔틀")
                }
                HStack {
                    Text(showStation[selectedArrival])
                }
                HStack {
                    if(shuttleTime != [-1, -1, -1]) {
                        Text("\(shuttleTime[0])시간 \(shuttleTime[1])분 \(shuttleTime[2])초 남음")
                        Spacer()
                        Text("\(self.controller.getNearShuttleTimeToString(depart: station[selectedDepart], arrival: station[selectedArrival], isNow: true))분 출발")
                    } else {
                        Text("운행 정보 없음")
                    }
                    
                    
                }
            }.background(Color("squash"))
                .padding()
            
            VStack {
                HStack {
                    Text("다음 버스")
                    Spacer()
                    Text("학교셔틀")
                }
                HStack {
                    if(nextShuttleTime != [-1, -1, -1]) {
                        Text("\(nextShuttleTime[0])시간 \(nextShuttleTime[1])분 \(nextShuttleTime[2])초 남음")
                        Spacer()
                        Text("\(nextShuttle)분 출발")
                    } else {
                        Text("운행 정보 없음")
                    }
                    
                }
            }.background(Color("squash"))
            .padding()
            
            VStack {
                HStack {
                    Text(showStation[selectedDepart])
                    Spacer()
                    Text("대성고속")
                }
                HStack {
                    Text(showStation[selectedArrival])
                }
                HStack {
                    if(expressTime != [-1, -1, -1]) {
                        Text("\(expressTime[0])시간 \(expressTime[1])분 \(expressTime[2])초 남음")
                        Spacer()
                        Text("\(self.controller.getNearExpressTimeToString(depart: station[selectedDepart], arrival: station[selectedArrival], isNow: true))분 출발")
                    } else {
                        Text("운행 정보 없음")
                    }
                    
                    
                }
            }.background(Color("squash"))
                .padding()
            
            VStack {
                HStack {
                    Text("다음 버스")
                    Spacer()
                    Text("대성고속")
                }
                HStack {
                    if(nextExpressTime != [-1, -1, -1]) {
                        Text("\(nextExpressTime[0])시간 \(nextExpressTime[1])분 \(nextExpressTime[2])초 남음")
                        Spacer()
                        Text("\(nextExpress)분 출발")
                    } else {
                        Text("운행 정보 없음")
                    }
                    
                }
            }.background(Color("squash"))
            .padding()
            
            
        }
    }
}

struct BusPagerView<Content: View>: View {
    let pageCount: Int
    @Binding var currentIndex: Int
    let content: Content
    @GestureState private var translation: CGFloat = 0

    init(pageCount: Int, currentIndex: Binding<Int>, @ViewBuilder content: () -> Content) {
        self.pageCount = pageCount
        self._currentIndex = currentIndex
        self.content = content()
    }
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                self.content.frame(width: geometry.size.width)
            }
            .frame(width: geometry.size.width, alignment: .leading)
            .offset(x: -CGFloat(self.currentIndex) * geometry.size.width)
            .offset(x: self.translation)
            .animation(.interactiveSpring())
            .gesture(
                DragGesture().updating(self.$translation) { value, state, _ in
                    state = value.translation.width
                }.onEnded { value in
                    let offset = value.translation.width / geometry.size.width
                    let newIndex = (CGFloat(self.currentIndex) - offset).rounded()
                    self.currentIndex = min(max(Int(newIndex), 0), self.pageCount - 1)
                }
            )
        }
    }
    
}

struct BusView: View {
    @State private var currentPage = 0

    var body: some View {
        VStack {
            HStack {
            Spacer()
                VStack{
                    Text("운행정보")
                            //현재 선택되어있는 탭이 "breakfast"이면, squash색의 밑줄 긋기
                            .onTapGesture { //이 탭을 누르면
                                //선택된 탭을 "breakfast"로 변경
                                self.currentPage = 0
                            }
                    .foregroundColor(self.currentPage == 0 ? Color("squash") : Color.black.opacity(0.7))
                    .accentColor(self.currentPage == 0 ? Color("squash") : Color.black.opacity(0.7))
                    Rectangle()
                        .fill(self.currentPage == 0 ? Color("squash") : Color.black.opacity(0.7))
                    .frame(height: 1)
                }
                Spacer()

                    VStack{
                        Text("운행 정보 검색")
                                //현재 선택되어있는 탭이 "breakfast"이면, squash색의 밑줄 긋기
                                .onTapGesture { //이 탭을 누르면
                                    //선택된 탭을 "breakfast"로 변경
                                    self.currentPage = 1
                                }
                        .foregroundColor(self.currentPage == 1 ? Color("squash") : Color.black.opacity(0.7))
                        .accentColor(self.currentPage == 1 ? Color("squash") : Color.black.opacity(0.7))
                            Rectangle()
                                .fill(self.currentPage == 1 ? Color("squash") : Color.black.opacity(0.7))
                            .frame(height: 1)
                    }
                    Spacer()
                    VStack{
                        Text("시간표")
                                //현재 선택되어있는 탭이 "breakfast"이면, squash색의 밑줄 긋기
                                .onTapGesture { //이 탭을 누르면
                                    //선택된 탭을 "breakfast"로 변경
                                    self.currentPage = 2
                                }
                        .foregroundColor(self.currentPage == 2 ? Color("squash") : Color.black.opacity(0.7))
                        .accentColor(self.currentPage == 2 ? Color("squash") : Color.black.opacity(0.7))
                        Rectangle()
                            .fill(self.currentPage == 2 ? Color("squash") : Color.black.opacity(0.7))
                        .frame(height: 1)
                    }
                Spacer()
            }
            BusPagerView(pageCount: 3, currentIndex: self.$currentPage) {
                BusInfoView()
                BusSearchView()
                Color.black
            }
        }
    }
}

struct BusView_Previews: PreviewProvider {
    static var previews: some View {
        BusView()
    }
}
