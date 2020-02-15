//
//  BusTimeTableView.swift
//  dev_koin
//
//  Created by 정태훈 on 2020/02/09.
//  Copyright © 2020 정태훈. All rights reserved.
//

import SwiftUI





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
let VacationSeoulCommuterArrivalSchool:[[String]] = [
    ["대학","18:10"],
    ["죽전간이정류장","하차"],
    ["교대","하차"]
]
let VacationSeoulCommuterArrivalSeoul:[[String]] = [
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
let VacationCheonanCycle:[[String]] = [
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
//천안주간, 천안주말, 청주, 서울, 대전

struct CommuterListCell: View {
    let place: String
    let time: String
    init(place: String, time: String) {
        self.place = place
        self.time = time
    }
    var body: some View {
        return HStack {
            Text(place)
            Spacer()
            Text(time)
        }
    }
}

struct CommuterListView: View {
    var CommuterList: [[String]]
    
    init(list: [[String]] ) {
        self.CommuterList = list
    }
    var body: some View {
        VStack {
            HStack {
                Text("승차장소")
                    .foregroundColor(Color("light_navy"))
                Spacer()
                Text("시간")
                .foregroundColor(Color("light_navy"))
            }.padding(.horizontal, 20)
            Rectangle()
                .fill(Color("light_navy"))
                .frame(height: 1)
            .padding(.horizontal, 10)
            List(CommuterList, id: \.self) { l in
                CommuterListCell(place: l[0], time: l[1])
            }.padding(.horizontal, 10)
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
        CommuterListView(list: VacationCheonanCommuterToDujeongStation)
    }
}
