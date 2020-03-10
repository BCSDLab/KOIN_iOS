//
//  BusTimeTableView.swift
//  dev_koin
//
//  Created by 정태훈 on 2020/02/09.
//  Copyright © 2020 정태훈. All rights reserved.
//

import SwiftUI

let CityBusTimeTable:[[String]] = [
    ["시간표(터미널)","6:00(첫)-22:30(막)(10분간격)"],
    ["시간표(병천)","6:10(첫)-22:45(막)(10분간격)"],
    ["소요시간","약 40분"]
]

let ExpressBusFromKoreatechToTerminal:[[String]] = [
    ["08:00","08:20"],
    ["09:35","09:55"],
    ["10:30","10:50"],
    ["11:45","12:00"],
    ["12:35","12:55"],
    ["14:00","14:20"],
    ["15:05","15:25"],
    ["16:00","16:20"],
    ["16:55","17:15"],
    ["18:05","18:25"],
    ["18:55","19:15"],
    ["20:00","20:20"],
    ["21:05","21:25"],
    ["21:55","22:15"]
]

let ExpressBusFromTerminalToKoreatech:[[String]] = [
    ["07:00","07:20"],
    ["07:30","07:50"],
    ["09:00","09:20"],
    ["10:00","10:20"],
    ["11:00","11:20"],
    ["12:00","12:20"],
    ["13:00","13:20"],
    ["14:00","14:20"],
    ["14:30","14:50"],
    ["15:00","15:20"],
    ["16:00","16:20"],
    ["17:00","17:20"],
    ["17:50","18:10"],
    ["19:30","19:50"],
    ["20:30","20:50"],
    ["21:00","21:20"]
]

let VacationCheonanCommuterToDujeongStation:[[String]] = [
    ["두정역","07:43"],
    ["노동부(천안지방사무소)","07:45"],
    ["늘푸른극동아파트","07:46"],
    ["성정동지하차도(6단지)","07:48"],
    ["성정동전자랜드","07:49"],
    ["광혜당약국","07:50"],
    ["용암마을","07:58"],
    ["주공7단지(한라동백BS)","07:59"],
    ["신방동리차드","08:03"],
    ["신방동(구 GS주유소)","08:04"],
    ["청당동(벽산블루밍)","08:08"],
    ["부영아파트","08:10"],
    ["동우,신계초, 운전리,연춘리","정차"],
    ["대학","08:50"]
]
let VacationCheongjuCommuterToYongam:[[String]] = [
    ["용암동 현대아파트","07:30"],
    ["용암동GS대청주유소","07:31"],
    ["육거리","07:33"],
    ["상당공원B(지하상가)","07:36"],
    ["체육관(NEPA)","07:40"],
    ["사창사거리","07:42"],
    ["갤러리호텔(봉명우체국 건너편 BS)","07:43"],
    ["솔밭공원","07:45"],
    ["청주역A(서촌동BS)","07:47"],
    ["옥산(가산3리BS)","정차"],
    ["대학","08:40"]
]
let SeasonCheongjuCommuterToGym:[[String]] = [
    ["체육관(NEPA)","07:40"],
    ["사창사거리","07:42"],
    ["갤러리호텔(봉명우체국 건너편 BS)","07:43"],
    ["솔밭공원","07:45"],
    ["청주역A(서촌동BS)","07:47"],
    ["옥산(가산3리BS)","정차"],
    ["대학","08:40"]
]
let VacationSeoulCommuterToSeoul:[[String]] = [
    ["대학","18:10"],
    ["죽전간이정류장","하차"],
    ["교대","하차"]
]
let VacationSeoulCommuterToSchool:[[String]] = [
    ["교대","07:20"],
    ["동천역 환승정류장","07:37"],
    ["죽전간이정류장","07:40"],
    ["대학","08:40"]
]

