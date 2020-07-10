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
    
    @State var errorText: String = ""
    @State var showError: Bool = false
    
    @State var nearCityBusTime : Date = Date()
    @State var nextCityBusTime: Date = Date()
    @State var nearCityBus : String = ""
    @State var nextCityBus: String = ""
    @State var shuttleTime: Date = Date()
    @State var expressTime: Date = Date()
    @State var nearShuttle: String = ""
    @State var nearExpressTime : String = ""
    @State var nextShuttleTime: Date = Date()
    @State var nextExpressTime: Date = Date()
    @State var nextShuttle: String = ""
    @State var nextExpress : String = ""
    
    
    @State var selectedDepart = 0
    @State var selectedArrival = 2
    @State var nowDate: Date = Date()
    var timer: Timer {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {_ in
            self.nowDate = Date()
        }
    }
    //시분초 단위로 분래
    func countDownString(from date: Date, until nowDate: Date) -> String {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar
            .dateComponents([.hour, .minute, .second]
                ,from: nowDate,
                 to: date)
        return String(format: "%02d시간 %02d분 %02d초",
                      components.hour ?? 00,
                      components.minute ?? 00,
                      components.second ?? 00)
    }
    
    
    var departActionSheet: ActionSheet {
        ActionSheet(title: Text("출발"), buttons: [
            .default(Text("한기대"), action: {
                self.selectedDepart = 0
            }),
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
        
        return VStack {
            HStack {
                HStack {
                    Text(showStation[selectedDepart])
                        .font(.system(size: 20))
                        .foregroundColor(Color("black"))
                        .fixedSize(horizontal: true, vertical: false)
                    Image(systemName: "chevron.down")
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 9.9, height: 6.1, alignment: .center)
                        .foregroundColor(Color("bus_arrow_color"))
                        .padding(.all, 0)
                }
                .actionSheet(isPresented: $isDepartActionSheet) {
                    self.departActionSheet
                }
                .onTapGesture {
                    self.isDepartActionSheet.toggle()
                }
                
                Text("에서 ")
                    .font(.system(size: 20))
                    .foregroundColor(Color("black"))
                    .fontWeight(.light)
                HStack {
                    Text(showStation[selectedArrival])
                        .font(.system(size: 20))
                        .foregroundColor(Color("black"))
                        .fixedSize(horizontal: true, vertical: false)
                    Image(systemName: "chevron.down")
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 9.9, height: 6.1, alignment: .center)
                        .foregroundColor(Color("bus_arrow_color"))
                        .padding(.all, 0)
                }.onTapGesture {
                    self.isArrivalActionSheet.toggle()
                }.actionSheet(isPresented: $isArrivalActionSheet) {
                    self.arrivalActionSheet
                }
                
                Text("갑니다")
                    .font(.system(size: 20))
                    .foregroundColor(Color("black"))
                    .fontWeight(.light)
                    .padding(.all, 0)
            }.padding(.vertical, 16)
            ScrollView(.vertical) {
                VStack {
                    HStack {
                        Text("출발")
                            .font(.system(size: 11))
                            .foregroundColor(.white)
                            .frame(width: 42, height: 20, alignment: .center)
                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white, lineWidth: 1))
                        Text(showStation[selectedDepart])
                            .font(.system(size: 15))
                            .foregroundColor(.white)
                            .fontWeight(.light)
                        Spacer()
                        Text("학교셔틀")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                    }.padding([.top, .horizontal], 16)
                    HStack {
                        Text("도착")
                            .font(.system(size: 11))
                            .foregroundColor(.white)
                            .frame(width: 42, height: 20, alignment: .center)
                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white, lineWidth: 1))
                        Text(showStation[selectedArrival])
                            .font(.system(size: 15))
                            .foregroundColor(.white)
                            .fontWeight(.light)
                        Spacer()
                    }.padding(.horizontal, 16)
                        .padding(.vertical, 8)
                    HStack {
                        if(shuttleTime.timeIntervalSince(Date()) > 0) {
                            Text(countDownString(from: shuttleTime, until: nowDate))
                                .font(.system(size: 18))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .onAppear(perform: {
                                    let _ = self.timer
                                })
                            Text("남음")
                                .font(.system(size: 18))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Spacer()
                            Text("(\(self.controller.getNearShuttleTimeToString(depart: station[selectedDepart], arrival: station[selectedArrival], isNow: true))분 출발)")
                                .font(.system(size: 13))
                                .foregroundColor(.white)
                                .onAppear(perform: {
                                    let _ = self.timer
                                })
                        } else {
                            Text("운행 정보 없음")
                                .font(.system(size: 18))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Spacer()
                        }
                        
                    }.padding([.horizontal, .top], 16)
                        .padding(.bottom, 8)
                }.background(Color("squash"))
                    .padding(.horizontal, 16)
                    .padding(.bottom, 4)
                
                VStack {
                    HStack {
                        Text("다음 버스")
                            .font(.system(size: 15))
                            .foregroundColor(.white)
                        Spacer()
                        Text("학교셔틀")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                    }.padding([.top, .horizontal], 16)
                        .padding(.bottom, 8)
                    HStack {
                        if(nextShuttleTime.timeIntervalSince(Date()) > 0) {
                            Text(countDownString(from: nextShuttleTime, until: nowDate))
                                .font(.system(size: 18))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .onAppear(perform: {
                                    let _ = self.timer
                                })
                            Text("남음")
                                .font(.system(size: 18))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Spacer()
                            Text("(\(nextShuttle)분 출발)")
                                .font(.system(size: 13))
                                .foregroundColor(.white)
                                .onAppear(perform: {
                                    let _ = self.timer
                                })
                        } else {
                            Text("운행 정보 없음")
                                .font(.system(size: 18))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Spacer()
                        }
                        
                    }.padding([.horizontal, .top], 16)
                        .padding(.bottom, 8)
                }.background(Color("squash"))
                    .padding(.horizontal, 16)
                    .padding(.bottom, 4)
                
                
                VStack {
                    HStack {
                        Text("출발")
                            .font(.system(size: 11))
                            .foregroundColor(.white)
                            .frame(width: 42, height: 20, alignment: .center)
                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white, lineWidth: 1))
                        Text(showStation[selectedDepart])
                            .font(.system(size: 15))
                            .foregroundColor(.white)
                            .fontWeight(.light)
                        Spacer()
                        Text("대성고속")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                    }.padding([.top, .horizontal], 16)
                    HStack {
                        Text("도착")
                            .font(.system(size: 11))
                            .foregroundColor(.white)
                            .frame(width: 42, height: 20, alignment: .center)
                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white, lineWidth: 1))
                        Text(showStation[selectedArrival])
                            .font(.system(size: 15))
                            .foregroundColor(.white)
                            .fontWeight(.light)
                        Spacer()
                    }.padding(.horizontal, 16)
                        .padding(.vertical, 8)
                    HStack {
                        if(expressTime.timeIntervalSince(Date()) > 0) {
                            Text(countDownString(from: expressTime, until: nowDate))
                                .font(.system(size: 18))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .onAppear(perform: {
                                    let _ = self.timer
                                })
                            Text("남음")
                                .font(.system(size: 18))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Spacer()
                            Text("(\(self.controller.getNearExpressTimeToString(depart: station[selectedDepart], arrival: station[selectedArrival], isNow: true))분 출발)")
                                .font(.system(size: 13))
                                .foregroundColor(.white)
                                .onAppear(perform: {
                                    let _ = self.timer
                                })
                        } else {
                            Text("운행 정보 없음")
                                .font(.system(size: 18))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Spacer()
                        }
                        
                    }.padding([.horizontal, .top], 16)
                        .padding(.bottom, 8)
                }.background(Color("shark"))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 4)
                
                VStack {
                    HStack {
                        Text("다음 버스")
                            .font(.system(size: 15))
                            .foregroundColor(.white)
                        Spacer()
                        Text("대성고속")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                    }.padding([.top, .horizontal], 16)
                        .padding(.bottom, 8)
                    HStack {
                        if(nextExpressTime.timeIntervalSince(Date()) > 0) {
                            Text(countDownString(from: nextExpressTime, until: nowDate))
                                .font(.system(size: 18))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .onAppear(perform: {
                                    let _ = self.timer
                                })
                            Text("남음")
                                .font(.system(size: 18))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Spacer()
                            Text("(\(nextExpress)분 출발)")
                                .font(.system(size: 13))
                                .foregroundColor(.white)
                                .onAppear(perform: {
                                    let _ = self.timer
                                })
                        } else {
                            Text("운행 정보 없음")
                                .font(.system(size: 18))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Spacer()
                        }
                        
                    }.padding([.horizontal, .top], 16)
                        .padding(.bottom, 8)
                }.background(Color("shark"))
                    .padding(.horizontal, 16)
                    .padding(.bottom, 4)
                
                
                VStack {
                    HStack {
                        Text("출발")
                            .font(.system(size: 11))
                            .foregroundColor(.white)
                            .frame(width: 42, height: 20, alignment: .center)
                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white, lineWidth: 1))
                        Text(showStation[selectedDepart])
                            .font(.system(size: 15))
                            .foregroundColor(.white)
                            .fontWeight(.light)
                        Spacer()
                        Text("시내버스")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                    }.padding([.top, .horizontal], 16)
                    HStack {
                        Text("도착")
                            .font(.system(size: 11))
                            .foregroundColor(.white)
                            .frame(width: 42, height: 20, alignment: .center)
                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white, lineWidth: 1))
                        Text(showStation[selectedArrival])
                            .font(.system(size: 15))
                            .foregroundColor(.white)
                            .fontWeight(.light)
                        Spacer()
                    }.padding(.horizontal, 16)
                        .padding(.vertical, 8)
                    HStack {
                        if(nearCityBusTime.timeIntervalSince(Date()) > 0) {
                            Text(countDownString(from: nearCityBusTime, until: nowDate))
                                .font(.system(size: 18))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .onAppear(perform: {
                                    let _ = self.timer
                                })
                            Text("남음")
                                .font(.system(size: 18))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Spacer()
                            Text("(\(nearCityBus)분 출발)")
                                .font(.system(size: 13))
                                .foregroundColor(.white)
                                .onAppear(perform: {
                                    let _ = self.timer
                                })
                        } else {
                            Text("운행 정보 없음")
                                .font(.system(size: 18))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Spacer()
                        }
                        
                    }.padding([.horizontal, .top], 16)
                        .padding(.bottom, 8)
                }.background(Color("mint"))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 4)
                
                VStack {
                    HStack {
                        Text("다음 버스")
                            .font(.system(size: 15))
                            .foregroundColor(.white)
                        Spacer()
                        Text("시내버스")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                    }.padding([.top, .horizontal], 16)
                        .padding(.bottom, 8)
                    HStack {
                        if(nextCityBusTime.timeIntervalSince(Date()) > 0) {
                            Text(countDownString(from: nextCityBusTime, until: nowDate))
                                .font(.system(size: 18))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .onAppear(perform: {
                                    let _ = self.timer
                                })
                            Text("남음")
                                .font(.system(size: 18))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Spacer()
                            Text("(\(nextCityBus)분 출발)")
                                .font(.system(size: 13))
                                .foregroundColor(.white)
                                .onAppear(perform: {
                                    let _ = self.timer
                                })
                        } else {
                            Text("운행 정보 없음")
                                .font(.system(size: 18))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Spacer()
                        }
                        
                    }.padding([.horizontal, .top], 16)
                        .padding(.bottom, 8)
                }.background(Color("mint"))
                    .padding(.horizontal, 16)
                    .padding(.bottom, 4)
                
                
            }
        }.alert(isPresented: $showError) {
            // 이메일을 확인해보라는 Alert을 띄운 다음
            Alert(title: Text("에러"), message: Text(self.errorText), dismissButton: .default(Text("닫기")) {
                // 돌아가기 버튼을 누르면 Alert은 꺼지고
                self.showError = false
                })
        }.onAppear {
            self.controller.getRemainCityBusTimeToDate(depart: self.station[self.selectedDepart], arrival: self.station[self.selectedArrival]) { (result, error) in
                if let date = result {
                    self.nearCityBusTime = date
                    self.errorText = ""
                    self.showError = false
                } else {
                    self.errorText = (error?.localizedDescription)!
                    self.showError = true
                }
            }
            self.controller.getNextCityBusTimeToDate(depart: self.station[self.selectedDepart], arrival: self.station[self.selectedArrival]) {(result, error) in
                if let date = result {
                    self.nextCityBusTime = date
                    self.errorText = ""
                    self.showError = false
                } else {
                    self.errorText = (error?.localizedDescription)!
                    self.showError = true
                }
            }
            
            self.controller.getRemainCityBusTimeToString(depart: self.station[self.selectedDepart], arrival: self.station[self.selectedArrival]) { (result, error) in
                if let bus = result {
                    self.nearCityBus = bus
                    self.errorText = ""
                    self.showError = false
                } else {
                    self.errorText = (error?.localizedDescription)!
                    self.showError = true
                }
                
            }
            self.controller.getNextCityBusTimeToString(depart: self.station[self.selectedDepart], arrival: self.station[self.selectedArrival]) {(result, error) in
                if let bus = result {
                    self.nextCityBus = bus
                    self.errorText = ""
                    self.showError = false
                } else {
                    self.errorText = (error?.localizedDescription)!
                    self.showError = true
                }
                
            }
            self.shuttleTime = self.controller.getRemainShuttleTimeToDate(depart: self.station[self.selectedDepart], arrival: self.station[self.selectedArrival], isNow: true)
            self.expressTime = self.controller.getRemainExpressTimeToDate(depart: self.station[self.selectedDepart], arrival: self.station[self.selectedArrival], isNow: true)
            
            self.nearShuttle = self.controller.getNearShuttleTimeToString(depart: self.station[self.selectedDepart], arrival: self.station[self.selectedArrival], isNow: true)
            self.nearExpressTime =
                self.controller.getNearExpressTimeToString(depart: self.station[self.selectedDepart], arrival: self.station[self.selectedArrival], isNow: true)
            
            
            self.nextShuttleTime = self.controller.getRemainShuttleTimeToDate(depart: self.station[self.selectedDepart], arrival: self.station[self.selectedArrival], isNow: false)
            self.nextExpressTime = self.controller.getRemainExpressTimeToDate(depart: self.station[self.selectedDepart], arrival: self.station[self.selectedArrival], isNow: false)
            self.nextShuttle = self.controller.getNearShuttleTimeToString(depart: self.station[self.selectedDepart], arrival: self.station[self.selectedArrival], isNow: false)
            self.nextExpress =
                self.controller.getNearExpressTimeToString(depart: self.station[self.selectedDepart], arrival: self.station[self.selectedArrival], isNow: false)
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
    @EnvironmentObject var tabData: ViewRouter
    
    var body: some View {
        VStack {
            HStack(alignment: .bottom,spacing: 0){
                VStack{
                    Spacer()
                    Text("운행정보")
                        //현재 선택되어있는 탭이 "breakfast"이면, squash색의 밑줄 긋기
                        .onTapGesture { //이 탭을 누르면
                            //선택된 탭을 "breakfast"로 변경
                            self.currentPage = 0
                    }
                    .foregroundColor(self.currentPage == 0 ? Color("squash") : Color("grey2"))
                    .accentColor(self.currentPage == 0 ? Color("squash") : Color("grey2"))
                }.padding(.horizontal, 0)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 37, maxHeight: 37)
                VStack{
                    Spacer()
                    Text("운행 정보 검색")
                        //현재 선택되어있는 탭이 "breakfast"이면, squash색의 밑줄 긋기
                        .onTapGesture { //이 탭을 누르면
                            //선택된 탭을 "breakfast"로 변경
                            self.currentPage = 1
                    }
                    .foregroundColor(self.currentPage == 1 ? Color("squash") : Color("grey2"))
                    .accentColor(self.currentPage == 1 ? Color("squash") : Color("grey2"))
                }.padding(.horizontal, 0)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 37, maxHeight: 37)
                VStack{
                    Spacer()
                    Text("시간표")
                        //현재 선택되어있는 탭이 "breakfast"이면, squash색의 밑줄 긋기
                        .onTapGesture { //이 탭을 누르면
                            //선택된 탭을 "breakfast"로 변경
                            self.currentPage = 2
                    }
                    .foregroundColor(self.currentPage == 2 ? Color("squash") : Color("grey2"))
                    .accentColor(self.currentPage == 2 ? Color("squash") : Color("grey2"))
                }.padding(.horizontal, 0)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 37, maxHeight: 37)
                
            }.padding(.all, 0)
            HStack(alignment:.top,spacing: 0){
                if (self.currentPage == 0) {
                    Rectangle()
                        .fill(Color("squash"))
                        .frame(height: 2)
                } else {
                    Rectangle()
                        .fill(Color("grey2"))
                        .frame(height: 2)
                }
                if (self.currentPage == 1) {
                    Rectangle()
                        .fill(Color("squash"))
                        .frame(height: 2)
                } else {
                    Rectangle()
                        .fill(Color("grey2"))
                        .frame(height: 2)
                }
                if (self.currentPage == 2) {
                    Rectangle()
                        .fill(Color("squash"))
                        .frame(height: 2)
                } else {
                    Rectangle()
                        .fill(Color("grey2"))
                        .frame(height: 2)
                }
                
            }.padding(.all, 0)
            BusPagerView(pageCount: 3, currentIndex: self.$currentPage) {
                BusInfoView()
                BusSearchView()
                CommuterListView()
            }
            .navigationBarTitle("버스", displayMode: .inline)
        }.onAppear {
            
        }
    }
}

struct BusView_Previews: PreviewProvider {
    static var previews: some View {
        BusView()
    }
}
