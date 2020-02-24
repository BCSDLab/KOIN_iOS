//
//  BusView.swift
//  dev_koin
//
//  Created by 정태훈 on 2020/02/08.
//  Copyright © 2020 정태훈. All rights reserved.
//

import SwiftUI

struct MyAlert: View {
    @State private var currentDate = Date()

    var body: some View {

        VStack {
            Text("Enter Input").font(.headline).padding()

            DatePicker("", selection: $currentDate, displayedComponents: .date).labelsHidden()
            Divider()
            HStack {
                Button(action: {
                    UIApplication.shared.windows[0].rootViewController?.dismiss(animated: true, completion: {})
                }) {

                    Text("Done")
                }

                Divider()

                Button(action: {
                    UIApplication.shared.windows[0].rootViewController?.dismiss(animated: true, completion: {})
                }) {
                    Text("Cancel")
                }
            }.padding(0)


            }.background(Color(white: 0.9))
    }
}
/*
struct BusSearchView: View {
    let controller: BusController = BusController()
    var station = ["koreatech", "station", "terminal"]
    var showStation = ["한기대", "천안역","야우리"]
    @State private var isDepartActionSheet = false
    @State private var isArrivalActionSheet = false
    @State var selectedDepart = 0
    @State var selectedArrival = 2
    @State private var currentDate = Date()
    @State private var isCheckActionSheet = false
    
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
            var shuttleTime: TimeInterval = self.controller.getRemainShuttleTimeToInt(depart: station[selectedDepart], arrival: station[selectedArrival], isNow: true)
            var expressTime: TimeInterval = self.controller.getRemainExpressTimeToInt(depart: station[selectedDepart], arrival: station[selectedArrival], isNow: true)
            var nearShuttle: String = self.controller.getNearShuttleTimeToString(depart: station[selectedDepart], arrival: station[selectedArrival], isNow: true)
            var nearExpressTime : String =
                self.controller.getNearExpressTimeToString(depart: station[selectedDepart], arrival: station[selectedArrival], isNow: true)
            var nextShuttleTime: TimeInterval = self.controller.getRemainShuttleTimeToInt(depart: station[selectedDepart], arrival: station[selectedArrival], isNow: false)
            var nextExpressTime: TimeInterval = self.controller.getRemainExpressTimeToInt(depart: station[selectedDepart], arrival: station[selectedArrival], isNow: false)
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
                    //DatePicker("", selection: $currentDate, displayedComponents: .date).labelsHidden()
                    Text("fff")
                        .onTapGesture {
                            let alertHC = UIHostingController(rootView: MyAlert())

                            alertHC.preferredContentSize = CGSize(width: 300, height: 200)
                            alertHC.modalPresentationStyle = UIModalPresentationStyle.formSheet

                            UIApplication.shared.windows[0].rootViewController?.present(alertHC, animated: true)
                    }
                }
                Section(header: Text("시간 선택")) {
                    DatePicker("", selection: $currentDate, displayedComponents: .hourAndMinute).labelsHidden()
                }
                    
                
            }
        }
    }
*/
struct BusInfoView: View {
    let controller: BusController = BusController()
    var station = ["koreatech", "station", "terminal"]
    var showStation = ["한기대", "천안역","야우리"]
    @State private var isDepartActionSheet = false
    @State private var isArrivalActionSheet = false
    @State var selectedDepart = 0
    @State var selectedArrival = 2
    @State var nowDate: Date = Date()
    var timer: Timer {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {_ in
            self.nowDate = Date()
        }
    }
    
    func countDownString(from date: Date, until nowDate: Date) -> String {
            let calendar = Calendar(identifier: .gregorian)
            let components = calendar
                .dateComponents([.hour, .minute, .second]
                    ,from: nowDate,
                     to: date)
            return String(format: "%02d시간 %02d분 %02d초 남음",
                          components.hour ?? 00,
                          components.minute ?? 00,
                          components.second ?? 00)
    }
    
    
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
        var shuttleTime: Date = self.controller.getRemainShuttleTimeToDate(depart: station[selectedDepart], arrival: station[selectedArrival], isNow: true)
        var expressTime: Date = self.controller.getRemainExpressTimeToDate(depart: station[selectedDepart], arrival: station[selectedArrival], isNow: true)
        var nearShuttle: String = self.controller.getNearShuttleTimeToString(depart: station[selectedDepart], arrival: station[selectedArrival], isNow: true)
        var nearExpressTime : String =
            self.controller.getNearExpressTimeToString(depart: station[selectedDepart], arrival: station[selectedArrival], isNow: true)
        
