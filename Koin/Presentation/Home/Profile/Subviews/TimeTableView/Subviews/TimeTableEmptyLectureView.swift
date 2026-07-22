//
//  TimeTableEmptyView.swift
//  koin
//
//  Created by 홍기정 on 7/11/26.
//

import SwiftUI

struct TimeTableEmptyLectureView: View {
    
    var body: some View {
        Color.clear
            .border(
                Color.appColor(.neutral100),
                width: TimeTableView.Layout.Separator.thin,
                edges: [.bottom, .trailing])
    }
}