let SeasonCheonanCommuterToTerminal:[[String]] = [
    ["터미널","08:00"],
    ["성황동 신협","08:03"],
    ["제일고 맞은편(구 교육청)","08:06"],
    ["원성동(GS마트)","08:08"],
    ["삼룡교(유니클로, 구 한방병원)","08:09"],
    ["구성동 부광약국(구 GS주유소)","08:10"],
    ["대학","08:50"]
]
let SeasonCheonanCommuterToCheonanStation:[[String]] = [
    ["천안역","08:05"],
    ["남부오거리(귀뚜라미보일러)","08:07"],
    ["삼룡교(유니클로, 구 한방병원)","08:09"],
    ["구성동 부광약국(구 GS주유소)","08:10"],
    ["대학","08:50"]
]
let VacationCheonanCommuterToTerminal:[[String]] = [
    ["터미널","08:00"],
    ["성황동 신협","08:03"],
    ["천안역","08:05"],
    ["남부오거리(귀뚜라미보일러)","08:07"],
    ["삼룡교(유니클로, 구 한방병원)","08:08"],
    ["구성동 부광약국(구 GS주유소)","08:10"],
    ["대학","08:50"]
]
let VacationCheonanShuttle:[[String]] = [
    ["대학","14:00"],
    ["터미널","14:25"],
    ["천안역","14:30"],
    ["삼룡교(유니클로,구 한방병원)","14:34"],
    ["구성동 부광약국(구 GS주유소)","14:35"],
    ["대학","15:20"]
]


let CheonanCommuterToKTX:[[String]] = [
    ["주공11단지APT","07:40"],
    ["동일하이빌APT","07:41"],
    ["천안아산KTX(3번출구)","07:46"],
    ["Y-City","07:47"],
    ["한화꿈에그린APT","07:49"],
    ["용암마을","07:50"],
    ["주공7단지(한라동백BS)","07:51"],
    ["신방동리차드","07:53"],
    ["신방동 GS주유소","07:54"],
    ["청당동(벽산블루밍)","08:00"],
    ["부영아파트","08:05"],
    ["동우,신계초, 운전리,연춘리","정차"],
    ["중앙APT","정차"],
    ["대학","08:50"]
]
let CheonanCommuterToTerminal:[[String]] = [
    ["터미널","08:00"],
    ["제일고 맞은편(구 교육청)","08:06"],
    ["원성동(GS마트)","08:08"],
    ["삼룡교(유니클로, 구 한방병원)","08:09"],
    ["구성동 부광약국(구 GS주유소)","08:10"],
    ["중앙APT","정차"],
    ["대학","08:50"]
]
let CheonanCommuterToCheonanStation:[[String]] = [
    ["천안역","08:05"],
    ["남부오거리(귀뚜라미보일러)","08:07"],
    ["삼룡교(유니클로, 구 한방병원)","08:09"],
    ["구성동 부광약국(구 GS주유소)","08:10"],
    ["중앙APT","정차"],
    ["대학","08:50"]
]
let CheonanCommuterToShinbang:[[String]] = [
    ["신방동(현대APT)","07:55"],
    ["신방동 새마을금고","07:56"],
    ["충무병원","08:01"],
    ["세종아트빌라BS(구 일봉회관)","08:03"],
    ["제일고 맞은편(구 교육청)","08:08"],
    ["원성동(GS마트)","08:10"],
    ["삼룡교(유니클로, 구 한방병원)","08:12"],
    ["구성동 부광약국(구 GS주유소)","08:13"],
    ["청수고BS 앞쪽","08:14"],
    ["한양수자인APT(청당동)","08:15"],
    ["중앙APT","정차"],
    ["대학","08:50"]
]
let CheonanCommuterToDujeongStation:[[String]] = [
    ["두정역","07:43"],
    ["노동부(천안지방사무소)","07:45"],
    ["늘푸른극동아파트","07:46"],
    ["성정동지하차도(6단지)","07:48"],
    ["성정동전자랜드","07:49"],
    ["광혜당약국","07:50"],
    ["충무병원","07:53"],
    ["세종아트빌라BS(구 일봉회관)","07:55"],
    ["남부오거리(귀뚜라미 보일러)","07:56"],
    ["삼룡교(유니클로, 구 한방병원)","07:58"],
    ["구성동 부광약국(구 GS주유소)","08:00"],
    ["동우APT,신계초,운전리,연춘리","정차"],
    ["중앙APT","정차"],
    ["대학","08:50"]
]

