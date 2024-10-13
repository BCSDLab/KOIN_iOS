//
//  NoticeListDTO.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/13/24.
//

import Foundation
import SwiftSoup

struct NoticeListDTO: Decodable {
    let articles: [NoticeArticleDTO]?
    let totalCount, currentCount, totalPage, currentPage: Int
    
    enum CodingKeys: String, CodingKey {
        case articles
        case totalCount = "total_count"
        case currentCount = "current_count"
        case totalPage = "total_page"
        case currentPage = "current_page"
    }
}

struct NoticeArticleDTO: Decodable {
    let id, boardId: Int
    let title, author: String
    let hit: Int
    let content: String?
    let updatedAt: String
    let attachments: [NoticeAttachmentDTO]?
    let prevId: Int?
    let nextId: Int?
    let registeredAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case boardId = "board_id"
        case title, author, hit, content, attachments
        case prevId = "prev_id"
        case nextId = "next_id"
        case updatedAt = "updated_at"
        case registeredAt = "registered_at"
    }
}

struct NoticeAttachmentDTO: Decodable {
    let id: Int
    let name, url, createdAt, updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, url
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

extension NoticeListDTO {
    func toDomain() -> NoticeListDTO {
        var newArticles: [NoticeArticleDTO] = []
        if let articles = articles {
            for article in articles {
                newArticles.append(article.toDomainWithChangedDate())
            }
        }
        return NoticeListDTO(articles: newArticles, totalCount: totalCount, currentCount: currentCount, totalPage: totalPage, currentPage: currentPage)
    }
}

extension NoticeArticleDTO {
    func toDomain() -> NoticeDataInfo {
        return NoticeDataInfo(title: title, boardId: boardId, content: content ?? "", author: author, hit: hit, prevId: prevId, nextId: nextId, attachments: attachments ?? [], registeredAt: registeredAt)
    }
    
    func toDomainWithChangedDate() -> NoticeArticleDTO {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.date(from: registeredAt) ?? Date()
        let newDate = date.formatDateToMMDDE()
        let newTitle = title.replacingOccurrences(of: "\n", with: "")
        return NoticeArticleDTO(id: id, boardId: boardId, title: newTitle, author: author, hit: hit, content: modifyFontInHtml(html: content ?? ""), updatedAt: updatedAt, attachments: attachments ?? [], prevId: prevId, nextId: nextId, registeredAt: newDate)
    }
    
    private func modifyFontInHtml(html: String) -> String? {
        do {
            let document = try SwiftSoup.parse(html)
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
                
                if (try paragraph.select("img").first()) != nil {
                    try paragraph.append("<p></p>")
                }
            }
        
            let allTags: [Elements] = [paragraphs, bTags, iTags, hTags, spans, ulTags, olTags, liTags]
            for elements in allTags {
                for element in elements {
                    let existingStyle = try element.attr("style")
                    let newStyle = "font-family: 'Pretandard-Medium', sans-serif; font-size: 16px;"
                    let updatedStyle = existingStyle.isEmpty ? newStyle : "\(existingStyle); \(newStyle)"
                    try element.attr("style", updatedStyle)
                }
            }
           
            for element in bTags {
                let existingStyle = try element.attr("style")
                let newBoldStyle = "font-family: 'Pretandard-Bold', sans-serif; font-size: 16px;"
                let updatedBoldStyle = existingStyle.isEmpty ? newBoldStyle : "\(existingStyle); \(newBoldStyle)"
                try element.attr("style", updatedBoldStyle)
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
    
}
