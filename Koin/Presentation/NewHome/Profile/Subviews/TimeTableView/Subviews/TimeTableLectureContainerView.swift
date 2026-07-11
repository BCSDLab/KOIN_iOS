//
//  TimeTableLectureContainerView.swift
//  koin
//
//  Created by 홍기정 on 7/11/26.
//

import SwiftUI

enum TimeTableRow: Identifiable {
    case empty(at: Int)
    case some(LectureDataWrapper)
    
    var id: Int {
        switch self {
        case .empty(let row):
            return row
        case .some(let wrapper):
            return wrapper.id
        }
    }
}

struct TimeTableLectureContainerView: View {

    let numberOfRows: Int = 10

    var rows: [TimeTableRow] = []
    
    init(
        lectureWrappers: [LectureDataWrapper]
    ) {
        self.rows = mergeConsecutiveRows(makeRows(wrappers: lectureWrappers))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(rows) { row in
                switch row {
                case .empty:
                    TimeTableEmptyLectureView()
                        .frame(height: TimeTableView.Layout.timeHeight)
                case .some(let wrapper):
                    TimeTableLectureView(
                        headerColor: wrapper.header,
                        bodyColor: wrapper.body,
                        lecture: wrapper.lecture
                    )
                    .frame(height: TimeTableView.Layout.timeHeight * wrapper.hours)
                }
            }
        }
    }
}

extension TimeTableLectureContainerView {
    
    private func makeRows(wrappers: [LectureDataWrapper]) -> [TimeTableRow] {
        func findLecture(at time: Int) -> LectureDataWrapper? {
            return wrappers.first(where: {
                if let _ = $0.lecture.classTime.first(where: {
                    $0 % 10 == time
                }) {
                    return true
                } else {
                    return false
                }
            })
        }
        
        var result: [TimeTableRow] = []
        
        for time in 0..<numberOfRows {
            if let wrapper = findLecture(at: time) {
                result.append(TimeTableRow.some(wrapper))
            } else {
                result.append(TimeTableRow.empty(at: time))
            }
        }
        
        return result
    }
    
    private func mergeConsecutiveRows(_ wrappers: [TimeTableRow]) -> [TimeTableRow] {
        wrappers.reduce(into: [TimeTableRow]()) { (result, row) in
            switch (result.last, row) {
            case let (.some(previous), .some(current)) where previous.id == current.id:
                break
            default:
                result.append(row)
            }
        }
    }
}