let CheonanWeekdayShuttle:[[String]] = [
["대학(본교)","09:10","11:00","14:00","15:00","16:00","16:30","17:00","","19:30","21:00","","22:40"],
["천안역(태극당 건너 정류장)","09:30","","","15:20","","","","","","","",""],
["터미널(신세계)","09:40","","","15:30","","","","","","","",""],
["두정캠퍼스","09:55","","","15:45","","","","","","","21:50",""],
["터미널(신세계)","10:10","11:25","14:25","16:05","16:25","16:55","17:25","18:45","19:55","하차","22:00","하차"],
["천안역","10:15","11:30","14:30","16:10","16:30","17:00","17:30","18:50","20:00","종점","22:05","종점"],
["대학(본교)","11:00","12:00","15:00","16:40","17:00","17:30","18:00","19:20","20:40","","22:25",""]
]

let CheonanWeekendShuttle:[[String]] = [
["대학(본교)","14:00","","17:00","",""],
["천안역(태극당 건너 정류장)","","","","",""],
["터미널(신세계)","","","","",""],
["두정캠퍼스","","","","",""],
["터미널(신세계)","14:25","18:45","17:30","21:15","21:30"],
["천안역","14:30","18:50","17:35","21:20","21:35"],
["대학(본교)","15:00","19:30","18:10","21:50","22:00"]
]

let CheongjuCommuterToGym:[[String]] = [
    ["체육관(NEPA)","07:40"],
    ["사창사거리","07:42"],
    ["갤러리호텔(봉명우체국 건너편 BS)","07:46"],
    ["솔밭공원","07:50"],
    ["청주역A(서촌동BS)","07:56"],
    ["대학","08:50"]
]

let CheongjuCommuterToYongam:[[String]] = [
    ["용암동 현대아파트","07:30"],
    ["용암동GS대청주유소","07:31"],
    ["석교동육거리","07:33"],
    ["상당공원B(지하상가)","07:36"],
    ["청주시청(방아다리)","07:37"],
    ["문화 산업단지(구 제조창)","07:40"],
    ["성모병원(율량 맥도널드)","07:45"],
    ["과학단지(오창프라자)","08:00"],
    ["대학","08:50"]
]

let CheongjuCommuterToSannam:[[String]] = [
    ["산남동 수곡교회","07:20"],
    ["충북 원예농협(GS 마트)","07:22"],
    ["충북대병원(버스정류장)","07:26"],
    ["KBS 맞은편","07:27"],
    ["개신동푸르지오(버스정류장)","07:31"],
    ["군산회타운(경산초 맞은편)","07:32"],
    ["롯데마트앞","07:37"],
    ["흥덕고교 버스정류장","07:42"],
    ["청주역(서촌동버스정류장)","07:46"],
    ["옥산(가락3리버스정류장)","07:49"],
    ["대학","08:50"]
]

let CheongjuCommuterToBunpyeong:[[String]] = [
    ["대학","등교만"],
    ["분평동 전자랜드","07:30"],
    ["남성초등학교","07:31"],
    ["청주교대(KFC 앞)","07:32"],
    ["청주농협 남부지점(일신장)","07:34"],
    ["서원대학교","07:38"],
    ["사직동 새마을금고(거구장)","07:41"],
    ["사직평화APT(버스정류장)","07:42"],
    ["청원경찰서","07:43"],
    ["루체피에스타(구 대한예식장)","07:45"],
    ["청주농고후문","07:47"],
    ["성모병원(율량 맥도널드)","07:50"],
    ["과학단지(오창프라자)","08:00"],
    ["대학","08:50"]
]

let CheongjuShuttle:[[String]] = [
    ["대학(본교)","","14:00","16:00","20:00","22:00"],
    ["옥산(가락3리)","","하차","","하차",""],
    ["청주역","","하차","","하차",""],
    ["G-WELL CITY","","하차","","하차",""],
    ["솔밭공원","","하차","","하차",""],
    ["봉명우체국","","하차","","하차",""],
    ["오창과학단지","","","하차","","하차"],
    ["성모병원","","","하차","","하차"],
    ["신봉사거리(LPG충전소)","","","하차","","하차"],
    ["봉명사거리","","","하차","","하차"],
    ["사창사거리","","하차","하차","하차","하차"],
    ["체육관","","하차","하차","하차","종점"],
    ["상당공원","","하차","하차","하차",""],
    ["육거리","","하차","하차","하차",""],
    ["삼양가스","","하차","하차","하차",""],
    ["용암동(현대APT)","11:50","종점","종점","종점",""],
    ["GS 대청주유소(용암동)","11:51","","","",""],
    ["석교동육거리","11:54","","","",""],
    ["상당공원(지하상가)","11:56","","","",""],
    ["체육관(NEPA)","11:58","","","",""],
    ["사창사거리","12:00","","","",""],
    ["갤러리호텔","12:02","","","",""],
    ["솔밭공원앞","12:05","","","",""],
    ["청주역(서촌동버스정류장)","12:10","","","",""],
    ["옥산(가락3리버스정류장)","12:12","","","",""],
    ["대학(본교)","12:50","","","",""]
]