        var nearCityBusTime : Date = self.controller.getRemainCityBusTimeToDate(depart: station[selectedDepart], arrival: station[selectedArrival])
        var nextCityBusTime: Date = self.controller.getNextCityBusTimeToDate(depart: station[selectedDepart], arrival: station[selectedArrival])
        
        var nearCityBus : String = self.controller.getRemainCityBusTimeToString(depart: station[selectedDepart], arrival: station[selectedArrival])
        var nextCityBus: String = self.controller.getNextCityBusTimeToString(depart: station[selectedDepart], arrival: station[selectedArrival])
        
        var nextShuttleTime: Date = self.controller.getRemainShuttleTimeToDate(depart: station[selectedDepart], arrival: station[selectedArrival], isNow: false)
        var nextExpressTime: Date = self.controller.getRemainExpressTimeToDate(depart: station[selectedDepart], arrival: station[selectedArrival], isNow: false)
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
                    if(shuttleTime.timeIntervalSince(Date()) > 0) {
                        Text(countDownString(from: shuttleTime, until: nowDate))
                        .onAppear(perform: {
                            let _ = self.timer
                        })
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
                    if(nextShuttleTime.timeIntervalSince(Date()) > 0) {
                        Text(countDownString(from: nextShuttleTime, until: nowDate))
                        .onAppear(perform: {
                            let _ = self.timer
                        })
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
                    if(expressTime.timeIntervalSince(Date()) > 0) {
                        Text(countDownString(from: expressTime, until: nowDate))
                        .onAppear(perform: {
                            let _ = self.timer
                        })
                        Spacer()
                        Text("\(self.controller.getNearExpressTimeToString(depart: station[selectedDepart], arrival: station[selectedArrival], isNow: true))분 출발")
                    } else {
                        Text("운행 정보 없음")
                    }
                    
                    
                }
            }.background(Color("shark"))
                .padding()
            
            VStack {
                HStack {
                    Text("다음 버스")
                    Spacer()
                    Text("대성고속")
                }
                HStack {
                    if(nextExpressTime.timeIntervalSince(Date()) > 0) {
                        Text(countDownString(from: nextExpressTime, until: nowDate))
                        .onAppear(perform: {
                            let _ = self.timer
                        })
                        Spacer()
                        Text("\(nextExpress)분 출발")
                        .onAppear(perform: {
                            let _ = self.timer
                        })
                    } else {
                        Text("운행 정보 없음")
                    }
                    
                }
            }.background(Color("shark"))
            .padding()
            
            VStack {
                HStack {
                    Text(showStation[selectedDepart])
                    Spacer()
                    Text("시내버스")
                }
                HStack {
                    Text(showStation[selectedArrival])
                }
                HStack {
                    if(nearCityBusTime.timeIntervalSince(Date()) > 0) {
                        Text(countDownString(from: nearCityBusTime, until: nowDate))
                        .onAppear(perform: {
                            let _ = self.timer
                        })
                        Spacer()
                        Text("\(nearCityBus)분 출발")
                        .onAppear(perform: {
                            let _ = self.timer
                        })
                    } else {
                        Text("운행 정보 없음")
                    }
                    
                    
                }
            }.background(Color("mint"))
                .padding()
            
            VStack {
                HStack {
                    Text("다음 버스")
                    Spacer()
                    Text("시내버스")
                }
                HStack {
                    if(nextCityBusTime.timeIntervalSince(Date()) > 0) {
                        Text(countDownString(from: nextCityBusTime, until: nowDate))
                        .onAppear(perform: {
                            let _ = self.timer
                        })
                        Spacer()
                        Text("\(nextCityBus)분 출발")
                        .onAppear(perform: {
                            let _ = self.timer
                        })
                    } else {
                        Text("운행 정보 없음")
                    }
                    
                }
            }.background(Color("mint"))
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
                CommuterListView()
            }
        }
    }
}

struct BusView_Previews: PreviewProvider {
    static var previews: some View {
        BusView()
    }
}
