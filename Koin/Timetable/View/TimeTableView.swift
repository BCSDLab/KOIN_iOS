//
//  TimeTableView.swift
//  Koin
//
//  Created by 정태훈 on 2020/07/20.
//  Copyright © 2020 정태훈. All rights reserved.
//

import SwiftUI
import Foundation

struct TimeDuration {
    let start: Int
    let end: Int
}

extension TimeDuration: Hashable {
    static func == (lhs: TimeDuration, rhs: TimeDuration) -> Bool {
        return lhs.start == rhs.start
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.start)
    }
}

struct TimeTableView: View {
    
    let data: TimeTables = TimeTables(
        semester: "20202",
        timetable: [
            Lecture(id: 801, code: "HRD170", classTitle: "창의력개발실습", classPlace: nil, memo: nil, grades: "2",
                    lectureClass: "01", regularNumber: "50", department: "HRD학과", target: "전체", professor: "유민희", designScore: "0", classTime: [
                100,
                101,
                102,
                103
            ]),
            Lecture(id: 802, code: "CPS343", classTitle: "소프트웨어공학", classPlace: nil, memo: nil, grades: "3",
                    lectureClass: "02", regularNumber: "50", department: "HRD학과", target: "컴부3", professor: "김승희", designScore: "0", classTime: [
                        104,
                        105,
                        106,
                        107,
                        304,
                        305
            ])
        ]
    )
    
    let colors: Array<Color> = [
        Color(red: 253/255, green: 188/255, blue: 245/255),
        Color(red: 255/255, green: 169/255, blue: 183/255),
        Color(red: 255/255, green: 181/255, blue: 136/255),
        Color(red: 138/255, green: 233/255, blue: 255/255),
        Color(red: 96/255, green: 228/255, blue: 193/255),
        Color(red: 180/255, green: 191/255, blue: 255/255),
        Color(red: 254/255, green: 219/255, blue: 143/255),
        Color(red: 194/255, green: 238/255, blue: 173/255),
        Color(red: 114/255, green: 176/255, blue: 255/255),
        Color(red: 224/255, green: 229/255, blue: 235/255),
    ]
    
    func filterClassTime(list: Array<Int>) -> Array<TimeDuration> {
        var center: Array<Int> = []
        var result: Array<TimeDuration> = []
        
        center.append(list[0])
        for i in 1..<list.count-1 {
            print(list[i-1], list[i], list[i+1])
            if(list[i] + 1 == list[i+1] && list[i-1] + 1 == list[i]) {
                continue
            } else if(list[i-1] + 1 != list[i] && list[i] + 1 == list[i+1]){
                center.append(list[i])
            } else if(list[i-1] + 1 == list[i] && list[i] + 1 != list[i+1]) {
                center.append(list[i])
            } else {
                continue
            }
        }
        center.append(list[list.count - 1])
        
        for i in stride(from: 0, to: center.count, by: 2) {
            result.append(TimeDuration(start: center[i], end: center[i+1]))
        }
        
        
        return result
    }
    
    func getHeight(start: Int, end: Int) -> CGFloat {
        return CGFloat(25*(end-start+1))
    }
    
    func getX(start: Int, width: Double) -> CGFloat {
        return CGFloat(0.2 * width * Double(start + 1) - (12.0 * Double(start)) - 44)
    }
    
    func getY(start: Int, end: Int) -> CGFloat {
        return CGFloat(25 / 2 * (end-start+1) + (25*(start-Int(start/100)*100)))
    }
    
