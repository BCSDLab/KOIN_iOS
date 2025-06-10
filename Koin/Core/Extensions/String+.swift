//
//  String+.swift
//  koin
//
//  Created by 김나훈 on 4/9/24.
//

import Foundation
import Kingfisher
import SwiftSoup

extension String {
    func toChatDateInfo() -> ChatDateInfo {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        formatter.timeZone = TimeZone(secondsFromGMT: 0) // ✅ UTC 그대로 변환
        
        // ✅ 소수점 이하 초 단위를 최대 3자리까지만 유지
        var formattedDateString = self
        if let dotIndex = self.firstIndex(of: ".") {
            let afterDot = self[dotIndex...]
            let trimmedFraction = afterDot.prefix(4) // '.' 포함 최대 4자리 (.SSS)
            formattedDateString = String(self[..<dotIndex]) + trimmedFraction
        }
        
        // ✅ UTC 시간 정보(`Z`)가 없는 경우 추가
        if !formattedDateString.hasSuffix("Z") {
            formattedDateString += "Z"
        }
        
        // ✅ 문자열을 Date 타입으로 변환 (UTC 기준)
        guard let date = formatter.date(from: formattedDateString) else {
            print("❌ 변환 실패: \(formattedDateString)")
            return ChatDateInfo(
                year: 0, month: 0, day: 0, hour: 0, minute: 0, second: 0,
                isToday: false, isYesterday: false, showingText: "날짜 오류"
            )
        }
        
        // ✅ UTC 기반 Calendar 생성 (로컬 시간 적용 안 함)
        var utcCalendar = Calendar(identifier: .gregorian)
        utcCalendar.timeZone = TimeZone(secondsFromGMT: 0) ?? TimeZone.current
        
        let components = utcCalendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        
        // ✅ 오늘/어제 여부 체크 (UTC 기준)
        let today = utcCalendar.startOfDay(for: Date()) // ✅ 현재 시간도 UTC로 비교해야 함
        let messageDay = utcCalendar.startOfDay(for: date)
        
        let isToday = messageDay == today
        let isYesterday = messageDay == utcCalendar.date(byAdding: .day, value: -1, to: today)
        
        // ✅ `showingText` 생성 (UTC 기준 유지)
        let showingText: String
        let hour = components.hour ?? 0
        let minute = components.minute ?? 0
        
        if isToday {
            let period = hour < 12 ? "오전" : "오후"
            let formattedHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour)
            
            // ✅ 한 자리 숫자를 두 자리로 변환
            let hourString = String(format: "%02d", formattedHour)
            let minuteString = String(format: "%02d", minute)

            showingText = "\(period) \(hourString)시 \(minuteString)분"
        } else if isYesterday {
            showingText = "어제"
        } else {
            let currentYear = utcCalendar.component(.year, from: today)
            
            let monthString = String(format: "%02d", components.month ?? 0)
            let dayString = String(format: "%02d", components.day ?? 0)

            if components.year == currentYear {
                showingText = "\(monthString)월 \(dayString)일"
            } else {
                let yearString = String(format: "%04d", components.year ?? 0) // ✅ 4자리 연도 변환
                showingText = "\(yearString)년 \(monthString)월 \(dayString)일"
            }
        }

        
        return ChatDateInfo(
            year: components.year ?? 0,
            month: components.month ?? 0,
            day: components.day ?? 0,
            hour: hour,
            minute: minute,
            second: components.second ?? 0,
            isToday: isToday,
            isYesterday: isYesterday,
            showingText: showingText
        )
    }
    func formatSemester() -> String {
        // 1. "2024년 1학기" 같은 텍스트를 학기 코드로 변환
        if let match = self.range(of: #"^\d{4}년 (1학기|2학기|여름 학기|겨울 학기)$"#, options: .regularExpression) {
            let year = String(self[match].prefix(4)) // 연도 추출
            if self.contains("1학기") {
                return "\(year)1"
            } else if self.contains("2학기") {
                return "\(year)2"
            } else if self.contains("여름 학기") {
                return "\(year)-여름"
            } else if self.contains("겨울 학기") {
                return "\(year)-겨울"
            }
        }
        
        // 2. 이미 표준 코드 형식인 경우 그대로 반환
        if self.range(of: #"^\d{4}[1-4]$"#, options: .regularExpression) != nil ||
            self.range(of: #"^\d{4}-(여름|겨울)$"#, options: .regularExpression) != nil {
            return self
        }
        
        // 변환 실패 시 빈 문자열 반환
        return ""
    }
    
    /// 학기 코드 (e.g., 20241, 2024-여름) 텍스트를 "2024년 겨울 학기" 형식으로 변환
    func reverseFormatSemester() -> String {
        // 1. 숫자로 끝나는 형식 (e.g., 20241, 20242)
        if let match = self.range(of: #"^\d{4}[1-4]$"#, options: .regularExpression) {
            let year = String(self[match].prefix(4)) // 연도 추출
            let semesterCode = self.suffix(1) // 학기 코드 추출
            
            let semesterText: String
            switch semesterCode {
            case "1": semesterText = "1학기"
            case "2": semesterText = "2학기"
            case "3": semesterText = "여름 학기"
            case "4": semesterText = "겨울 학기"
            default: semesterText = ""
            }
            
            return "\(year)년 \(semesterText)"
        }
        
        // 2. "-"가 포함된 패턴 (e.g., 2024-여름, 2024-겨울)
        if let match = self.range(of: #"^\d{4}-(여름|겨울)$"#, options: .regularExpression) {
            let components = self.split(separator: "-") // "-" 기준으로 나누기
            guard components.count == 2, let year = components.first, let semester = components.last else {
                return ""
            }
            return "\(year)년 \(semester) 학기"
        }
        
        // 변환 실패 시 빈 문자열 반환
        return ""
    }
    func hasFinalConsonant() -> Bool {
        guard let lastText = self.last else { return false }
        let unicodeVal = UnicodeScalar(String(lastText))?.value
        
        guard let value = unicodeVal else { return false }
        if (value < 0xAC00 || value > 0xD7A3) { return false }
        let last = (value - 0xAC00) % 28
        return last > 0
    }
    
    func toDateFromYYMMDD() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyMMdd"
        return dateFormatter.date(from: self)
    }
    
    func extractImageStringFromHtmlTag() -> String? {
        do {
            let docs: Document = try SwiftSoup.parse(self)
            let element: Elements = try docs.select("img")
            
            let imageUrl = try element.attr("src").description
            return imageUrl.isEmpty ? nil : imageUrl
        } catch {
            return nil
        }
    }
    
    func extractStringFromParentheses() -> (String, String) {
        var result = ""
        var isInsideParentheses = false
        var startParenthesesIdx = 0
        
        for (index, char) in self.reversed().enumerated() {
            if char == ")" {
                isInsideParentheses = true
                continue
            }
            
            if char == "(" {
                isInsideParentheses = false
                startParenthesesIdx = self.count - index - 1
                break
            }
            
            if isInsideParentheses {
                result += String(char)
            }
        }
        let fileSize = String(result.reversed())
        if startParenthesesIdx > 0 {
            let resultString = self.prefix(startParenthesesIdx)
            return (fileSize, String(resultString))
        }
        else {
            return ("", self)
        }
    }
    
    func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        KingfisherManager.shared.retrieveImage(with: url) { result in
            switch result {
            case .success(let value):
                completion(value.image)
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }
    
    func convertToAttributedFromHTML() -> NSAttributedString? {
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        
        guard let data = self.data(using: .utf8) else { return nil }
        
        do {
            let attributedString = try NSAttributedString(data: data, options: options, documentAttributes: nil)
            let text = NSMutableAttributedString(attributedString: attributedString)
            
            let docs: Document = try SwiftSoup.parse(self)
            let imgElements: Elements = try docs.select("img")
            var imgSrcLists: [String] = []
            var check = 0
            imgElements.forEach { element in
                let imageSrc = (try? element.attr("src")) ?? ""
                imgSrcLists.append(imageSrc)
            }
            let range = NSMakeRange(0, text.length)
            
            text.enumerateAttribute(NSAttributedString.Key.attachment, in: range, options: []) { (value, _, _) in
                if let attachment = value as? NSTextAttachment, !imgSrcLists.isEmpty {
                    let imageSrc = imgSrcLists[check]
                    imageSrc.loadImage(from: imageSrc, completion: { image in
                        attachment.image = image
                    })
                    check += 1
                }
            }
            
            return text
        } catch {
            print("Fail: \(error.localizedDescription)")
            return nil
        }
    }
    
    func toDateFromYYYYMMDD() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.date(from: self)
    }
    
    // 이메일 정규식
    var isValidEmailFormat: Bool {
        let regex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: self)
    }
}
