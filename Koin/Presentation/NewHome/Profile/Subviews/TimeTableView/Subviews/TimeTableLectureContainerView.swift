//
//  TimeTableLectureContainerView.swift
//  koin
//
//  Created by 홍기정 on 7/11/26.
//

import SwiftUI

enum TimeTableRow: Identifiable {
    case empty(at: Int)
    case some(at: Int, LectureDataWrapper)
    
    var id: Int {
        switch self {
        case .empty(let row):
            return row
        case .some(let row, _):
            return row
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
                case .some(_, let wrapper):
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
        func findLecture(at row: Int) -> LectureDataWrapper? {
            return wrappers.first(where: {
                if let _ = $0.lecture.classTime.first(where: {
                    $0 % 10 == row
                }) {
                    return true
                } else {
                    return false
                }
            })
        }
        
        var result: [TimeTableRow] = []
        
        for row in 0..<numberOfRows {
            if let wrapper = findLecture(at: row) {
                result.append(TimeTableRow.some(at: row, wrapper))
            } else {
                result.append(TimeTableRow.empty(at: row))
            }
        }
        
        return result
    }
    
    private func mergeConsecutiveRows(_ wrappers: [TimeTableRow]) -> [TimeTableRow] {
        wrappers.reduce(into: [TimeTableRow]()) { (result, newRow) in
            if let lastRow = result.last,
               case .some(_, let lastWrapper) = lastRow,
               case .some(_, let newWrapper) = newRow,
               lastWrapper.lecture.id != newWrapper.lecture.id {
                result.append(newRow)
            }
        }
    }
}