let SeoulCommuterToSeoul:[[String]] = [
    ["대학","18:10","16:30(학기중 월, 금요일 운행)"],
    ["죽전간이정류장","하차","하차"],
    ["교대","하차","하차"]
]

let SeoulCommuterToSchool:[[String]] = [
    ["교대","07:20", ""],
    ["동천역 환승정류장","07:37", ""],
    ["죽전간이정류장","07:40", ""],
    ["대학","08:40", ""]
]

let DaejeonCommuter:[[String]] = [
    ["대학→대전(하교 / 주말 전날)","18:20"],
    ["대전→대학(등교 / 주초 휴무일 전날) (승차장소확인)","18:00(시청), 18:10 (시청), 18:20 (역), 18:25(복합터미널 건너편 오렌지팩토리)"]
]



struct CommuterListCell: View {
    let place: String
    let time: String
    init(place: String, time: String) {
        self.place = place
        self.time = time
    }
    var body: some View {
        return VStack {
            HStack {
                Text(place)
                .foregroundColor(Color("black"))
                .font(.system(size: 13))
                Spacer()
                Text(time)
                    .foregroundColor(Color("black"))
                .font(.system(size: 13))
            }.padding(.horizontal, 10)
            Divider()
        }
    }
}

struct ShuttleListCell: View {
    let content: [String]
    var body: some View {
        VStack{
                HStack {
                    Text(self.content[0])
                        .foregroundColor(Color("black"))
                        .font(.system(size: 13))
                    .frame(width: 100, alignment: .center)
                    .padding(5)
                    ForEach(1 ..< content.count, id: \.self) { i in
                        Text(self.content[i] == "" ? "X" : self.content[i])
                            .foregroundColor(Color("black"))
                            .font(.system(size: 13))
                                .frame(width: 50, alignment: .center)
                            .padding(5)
                        
                    }
                    
        }
            Divider()
        }
    }

    init(content: [String]) {
        self.content = content
    }
}

struct SeoulListCell: View {
    let content: [String]

    var body: some View {
                HStack {
                    Text(self.content[0])
                        .foregroundColor(Color("black"))
                    .font(.system(size: 13))
                    .frame(width: 100, alignment: .center)
                    .padding(5)
                    ForEach(1 ..< content.count, id: \.self) { i in
                        Text(self.content[i] == "" ? "X" : self.content[i])
                            .foregroundColor(Color("black"))
                            .font(.system(size: 13))
                                .frame(width: 100, alignment: .center)
                            .padding(5)
                        
                    }
        }
    }

    init(content: [String]) {
        self.content = content
    }
}

struct ExpressListCell: View {
    let place: String
    let time: String

    var body: some View {
                HStack {
                    Text(self.place)
                        .foregroundColor(Color("black"))
                    .font(.system(size: 13))
                    .frame(width: 150, alignment: .center)
                    .padding(5)
                    Text(self.time)
                        .foregroundColor(Color("black"))
                    .font(.system(size: 13))
                    .frame(width: 150, alignment: .center)
                    .padding(5)
        }
    }

    init(place: String, time: String) {
        self.place = place
        self.time = time
    }
}

struct CommuterListView: View {
    //var CommuterList: [[String]]
    var PrimaryCommuterList = ["천안 등교/하교","천안 셔틀","청주 등교/하교","청주 셔틀","서울 등교/하교","대전 등교/하교"]
    var VacationCommuterList = ["(계절/방학)천안 등교/하교","(계절/방학)천안 셔틀","(계절/방학)청주 등교/하교","(계절/방학)청주 셔틀","(방학)서울 등교/하교"]
    var CheonanCommuterList = ["천안역","터미널","두정역","고속철","신방동"]
    var CheonanVacationList = ["계절학기 터미널","계절학기 천안역","방학 터미널","계절/방학 두정역"]
    var CheongjuCommuterList = ["체육관","용암동","산남동","분평동"]
    var ExpressList = ["한기대→야우리","야우리→한기대"]
    @State var isShuttleButtonClicked = true
    @State var isExpressButtonClicked = false
    @State var isCityBusButtonClicked = false
    @State private var isPrimaryActionSheet = false
    @State private var isSecondActionSheet = false
    @State private var isExpressActionSheet = false
    @State var primary: Int = 0
    @State var expressIndex: Int = 0
    @State var secondary: Int = 0
    