    var body: some View {
        GeometryReader{ geometry in
            VStack{
                HStack(spacing: 15){
                    Button(action: {
                        print("aa")
                    }) {
                        HStack{
                            Text("2020년 1학기")
                                .foregroundColor(.black)
                        }
                            .frame(maxWidth: .infinity, minHeight : 40)
                        .border(Color(red: 210/255, green: 218/255, blue: 226/255), width: 1)
                    }
                    Button(action: {
                        print("aa")
                    }) {
                        Text("이미지로 저장하기")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, minHeight : 40)
                        .background(Color("light_navy"))
                    }
                }.padding(.horizontal, 20)
                    .padding(.top, 10)
                ScrollView {
                    VStack(spacing: 0){
                        
                        // MARK: 요일
                        HStack(spacing: 0) {
                            Spacer()
                            ForEach(["월","화","수","목","금"], id: \.self) { weekday in
                                Text(weekday)
                                    .font(.system(size: 11))
                                    .foregroundColor(Color(red: 85/255, green: 85/255, blue: 85/255))
                                    .frame(maxWidth: (geometry.size.width - 60)/5,minHeight: 20)
                            }
                            .frame(maxWidth: (geometry.size.width - 60)/5,minHeight: 20)
                        }.background(Color(red: 241/255, green: 241/255, blue: 241/255))
                        
                        HStack(spacing: 0){
                            // MARK: 시간표 교시/시간
                            VStack(spacing: 0){
                                ForEach((9...18), id: \.self) { t in
                                    VStack(spacing: 0){
                                        HStack(spacing: 0){
                                            Text("\(String(format: "%02d", t-8))A")
                                                .font(.system(size: 9))
                                                .foregroundColor(Color(red: 37/255, green: 37/255, blue: 37/255))
                                                .frame(width: 30,height: 25, alignment: .center)
                                            Rectangle()
                                                .frame(width: 1)
                                                .border(Color(red: 218/255, green: 218/255, blue: 218/255), width: 1)
                                            Text("\(String(format: "%02d", t)):00")
                                                .font(.system(size: 9))
                                                .foregroundColor(Color(red: 37/255, green: 37/255, blue: 37/255))
                                                .frame(width: 30,height: 25, alignment: .center)
                                        }.frame(maxWidth: 60,maxHeight: 25)
                                        Rectangle()
                                            .frame(height: 1)
                                            .border(Color(red: 244/255, green: 244/255, blue: 244/255), width: 1)
                                        HStack(spacing: 0){
                                            Text("\(String(format: "%02d", t-8))B")
                                                .font(.system(size: 9))
                                                .foregroundColor(Color(red: 37/255, green: 37/255, blue: 37/255))
                                                .frame(width: 30,height: 25, alignment: .center)
                                            Rectangle()
                                                .frame(width: 1)
                                                .border(Color(red: 218/255, green: 218/255, blue: 218/255), width: 1)
                                            Text("\(String(format: "%02d", t)):30")
                                                .font(.system(size: 9))
                                                .foregroundColor(Color(red: 37/255, green: 37/255, blue: 37/255))
                                                .frame(width: 30,height: 25, alignment: .center)
                                        }.frame(maxWidth: 60,maxHeight: 25)
                                    }
                                    .frame(maxWidth: 60,maxHeight: 50)
                                    .border(Color(red: 218/255, green: 218/255, blue: 218/255), width: 1)
                                    .foregroundColor(.white)
                                }
                            }
                            
                            ZStack{
                                // MARK: 시간표 목록 배경
                                Grid((1...50), id: \.self) { index in
                                    VStack{
                                        Rectangle()
                                            .frame(height: 1)
                                            .border(Color(red: 244/255, green: 244/255, blue: 244/255), width: 1)
                                    }
                                    .frame(maxWidth: (geometry.size.width - 60)/5,minHeight: 50)
                                    .border(Color(red: 218/255, green: 218/255, blue: 218/255), width: 1)
                                    .foregroundColor(.white)
                                }
                                Group{
                                    ForEach(self.data.timetable, id: \.self) { lecture in
                                        ForEach(self.filterClassTime(list: lecture.classTime), id: \.self) { duration in
                                            VStack(alignment: .leading){
                                                Text(lecture.classTitle)
                                                    .font(.system(size: 9))
                                                    .fontWeight(.medium)
                                                    .padding(.bottom, 8)
                                                    .padding(.top, 4)
                                                Text("\(lecture.lectureClass) \(lecture.professor)")
                                                    .font(.system(size: 9))
                                                    .fontWeight(.regular)
                                            }
                                            .frame(width: (geometry.size.width - 60)/5+1, height: self.getHeight(start: duration.start, end: duration.end), alignment: .top)
                                            .background(self.colors[lecture.id % 10])
                                            .border(Color(red: 244/255, green: 244/255, blue: 244/255), width: 0.5)
                                            .position(x: self.getX(start: Int(floor(Double(duration.start)/100.0)), width: Double(geometry.size.width)), y: self.getY(start: duration.start, end: duration.end)+1.5)
                                        }
                                    }
                                }
                                
                                
                            }
                            
                        }
                    }
                }
            }
            .gridStyle(
                StaggeredGridStyle(.vertical, tracks: .fixed((geometry.size.width - 60)/5), spacing: 0)
            )
                .navigationBarTitle("시간표", displayMode: .inline)
        }
    }
}

struct TimeTableView_Previews: PreviewProvider {
    static var previews: some View {
        TimeTableView()
    }
}
