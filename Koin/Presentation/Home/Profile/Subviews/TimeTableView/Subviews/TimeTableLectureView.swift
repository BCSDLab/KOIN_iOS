//
//  TimeTableLectureView.swift
//  koin
//
//  Created by 홍기정 on 7/11/26.
//

import SwiftUI

struct TimeTableLectureView: View {
    let headerColor: TimetableColorAsset
    let bodyColor: TimetableColorAsset
    let lecture: LectureData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(lecture.name)
                .lineLimit(2, reservesSpace: false)
                .font(.appFont(.pretendardMedium, size: 10))
                .linespacing(fontSize: 10, percent: 140)
                .foregroundStyle(Color.appColor(.neutral800))
            
            Color.clear
                .frame(height: 4)
            
            Text(lecture.professor)
                .font(.appFont(.pretendardRegular, size: 8))
                .linespacing(fontSize: 8, percent: 160)
                .foregroundStyle(Color.appColor(.neutral800))
            
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 4)
        .padding(.top, 7)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(hex: bodyColor.hex))
        .border(
            Color(hex: headerColor.hex),
            width: TimeTableView.Layout.headerWidth,
            edges: [.top])
    }
}
