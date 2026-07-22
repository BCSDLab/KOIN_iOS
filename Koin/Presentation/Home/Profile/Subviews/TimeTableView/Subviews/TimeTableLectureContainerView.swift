//
//  TimeTableLectureContainerView.swift
//  koin
//
//  Created by 홍기정 on 7/11/26.
//

import SwiftUI

enum TimeTableRow: Identifiable {
    case empty(at: Int)
    case some(at: Int, LectureDataWrapper, times: CGFloat = 1)
    
    var id: Int {
        switch self {
        case .empty(let row):
            return row
        case .some(let row, _, _):
            return row
        }
    }
}

struct TimeTableLectureContainerView: View {

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
                        .frame(height: TimeTableView.Layout.slotHeight)
                case .some(_, let wrapper, let times):
                    TimeTableLectureView(
                        headerColor: wrapper.header,
                        bodyColor: wrapper.body,
                        lecture: wrapper.lecture
                    )
                    .frame(height: TimeTableView.Layout.slotHeight * times)
                }
            }
        }
    }
}

extension TimeTableLectureContainerView {
    
    private func makeRows(wrappers: [LectureDataWrapper]) -> [TimeTableRow] {
        func findLecture(at slot: Int) -> LectureDataWrapper? {
            return wrappers.first(where: {
                if let _ = $0.lecture.classTime.first(where: {
                    $0 % 100 == slot
                }) {
                    return true
                } else {
                    return false
                }
            })
        }
        
        var result: [TimeTableRow] = []
        
        for slot in 0..<TimeTableView.Layout.numberOfSlots {
            if let wrapper = findLecture(at: slot) {
                result.append(TimeTableRow.some(at: slot, wrapper))
            } else {
                result.append(TimeTableRow.empty(at: slot))
            }
        }
        
        return result
    }
    
    private func mergeConsecutiveRows(_ wrappers: [TimeTableRow]) -> [TimeTableRow] {
        wrappers.reduce(into: [TimeTableRow]()) { (result, newRow) in
            if var lastRow = result.last,
               case let .some(row, lastWrapper, times) = lastRow,
               case .some(_, let newWrapper, _) = newRow,
               lastWrapper.lecture.id == newWrapper.lecture.id {
                lastRow = TimeTableRow.some(at: row, lastWrapper, times: times + 1)
                result[result.count - 1] = lastRow
                return
            }
            result.append(newRow)
        }
    }
}
