//
//  TimeTableDayView.swift
//  koin
//
//  Created by 홍기정 on 7/11/26.
//

import SwiftUI

struct TimeTableDayView: View {
    
    private let days: [String] = ["월", "화", "수", "목", "금"]
    
    var body: some View {
        HStack {
            Color.clear
                .frame(
                    width: TimeTableView.Layout.timeWidth,
                    height: TimeTableView.Layout.dayHeight
                )
            
            ForEach(days, id: \.self) { day in
                Text(day)
                    .font(.appFont(.pretendardMedium, size: 12))
                    .foregroundStyle(Color.appColor(.neutral500))
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .border(
            .appColor(.neutral100),
            width: TimeTableView.Layout.Separator.bold,
            edges: [.bottom]
        )
    }
}
