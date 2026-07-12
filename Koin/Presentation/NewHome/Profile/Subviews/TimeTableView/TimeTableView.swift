//
//  TimeTableView.swift
//  koin
//
//  Created by 홍기정 on 7/11/26.
//

import SwiftUI

struct LectureDataWrapper: Identifiable {
    let lecture: LectureData
    let header: TimetableColorAsset
    let body: TimetableColorAsset
    let hours: CGFloat
    
    let id: Int
    
    init(
        lecture: LectureData,
        header: TimetableColorAsset,
        body: TimetableColorAsset
    ) {
        self.lecture = lecture
        self.header = header
        self.body = body
        
        self.id = lecture.id
        self.hours = CGFloat(lecture.classTime.count)
    }
}

struct TimeTableView: View {
    
    // MARK: - Layout
    enum Layout {
        static let topInset: CGFloat = 9
        static let dayHeight: CGFloat = 16
        static let timeWidth: CGFloat = 30
        static let timeHeight: CGFloat = 29
        static let headerWidth: CGFloat = 2
        enum Separator {
            static let bold: CGFloat = 1
            static let thin: CGFloat = 0.5
        }
    }
    
    // MARK: - Properties
    private let timetableColors: [(body: TimetableColorAsset, header: TimetableColorAsset)] = [
        (.body1, .header1),
        (.body2, .header2),
        (.body3, .header3),
        (.body4, .header4),
        (.body5, .header5),
        (.body6, .header6),
        (.body7, .header7),
        (.body8, .header8),
        (.body9, .header9),
        (.body10, .header10),
        (.body11, .header11),
        (.body12, .header12),
        (.body13, .header13),
        (.body14, .header14),
        (.body15, .header15)
    ]
    
    private var wrappers: [[LectureDataWrapper]] = [[], [], [], [], []]
    private let timeTableTapped: ()->Void
    
    // MARK: - Initializer
    init(
        lectures: [LectureData],
        timeTableTapped: @escaping ()->Void
    ) {
        self.timeTableTapped = timeTableTapped
        self.wrappers = splitInDays(makeWrapper(lectures))
    }
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 12) {
            Text("내 시간표")
                .font(.appFont(.pretendardSemiBold, size: 18))
                .foregroundStyle(Color.ColorSystem.Neutral.gray800)
                .frame(maxWidth: .infinity, idealHeight: 29, alignment: .leading)
            
            Button(action: timeTableTapped) {
                VStack(spacing: 0) {
                    Spacer(minLength: Layout.topInset)
                    
                    TimeTableDayView()
                    
                    HStack(spacing: 0) {
                        TimeTableHourView()
                            .border(.appColor(.neutral100), width: Layout.Separator.bold, edges: [.trailing])
                        Group {
                            TimeTableLectureContainerView(lectureWrappers: wrappers[0])
                            TimeTableLectureContainerView(lectureWrappers: wrappers[1])
                            TimeTableLectureContainerView(lectureWrappers: wrappers[2])
                            TimeTableLectureContainerView(lectureWrappers: wrappers[3])
                            TimeTableLectureContainerView(lectureWrappers: wrappers[4])
                        }
                        .frame(maxWidth: .infinity)
                        .border(.appColor(.neutral100), width: Layout.Separator.thin, edges: [.trailing])
                    }
                }
                .background {
                    Color.appColor(.neutral0)
                }
                .clipShape(RoundedRectangle(cornerRadius: 20))
            }
            .buttonStyle(.plain)
        }
    }
}

extension TimeTableView {
    
    private func makeWrapper(_ lectures: [LectureData]) -> [LectureDataWrapper] {
        // lecture(classTime: [0, 1, 5, 6]) 를 lecture(classTime: [0, 1]), lecture(classTime: [5, 6]) 으로 나눔
        func splitLecture() -> [LectureData] {
            lectures.flatMap { lecture in
                let classTimes = lecture.classTime
                    .sorted()
                    .reduce(into: [[Int]]()) { (classTimes, classTime) in
                        if let lastClassTime = classTimes.last?.last,
                           lastClassTime / 100 == classTime / 100,
                           lastClassTime + 1 == classTime {
                            classTimes[classTimes.count - 1].append(classTime)
                        } else {
                            classTimes.append([classTime])
                        }
                    }
                return classTimes.map { classTime in
                    var lecture = lecture
                    lecture.classTime = classTime
                    return lecture
                }
            }
        }
        
        // lecture id 마다 고유한 colors 인덱스를 지정
        let colorIndex = lectures.reduce(into: [Int: Int]()) { (result, lecture) in
            result[lecture.id] = min(result[lecture.id] ?? result.count, timetableColors.count - 1)
        }
        
        // wrapper로 변환
        return splitLecture().map { lecture in
            LectureDataWrapper(
                lecture: lecture,
                header: timetableColors[colorIndex[lecture.id] ?? 0].header,
                body: timetableColors[colorIndex[lecture.id] ?? 0].body
            )
        }
    }
    
    private func splitInDays(_ wrappers: [LectureDataWrapper]) -> [[LectureDataWrapper]] {
        var result: [[LectureDataWrapper]] = [[], [], [], [], []]
        
        for wrapper in wrappers {
            guard let classTime = wrapper.lecture.classTime.first else {
                print("classTime 배열이 비어있음")
                continue
            }
            let day = classTime / 100
            guard result.indices.contains(day) else {
                print("index 범위 오류")
                continue
            }
            result[day].append(wrapper)
        }
        
        return result
    }
}
