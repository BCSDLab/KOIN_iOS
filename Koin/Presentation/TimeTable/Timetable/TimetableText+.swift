//
//  TimetableText+.swift
//  koin
//
//  Created by 김나훈 on 12/4/24.
//

import Foundation

extension Array where Element == Int {
    func timeLabelText() -> String {
        guard !self.isEmpty else { return "" }

        let days = ["월", "화", "수", "목", "금"]
        var timetable = [(day: Int, start: Int, end: Int)]()
        var previousDay = -1
        var start = -1
        var end = -1

        for time in self.sorted() {
            let day = time / 100
            let slot = time % 100

            if day != previousDay || (start != -1 && slot != end + 1) {
                if start != -1 {
                    timetable.append((previousDay, start, end))
                }
                previousDay = day
                start = slot
            }
            end = slot
        }

        if start != -1 {
            timetable.append((previousDay, start, end))
        }

        var result = ""
        for (i, entry) in timetable.enumerated() {
            let dayText = days[entry.day]

            // 두 자리 형식으로 시간 계산
            let startHour = String(format: "%02d", entry.start / 2 + 1)
            let startText = "\(startHour)\(entry.start % 2 == 0 ? "A" : "B")"

            let endHour = String(format: "%02d", entry.end / 2 + 1)
            let endText = "\(endHour)\(entry.end % 2 == 0 ? "A" : "B")"

            if i > 0 {
                result += ", "
            }
            result += "\(dayText) \(startText) ~ \(endText)"
        }

        return result
    }
}
