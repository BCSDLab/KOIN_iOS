//
//  TimeTableEmptyView.swift
//  koin
//
//  Created by 홍기정 on 7/11/26.
//

import SwiftUI

struct TimeTableEmptyLectureView: View {
    
    var body: some View {
        VStack(spacing: 0) {
            Group {
                Color.clear
                
                Color.clear
            }
            .frame(maxHeight: .infinity)
            .border(
                Color.appColor(.neutral100),
                width: TimeTableView.Layout.Separator.thin,
                edges: [.bottom, .trailing])
        }
        .frame(height: TimeTableView.Layout.timeHeight)
    }
}
