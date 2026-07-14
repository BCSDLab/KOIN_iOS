//
//  TimeTableHourView.swift
//  koin
//
//  Created by 홍기정 on 7/11/26.
//

import SwiftUI

struct TimeTableHourView: View {
    
    let hours: ClosedRange<Int> = 9...18
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(hours, id: \.self) { hour in
                Text("\(hour)")
                    .font(.appFont(.pretendardMedium, size: 12))
                    .foregroundStyle(Color.appColor(.neutral500))
                    .frame(
                        width: TimeTableView.Layout.timeWidth,
                        height: TimeTableView.Layout.timeHeight,
                        alignment: .center)
                    .border(
                        hours.last == hour ? .clear : .appColor(.neutral100),
                        width: TimeTableView.Layout.Separator.bold,
                        edges: [.bottom]
                    )
            }
        }
//        .border( // MARK: - HStack으로 조립할 때 하기!
//            .appColor(.neutral100),
//            width: 1,
//            edges: [.trailing]
//        )
    }
}
