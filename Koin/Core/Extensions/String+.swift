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
            let document = try SwiftSoup.parse(self)
            try document.select("img").remove()
            try document.select("br").remove()
            var emptyPCount = 0 
            let paragraphs = try document.select("p")
            
            for paragraph in paragraphs {
                let paragraphText = try paragraph.text()
                if try paragraphText.isEmpty || paragraph.html().contains("br") {
                    emptyPCount += 1
                } else {
                    emptyPCount = 0
                }
               
                if emptyPCount > 1 {
                    try paragraph.remove()
                }
            }
           
            let changedHtml = try document.body()?.html() ?? ""
          
            let data = Data(changedHtml.utf8)
            let options: [NSAttributedString.DocumentReadingOptionKey : Any] = [
                .documentType: NSAttributedString.DocumentType.html,
                .characterEncoding: String.Encoding.utf8.rawValue
            ]
            let attributedString = try NSMutableAttributedString(data: data, options: options, documentAttributes: nil)
       
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineHeightMultiple = 1.5
            attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))
            
            let bTag = try NSRegularExpression(pattern: "<b>(.*?)</b>", options: [])
            let nsStringValue = attributedString.string as NSString
            let results = bTag.matches(in: changedHtml, options: [], range: NSRange(location: 0, length: nsStringValue.length))
            
            attributedString.addAttribute(.font, value: regularFont, range: NSRange(location: 0, length: attributedString.length))
            
            for result in results {
                let matchRange = result.range(at: 1)
                attributedString.addAttribute(.font, value: boldFont, range: matchRange)
            }
            
            return attributedString
        } catch {
            print("Error processing HTML: \(error)")
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
}
