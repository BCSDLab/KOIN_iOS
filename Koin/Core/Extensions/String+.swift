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

    func modifyFontInHtml() -> String? {
        do {
            let document = try SwiftSoup.parse(self)
            try document.select("br").remove()
            
            let paragraphs = try document.select("p")
            let bTags = try document.select("b")
            let iTags = try document.select("i")
            let hTags = try document.select("h1, h2, h3, h4, h5, h6")
            let spans = try document.select("span")
            let ulTags = try document.select("ul")
            let olTags = try document.select("ol")
            let liTags = try document.select("li")
            
            var emptyPCount = 0
            for paragraph in paragraphs {
                let paragraphText = try paragraph.text()
                if paragraphText.isEmpty {
                    emptyPCount += 1
                } else {
                    emptyPCount = 0
                }
                
                if emptyPCount > 1 {
                    try paragraph.remove()
                }
                
                if let img = try paragraph.select("img").first() {
                    try paragraph.append("<p></p>")
                }
            }
        
            let allTags: [Elements] = [paragraphs, bTags, iTags, hTags, spans, ulTags, olTags, liTags]
            for elements in allTags {
                for element in elements {
                    try element.attr("style", "font-family: 'Pretandard-Medium', sans-serif; font-size: 16px;")
                }
            }
            
            for element in bTags {
                try element.attr("style", "font-family: 'Pretandard-Bold', sans-serif; font-size: 16px;")
            }
            
            let setHeightUsingCSS = """
                <head>
                    <style type="text/css">
                        img {
                            max-height: 100%;
                            max-width: 317px !important;
                            width: auto;
                            height: auto;
                            display: block;
                            margin-bottom: 20px; /* Space below the image */
                        }
                        .txc-image {
                            text-align: center; /* Center the image */
                        }
                        .bc-s-post-ctnt-area {
                            padding: 20px; /* Optional padding */
                            border-top: 1px solid transparent; /* Prevent margin collapse */
                        }
                    </style>
                </head>
                <body class="center">
                    <div class="bc-s-post-ctnt-area">
                        \(try document.body()?.html() ?? "")
                    </div>
                </body>
                """
            return setHeightUsingCSS
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
            
            imgElements.forEach { element in
                let imageSrc = (try? element.attr("src")) ?? ""
                
                let range = NSMakeRange(0, text.length)
                
                text.enumerateAttribute(NSAttributedString.Key.attachment, in: range, options: []) { (value, _, _) in
                    if let attachment = value as? NSTextAttachment {
                        imageSrc.loadImage(from: imageSrc, completion: { image in
                            attachment.image = image
                        })
                    }
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