    var PrimaryActionSheet: ActionSheet {
        ActionSheet(title: Text("선택"), buttons: [
                .default(Text(PrimaryCommuterList[0]), action: {self.primary = 0}),
                .default(Text(PrimaryCommuterList[1]), action: {self.primary = 1}),
                .default(Text(PrimaryCommuterList[2]), action: {self.primary = 2}),
                .default(Text(PrimaryCommuterList[3]), action: {self.primary = 3}),
                .default(Text(PrimaryCommuterList[4]), action: {self.primary = 4}),
                .default(Text(PrimaryCommuterList[5]), action: {self.primary = 5}),
                    .destructive(Text("취소"), action: {self.isPrimaryActionSheet.toggle()})
        ])
    }
    
    var ExpressActionSheet: ActionSheet {
        ActionSheet(title: Text("선택"), buttons: [
                .default(Text(ExpressList[0]), action: {self.expressIndex = 0}),
                .default(Text(ExpressList[1]), action: {self.expressIndex = 1}),
                    .destructive(Text("취소"), action: {self.isExpressActionSheet.toggle()})
        ])
    }
    
    func SecondaryActionSheet() -> ActionSheet{
        if (primary == 0) {
            return ActionSheet(title: Text("선택"), buttons: [
                .default(Text("천안역"), action: {self.secondary = 0}),
                .default(Text("터미널"), action: {self.secondary = 1}),
                .default(Text("두정역"), action: {self.secondary = 2}),
                .default(Text("고속철"), action: {self.secondary = 3}),
                .default(Text("신방동"), action: {self.secondary = 4}),
                .destructive(Text("취소"), action: {self.isSecondActionSheet.toggle()})
            ])
        } else if(primary == 2) {
            return ActionSheet(title: Text("선택"), buttons: [
                .default(Text("체육관"), action: {self.secondary = 0}),
                .default(Text("용암동"), action: {self.secondary = 1}),
                .default(Text("산남동"), action: {self.secondary = 2}),
                .default(Text("분평동"), action: {self.secondary = 3}),
                .destructive(Text("취소"), action: {self.isSecondActionSheet.toggle()})
            ])
        }
        return ActionSheet(title: Text("nothing"))
    }
    
