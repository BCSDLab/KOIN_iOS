//
//  MainTimetableFrame.swift
//  koin
//
//  Created by 홍기정 on 11/8/26.
//

/// 가장 최근 학기의 메인 시간표.
struct MainTimetableFrame: Equatable {
    let semester: String
    let frameName: String
    let lectures: [LectureData]
}
