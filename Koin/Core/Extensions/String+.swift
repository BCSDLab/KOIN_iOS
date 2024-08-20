//
//  String+.swift
//  koin
//
//  Created by 김나훈 on 4/9/24.
//

import Foundation
import SwiftSoup

extension String {
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

    func extractFromHtmlTag(htmlTag: String) -> NSAttributedString? {
        do {
            let docs: Document = try SwiftSoup.parse(self)
            let elements: Elements = try docs.select(htmlTag)
            let resultString = NSMutableAttributedString()
            
            for element in elements {
                let elementText = try element.text()
                var attributedString: NSAttributedString

                if let _ = try? element.select("b").first() {
                    let attributes: [NSAttributedString.Key: Any] = [
                        .font: UIFont.appFont(.pretendardRegular, size: 12)
                    ]
                    attributedString = NSAttributedString(string: elementText, attributes: attributes)
                } else {
                    let attributes: [NSAttributedString.Key: Any] = [
                        .font: UIFont.appFont(.pretendardMedium, size: 12)
                    ]
                    attributedString = NSAttributedString(string: elementText, attributes: attributes)
                }
                
                resultString.append(attributedString)
            }
            
            let finalString = resultString.string.replacingOccurrences(of: "\n\n", with: "\n")
            return NSAttributedString(string: finalString)
        } catch {
                return nil
        }
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
>>>>>>> b0cb878 (feat: 공지사항 상세 뷰 데이터 연결)
    }
    
    func toDateFromYYYYMMDD() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.date(from: self)
    }
}