    var body: some View {
        return ScrollView(.vertical) {
            HStack(spacing: 16){
                Button(action:{
                    self.isShuttleButtonClicked = true
                    self.isExpressButtonClicked = false
                    self.isCityBusButtonClicked = false
                }) {
                    Text("학교셔틀")
                        .foregroundColor(.white)
                        .frame(width: 96, height: 40, alignment: .center)
                        .background(RoundedRectangle(cornerRadius: 20).foregroundColor(self.isShuttleButtonClicked ? Color("squash") : Color("squash").opacity(0.3)))
                }
                
                Button(action:{
                    self.isShuttleButtonClicked = false
                    self.isExpressButtonClicked = true
                    self.isCityBusButtonClicked = false
                }) {
                    Text("대성고속")
                        .foregroundColor(.white)
                    .frame(width: 96, height: 40, alignment: .center)
                        .background(RoundedRectangle(cornerRadius: 20).foregroundColor(self.isExpressButtonClicked ? Color("shark") : Color("shark").opacity(0.3)))
                }
                
                Button(action:{
                    self.isShuttleButtonClicked = false
                    self.isExpressButtonClicked = false
                    self.isCityBusButtonClicked = true
                }) {
                    Text("시내버스")
                        .foregroundColor(.white)
                        .frame(width: 96, height: 40, alignment: .center)
                        .background(RoundedRectangle(cornerRadius: 20).foregroundColor(self.isCityBusButtonClicked ? Color("mint") : Color("mint").opacity(0.3)))
                }
            }.padding(.vertical, 25)
            
            
            if isShuttleButtonClicked {
                
                VStack {
                
                HStack {
                 HStack {
                     Text(PrimaryCommuterList[primary])
                         .padding(.vertical, 10)
                         .padding(.horizontal, 8)
                         .font(.system(size: 13))
                     .foregroundColor(Color("black"))
                         .actionSheet(isPresented: $isPrimaryActionSheet) {
                             self.PrimaryActionSheet
                     }
                     Spacer()
                     Image(systemName: "chevron.down")
                         .renderingMode(.template)
                         .foregroundColor(Color("bus_arrow_color"))
                         .frame(width: 9.9, height: 6.1)
                     .padding(.vertical, 4)
                     .padding(.horizontal, 8)
                 }.frame(width: 155, height: 38)
                     .border(Color("store_menu_border"), width: 1)
                     .padding(.leading, 10)
                     .onTapGesture {
                         self.isPrimaryActionSheet.toggle()
                    }
                 Spacer()
                    if (primary == 0) {
                     HStack {
                      Text(CheonanCommuterList[secondary])
                         .padding(.vertical, 10)
                         .padding(.horizontal, 8)
                          .font(.system(size: 13))
                      .foregroundColor(Color("black"))
                          .actionSheet(isPresented: $isSecondActionSheet) {
                                  SecondaryActionSheet()
                          }
                         Spacer()
                      Image(systemName: "chevron.down")
                          .renderingMode(.template)
                          .foregroundColor(Color("bus_arrow_color"))
                          .frame(width: 9.9, height: 6.1)
                      .padding(.vertical, 4)
                      .padding(.horizontal, 8)
                      }.frame(width: 155, height: 38)
                      .border(Color("store_menu_border"), width: 1)
                         .padding(.trailing, 10)
                      .onTapGesture {
                              self.isSecondActionSheet.toggle()
                      }
                     
                    }
                    if (primary == 2) {
                     
                     HStack {
                     Text(CheongjuCommuterList[secondary])
                        .padding(.vertical, 10)
                        .padding(.horizontal, 8)
                         .font(.system(size: 13))
                     .foregroundColor(Color("black"))
                         .actionSheet(isPresented: $isSecondActionSheet) {
                                 SecondaryActionSheet()
                         }
                        Spacer()
                     Image(systemName: "chevron.down")
                         .renderingMode(.template)
                         .foregroundColor(Color("bus_arrow_color"))
                         .frame(width: 9.9, height: 6.1)
                     .padding(.vertical, 4)
                     .padding(.horizontal, 8)
                     }.frame(width: 155, height: 38)
                     .border(Color("store_menu_border"), width: 1)
                        .padding(.trailing, 10)
                     .onTapGesture {
                             self.isSecondActionSheet.toggle()
                     }
                     
                    }
                    
                    
                }.padding(.bottom, 25)
                
                if primary == 0 {
                 
                    Rectangle()
                    .fill(Color("light_navy"))
                    .frame(height: 2)
                 
                    HStack {
                        
                        Text("승차장소")
                         .font(.system(size: 15))
                            .foregroundColor(Color("light_navy"))
                        Spacer()
                        Text("시간")
                         .font(.system(size: 15))
                        .foregroundColor(Color("light_navy"))
                        
                    }.padding(.horizontal, 10)
                    Rectangle()
                        .fill(Color("light_navy"))
                        .frame(height: 1)
                    
                    if secondary == 0 {
                        
                     ForEach(CheonanCommuterToCheonanStation, id: \.self) { l in
                            CommuterListCell(place: l[0], time: l[1])
                        }
                    } else if secondary == 1 {
                     ForEach(CheonanCommuterToTerminal, id: \.self) { l in
                            CommuterListCell(place: l[0], time: l[1])
                            
                        }
                    } else if secondary == 2 {
                     ForEach(CheonanCommuterToDujeongStation, id: \.self) { l in
                            CommuterListCell(place: l[0], time: l[1])
                        }
                    } else if secondary == 3 {
                     ForEach(CheonanCommuterToKTX, id: \.self) { l in
                            CommuterListCell(place: l[0], time: l[1])
                            
                        }
                    } else if secondary == 4 {
                     ForEach(CheonanCommuterToShinbang, id: \.self) { l in
                            CommuterListCell(place: l[0], time: l[1])
                            
                        }
                    }
                } else if primary == 1 {
                    ScrollView(.horizontal) {
                     Rectangle()
                     .fill(Color("light_navy"))
                     .frame(height: 2)
                        HStack {
                            Text("구간")
                                .frame(width: 100, alignment: .center)
                                .font(.system(size: 15))
                                .foregroundColor(Color("light_navy"))
                                .padding(5)
                            ForEach(0 ..< 12, id: \.self) { i in
                                Text("\(i+1)회")
                                    .frame(width: 50, alignment: .center)
                                .font(.system(size: 15))
                                .foregroundColor(Color("light_navy"))
                                .padding(5)
                            }
                        }
                        Rectangle()
                            .fill(Color("light_navy"))
                            .frame(height: 1)
                         ForEach(CheonanWeekdayShuttle, id: \.self) { l in
                             ShuttleListCell(content: l)
                         }
                    }
                } else if primary == 2 {
                 Rectangle()
                 .fill(Color("light_navy"))
                 .frame(height: 2)
                    HStack {
                        
                        Text("승차장소")
                         .font(.system(size: 15))
                         .foregroundColor(Color("light_navy"))
                        Spacer()
                        Text("시간")
                        .font(.system(size: 15))
                        .foregroundColor(Color("light_navy"))
                        
                    }.padding(.horizontal, 10)
                    Rectangle()
                        .fill(Color("light_navy"))
                        .frame(height: 1)
                    if secondary == 0 {
                        ForEach(CheongjuCommuterToGym, id: \.self) { l in
                            CommuterListCell(place: l[0], time: l[1])
                        }
                    } else if secondary == 1 {
                        ForEach(CheongjuCommuterToYongam, id: \.self) { l in
                            CommuterListCell(place: l[0], time: l[1])
                        }
                    } else if secondary == 2 {
                        ForEach(CheongjuCommuterToSannam, id: \.self) { l in
                            CommuterListCell(place: l[0], time: l[1])
                        }
                    } else if secondary == 3 {
                        ForEach(CheongjuCommuterToBunpyeong, id: \.self) { l in
                            CommuterListCell(place: l[0], time: l[1])
                        }
                    }
                } else if primary == 3 {
                    ScrollView(.horizontal) {
                     Rectangle()
                     .fill(Color("light_navy"))
                     .frame(height: 2)
                        HStack {
                            Text("구간")
                                .frame(width: 100, alignment: .center)
                                .font(.system(size: 15))
                                .foregroundColor(Color("light_navy"))
                                .padding(5)
                            ForEach(0 ..< 5, id: \.self) { i in
                                Text("\(i+1)회")
                                    .frame(width: 50, alignment: .center)
                                .font(.system(size: 15))
                                .foregroundColor(Color("light_navy"))
                                .padding(5)
                            }
                        }.padding(.horizontal, 10)
                        Rectangle()
                            .fill(Color("light_navy"))
                            .frame(height: 1)
                        ForEach(CheongjuShuttle, id: \.self) { l in
                            ShuttleListCell(content: l)
                        }
                    }
                } else if primary == 4 {
                    ScrollView(.horizontal) {
                     Rectangle()
                     .fill(Color("light_navy"))
                     .frame(height: 2)
                        HStack {
                            Text("등교시")
                                .frame(width: 100, alignment: .center)
                                .font(.system(size: 15))
                                .foregroundColor(Color("light_navy"))
                                .padding(5)
                                Text("운행시간")
                                    .frame(width: 100, alignment: .center)
                                    .foregroundColor(Color("light_navy"))
                                    .padding(5)
                                Text("추가운행(월,금)")
                                .frame(width: 100, alignment: .center)
                                .font(.system(size: 15))
                                .foregroundColor(Color("light_navy"))
                                .padding(5)
                        }.padding(.horizontal, 10)
                        Rectangle()
                            .fill(Color("light_navy"))
                            .frame(height: 1)
                        ForEach(SeoulCommuterToSchool, id: \.self) { l in
                            SeoulListCell(content: l)
                        }
                     Rectangle()
                     .fill(Color("light_navy"))
                     .frame(height: 2)
                        HStack {
                            Text("하교시")
                                .frame(width: 100, alignment: .center)
                                .font(.system(size: 15))
                                .foregroundColor(Color("light_navy"))
                                .padding(5)
                                Text("운행시간")
                                    .frame(width: 100, alignment: .center)
                                    .foregroundColor(Color("light_navy"))
                                    .padding(5)
                                Text("추가운행(월,금)")
                                .frame(width: 100, alignment: .center)
                                .font(.system(size: 15))
                                .foregroundColor(Color("light_navy"))
                                .padding(5)
                        }.padding(.horizontal, 10)
                        Rectangle()
                            .fill(Color("light_navy"))
                            .frame(height: 1)
                        ForEach(SeoulCommuterToSeoul, id: \.self) { l in
                            SeoulListCell(content: l)
                        }
                    }
                } else if primary == 5 {
                 Rectangle()
                 .fill(Color("light_navy"))
                 .frame(height: 2)
                    HStack {
                        
                        Text("승차장소")
                            .font(.system(size: 15))
                            .foregroundColor(Color("light_navy"))
                        Spacer()
                        Text("시간")
                        .font(.system(size: 15))
                        .foregroundColor(Color("light_navy"))
                        
                    }.padding(.horizontal, 10)
                    Rectangle()
                        .fill(Color("light_navy"))
                        .frame(height: 1)
                        ForEach(DaejeonCommuter, id: \.self) { l in
                            CommuterListCell(place: l[0], time: l[1])
                        }
                    }
                }.padding(.horizontal, 10)
            } else if isExpressButtonClicked {
                VStack {
                    HStack {
                     HStack {
                         Text(ExpressList[expressIndex])
                             .padding(.vertical, 10)
                             .padding(.horizontal, 8)
                             .font(.system(size: 13))
                         .foregroundColor(Color("black"))
                             .actionSheet(isPresented: $isExpressActionSheet) {
                                 self.ExpressActionSheet
                         }
                         Spacer()
                         Image(systemName: "chevron.down")
                             .renderingMode(.template)
                             .foregroundColor(Color("bus_arrow_color"))
                             .frame(width: 9.9, height: 6.1)
                         .padding(.vertical, 4)
                         .padding(.horizontal, 8)
                     }.frame(width: 155, height: 38)
                         .border(Color("store_menu_border"), width: 1)
                         .padding(.leading, 10)
                         .onTapGesture {
                             self.isExpressActionSheet.toggle()
                        }
                     Spacer()
                        
                        
                    }.padding(.bottom, 25)
                    
                    VStack {
                        Rectangle()
                        .fill(Color("light_navy"))
                        .frame(height: 2)

                        HStack {
                                    Text("출발시간")
                                        .foregroundColor(Color("light_navy"))
                                    .font(.system(size: 15))
                                    .frame(width: 150, alignment: .center)
                                    .padding(5)
                                    Text("도착시간")
                                        .foregroundColor(Color("light_navy"))
                                        .font(.system(size: 15))
                                        .frame(width: 150, alignment: .center)
                                        .padding(5)
                        }
                        
                           Rectangle()
                               .fill(Color("light_navy"))
                               .frame(height: 1)
                               
                    
                    
                    if expressIndex == 0 {
                        ForEach(ExpressBusFromKoreatechToTerminal, id: \.self) { l in
                            ExpressListCell(place: l[0], time: l[1])
                        }
                    } else {
                        ForEach(ExpressBusFromTerminalToKoreatech, id: \.self) { l in
                            ExpressListCell(place: l[0], time: l[1])
                        }
                    }
                    }.padding(.horizontal, 10)
                }.padding(.horizontal, 10)
 
                
            } else if isCityBusButtonClicked {
                VStack {
                    Rectangle()
                    .fill(Color("light_navy"))
                    .frame(height: 2)
                       HStack {
                           
                           Text("기점")
                               .font(.system(size: 15))
                               .foregroundColor(Color("light_navy"))
                           Spacer()
                           Text("종합터미널-병천")
                           .font(.system(size: 15))
                           .foregroundColor(Color("light_navy"))
                           
                       }.padding(.horizontal, 10)
                       Rectangle()
                           .fill(Color("light_navy"))
                           .frame(height: 1)
                           ForEach(CityBusTimeTable, id: \.self) { l in
                               CommuterListCell(place: l[0], time: l[1])
                           }
                }.padding(.horizontal, 10)
            }
            
                       
            
                   
        }
    }
}

struct BusTimeTableView: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct BusTimeTableView_Previews: PreviewProvider {
    static var previews: some View {
        CommuterListView()
    }
}
