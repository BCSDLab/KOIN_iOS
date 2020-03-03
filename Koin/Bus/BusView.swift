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
        
        
        return
            VStack {
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
        }
    }
}

struct BusView_Previews: PreviewProvider {
    static var previews: some View {
        BusView()
    }
}
