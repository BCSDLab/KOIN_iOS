//
//  TimeTableView.swift
//  Koin
//
//  Created by 정태훈 on 2020/07/20.
//  Copyright © 2020 정태훈. All rights reserved.
//

import SwiftUI
import Foundation

struct TimeTableView: View {
    
    @ObservedObject var viewModel: TimeTableViewModel
    @EnvironmentObject var tabData: ViewRouter
    @EnvironmentObject var userData: UserConfig
    
    @State private var showLectures = false
    @State private var showLectureDetail = false
    @State private var showSemester = false
    
    @State private var timeTableRect: CGRect = .zero
    @State private var uiimage: UIImage? = nil
    
    @State private var showingAlert = false
    @State private var showingDuplicate = false
    @State private var duplicateTime = -1
    
    let imageSaver = ImageSaver()
    
    init() {
        self.viewModel = TimeTableViewModel()
    }
    
    func generateActionSheet(options: [Semester]) -> ActionSheet {
        let buttons = options.map { option in
            Alert.Button.default(Text("\(String(option.semester.prefix(4)))년 \(String(option.semester.suffix(1)))학기"), action: {
                self.viewModel.semester = option.semester
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.viewModel.load(token: self.userData.token)
                    self.viewModel.getLectures()
                }
            } )
        }
        return ActionSheet(title: Text("학기를 선택해주세요."),
                           buttons: buttons + [Alert.Button.cancel()])
    }
    
    var TimeTableAlertDialog: Alert {
        if(self.showingDuplicate) {
            return Alert(title: Text("시간 중복"), message: Text("선택한 시간에 이미 다른수업이 있습니다.\n바꾸시겠습니까?"),primaryButton: .default(Text("확인")) {
                
                var deletedLectures: [Lecture] = []
                
                self.viewModel.data.timetable.forEach { l in
                    self.viewModel.selectedLecture?.classTime.forEach { c in
                        if (!deletedLectures.contains(l) && l.classTime.contains(c)) {
                            deletedLectures.append(l)
                        }
                    }
                }
                
                deletedLectures.forEach { d in
                    DispatchQueue.main.async {
                        self.viewModel.deleteLecture(token: self.userData.token, lecture: d)
                    }
                }
                
                self.viewModel.addLecture(token: self.userData.token, lecture: self.viewModel.selectedLecture!)
                self.viewModel.selectedLecture = nil
                
                self.showingAlert = false
                self.showingDuplicate = false
                }, secondaryButton: .cancel(Text("취소")))
        } else {
            return Alert(title: Text("수업 삭제"), message: Text("해당 수업을 삭제하시겠습니까?"), primaryButton: .default(Text("확인")) {
                    self.viewModel.deleteLecture(token: self.userData.token, lecture: self.viewModel.detailLecture!)
                    self.showLectureDetail = false
                    self.showingAlert = false
                }, secondaryButton: .cancel(Text("취소")))
        }
    }
    
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
    
    func getClassTime(list: Array<Int>) -> String {
        var center: Array<Int> = []
        var classTime: String = ""
        
        if(list.isEmpty) {
            return ""
        } else {
            center.append(list[0])
            for i in 1..<list.count-1 {
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
                switch(Int(center[i]/100)) {
                    case 0:
                        classTime = classTime + "월 "
                        break
                    case 1:
                        classTime = classTime + "화 "
                        break
                    case 2:
                        classTime = classTime + "수 "
                        break
                    case 3:
                        classTime = classTime + "목 "
                        break
                    case 4:
                        classTime = classTime + "금 "
                        break
                    default:
                        break
                }
                for t in center[i]..<center[i+1] {
                    let time: Int = Int((t % 100)/2)
                    let subTime: String = (t % 2) == 1 ? "B" : "A"
                    
                    classTime = classTime + "\(time+1)\(subTime),"
                }
                classTime = classTime + "\(Int((center[i+1] % 100)/2)+1)\((center[i+1] % 2) == 1 ? "B" : "A") "
            }
            
            
            return classTime
        }
    }
    
    
    func getHeight(start: Int, end: Int) -> CGFloat {
        return CGFloat(25*(end-start+1))
    }
        
    func getX(start: Int, width: Double) -> CGFloat {
        return CGFloat(0.2 * width * Double(start + 1) - (12.0 * Double(start)) - ((width - 60)/25*3.5) + 1.5)
    }
    
    func getY(start: Int, end: Int) -> CGFloat {
        return CGFloat(25 / 2 * (end-start+1) + (25*(start-Int(start/100)*100)))
    }
    
    var body: some View {
        GeometryReader{ geometry in
            ZStack{
                VStack{
                    HStack(spacing: 15){
                        Button(action: {
                            self.showSemester = true
                        }) {
                            HStack{
                                Text(self.viewModel.semester.isEmpty ? "" : "\(String(self.viewModel.semester.prefix(4)))년 \(String(self.viewModel.semester.suffix(1)))학기")
                                    .foregroundColor(.black)
                            }
                            .frame(maxWidth: .infinity, minHeight : 40)
                            .border(Color(red: 210/255, green: 218/255, blue: 226/255), width: 1)
                        }
                        Button(action: {
                            let image = UIApplication.shared.windows[0].rootViewController?.view.asImage(rect: self.timeTableRect)
                            self.imageSaver.writeToPhotoAlbum(image: image!)
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
                                            }.frame(width: 60,height: 25)
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
                                            }.frame(width: 60,height: 25)
                                        }
                                        .frame(width: 60,height: 50)
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
                                        ForEach(self.viewModel.data.timetable, id: \.self) { lecture in
                                            ForEach(self.filterClassTime(list: lecture.classTime), id: \.self) { duration in
                                                VStack(alignment: .leading){
                                                    Text(lecture.classTitle ?? "")
                                                        .font(.system(size: 9))
                                                        .fontWeight(.medium)
                                                        .padding(.bottom, 8)
                                                        .padding(.top, 4)
                                                    Text("\(lecture.lectureClass) \(lecture.professor)")
                                                        .font(.system(size: 9))
                                                        .fontWeight(.regular)
                                                }.padding(.horizontal,4)
                                                    .frame(width: (geometry.size.width - 60)/5+1, height: self.getHeight(start: duration.start, end: duration.end), alignment: .top)
                                                    .background(self.colors[(lecture.id ??  Int.random(in: 0...10) ) % 10])
                                                    .border(Color(red: 244/255, green: 244/255, blue: 244/255), width: 0.5)
                                                    .onTapGesture {
                                                        self.viewModel.setDetailLecture(lecture: lecture)
                                                        self.showLectureDetail = true
                                                        self.showLectures = false
                                                    }
                                                    .position(x: self.getX(start: Int(floor(Double(duration.start)/100.0)), width: Double(geometry.size.width)), y: self.getY(start: duration.start, end: duration.end)+1.5)
                                                    
                                            }
                                        }
                                        
                                        if(self.viewModel.selectedLecture != nil) {
                                            ForEach(self.filterClassTime(list: self.viewModel.selectedLecture!.classTime), id: \.self) { duration in
                                                Rectangle()
                                                    
                                                    .foregroundColor(Color.white)
                                                    .frame(width: (geometry.size.width - 60)/5+1, height: self.getHeight(start: duration.start, end: duration.end), alignment: .top)
                                                    .border(Color.red, width: 1)
                                                .position(x: self.getX(start: Int(floor(Double(duration.start)/100.0)), width: Double(geometry.size.width)), y: self.getY(start: duration.start, end: duration.end)+1.5)
                                                
                                            }
                                        }
                                    }
                                    
                                    
                                }
                                
                            }
                        }.background(RectGetter(rect: self.$timeTableRect))
                    }
                }
                .gridStyle(
                    StaggeredGridStyle(.vertical, tracks: .fixed((geometry.size.width - 60)/5), spacing: 0)
                )
                    .actionSheet(isPresented: self.$showSemester) {
                        self.generateActionSheet(options: self.viewModel.semesters)
                }
                    .navigationBarTitle("시간표", displayMode: .inline)
                    .navigationBarItems(trailing: Button(action: {
                        self.showLectureDetail = false
                        self.showLectures = true
                    }) {
                        Text("작성")
                            .font(.system(size: 17))
                            .foregroundColor(.white)
                    })
                    
                Group{
                        BottomSheetModal(display: self.$showLectures) {
                            VStack(spacing: 0){
                                ZStack{
                                    Text("수업 추가")
                                        .font(.system(size: 15))
                                        .fontWeight(.medium)
                                        .foregroundColor(Color("light_navy"))
                                        .frame(height: 48,alignment: .center)
                                    Button(action: {
                                        self.showLectures = false
                                        self.viewModel.selectedLecture = nil
                                    }) {
                                        Text("완료")
                                            .font(.system(size: 15))
                                            .foregroundColor(Color("black"))
                                            .padding(.trailing, 16)
                                    }
                                    .frame(maxWidth: .infinity, minHeight: 48, alignment: .trailing)
                                }
                                Rectangle()
                                    .border(Color("cloudy_blue"))
                                    .frame(maxWidth: .infinity, maxHeight: 1)
                                HStack(spacing: 0){
                                    Image(systemName: "slider.horizontal.3")
                                        .scaledToFit()
                                        .frame(height: 24)
                                        .padding(.trailing, 16)
                                    
                                    VStack{
                                        TextField("", text: self.$viewModel.query)
                                            .font(.system(size: 14))
                                            .foregroundColor(Color("black"))
                                            .padding(.horizontal, 16)
                                    }.frame(maxWidth: .infinity, minHeight : 36)
                                        .border(Color(red: 210/255, green: 218/255, blue: 226/255), width: 1)
                                    
                                }.frame(maxWidth: .infinity, minHeight: 48, alignment: .trailing)
                                    .padding(.horizontal, 16)
                                Rectangle()
                                    .border(Color("cloudy_blue"))
                                    .frame(maxWidth: .infinity, maxHeight: 1)
                                List(self.viewModel.lectures.filter({ self.viewModel.query.isEmpty ? true : $0.name!.contains(self.viewModel.query)}), id: \.self) { l in
                                    HStack{
                                        VStack(alignment: .leading){
                                            Text(l.name ?? "")
                                                .font(.system(size: 15))
                                                .foregroundColor(Color("black"))
                                                .padding(.bottom, 12)
                                            // 추가: classTime
                                            Text("\(self.getClassTime(list: l.classTime))\(l.classPlace ?? "") / \(l.grades)학점 / \(l.code) / \(l.professor)")
                                                .font(.system(size: 13))
                                                .foregroundColor(Color("black"))
                                        }
                                        Spacer()
                                        
                                        Group{
                                            if(self.viewModel.data.timetable.contains{ t in
                                                t.code == l.code && t.lectureClass == l.lectureClass
                                            }) {
                                                Button(action: {
                                                    let lecture: Lecture? = self.viewModel.data.timetable.first { t in
                                                        t.code == l.code && t.lectureClass == l.lectureClass
                                                    }
                                                    self.viewModel.deleteLecture(token: self.userData.token, lecture: lecture!)
                                                }) {
                                                    Image(systemName: "minus.circle.fill")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 24, alignment: .center)
                                                        .foregroundColor(Color(red: 255/255, green: 108/255, blue: 108/255))
                                                }
                                            } else {
                                                Button(action: {
                                                    if(self.viewModel.selectedLecture != nil && self.viewModel.selectedLecture!.code == l.code && self.viewModel.selectedLecture!.lectureClass == l.lectureClass) {
                                                        let duplicateResult = self.viewModel.checkDuplicate(classTime: l.classTime)
                                                        
                                                        if(duplicateResult.0) {
                                                            self.duplicateTime = duplicateResult.1
                                                            self.showingDuplicate = true
                                                            self.showingAlert = true
                                                        } else {
                                                            self.viewModel.addLecture(token: self.userData.token, lecture: l)
                                                            self.viewModel.selectedLecture = nil
                                                        }
                                                        
                                                    } else {
                                                        self.viewModel.selectedLecture = l
                                                    }
                                                    
                                                }) {
                                                    Image(systemName: "plus.circle.fill")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 24, alignment: .center)
                                                        .foregroundColor(Color(red: 77/255, green: 178/255, blue: 151/255))
                                                }
                                            }
                                        }
                                        
                                    }.frame(height: 80)
                                }
                            }
                            
                            
                        }
                        BottomSheetModal(display: self.$showLectureDetail) {
                            VStack(spacing: 0){
                                HStack{
                                    Button(action: {
                                        self.showingAlert = true
                                    }) {
                                        Text("삭제")
                                            .font(.system(size: 15))
                                            .foregroundColor(Color("squash"))
                                            .padding(.leading, 16)
                                    }
                                    .frame(minHeight: 48, alignment: .trailing)
                                    Spacer()
                                    Text("수업 상세")
                                        .font(.system(size: 15))
                                        .fontWeight(.medium)
                                        .foregroundColor(Color("light_navy"))
                                        .frame(height: 48,alignment: .center)
                                    Spacer()
                                    Button(action: {
                                        self.showLectureDetail = false
                                    }) {
                                        Text("완료")
                                            .font(.system(size: 15))
                                            .foregroundColor(Color("black"))
                                            .padding(.trailing, 16)
                                    }
                                    .frame(minHeight: 48, alignment: .trailing)
                                }
                                Rectangle()
                                    .border(Color("cloudy_blue"))
                                    .frame(maxWidth: .infinity, maxHeight: 1)
                                
                                VStack(alignment: .leading, spacing: 0){
                                    Text(self.viewModel.detailLecture?.classTitle ?? "aaa")
                                        .font(.system(size: 15))
                                        .fontWeight(.medium)
                                        .foregroundColor(Color("black"))
                                        .padding(.bottom, 21)
                                    Text("\(self.getClassTime(list: self.viewModel.detailLecture?.classTime ?? []))\n\(self.viewModel.detailLecture?.department ?? "") / \(self.viewModel.detailLecture?.code ?? "") / \(self.viewModel.detailLecture?.grades ?? "")학점 / \(self.viewModel.detailLecture?.professor ?? "")")
                                        .font(.system(size: 15))
                                        .fontWeight(.regular)
                                        .foregroundColor(Color("black"))
                                }.frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 16)
                                .padding(.vertical, 21)
                                
                                
                                
                                
                                
                            }
                            
                            
                        }
                }
            }
            .alert(isPresented: self.$showingAlert) {
                self.TimeTableAlertDialog
            }
        }.onAppear{
            DispatchQueue.main.async {
                self.viewModel.getSemester()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.viewModel.load(token: self.userData.token)
                self.viewModel.getLectures()
            }
            
        }
    }
}

struct TimeTableView_Previews: PreviewProvider {
    static var previews: some View {
        TimeTableView()
    }
}
