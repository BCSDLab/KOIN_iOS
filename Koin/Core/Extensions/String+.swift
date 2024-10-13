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
                if let attachment = value as? NSTextAttachment {
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
}
