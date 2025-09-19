//
//  NoticeListDto.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/13/24.
//

import Foundation
import SwiftSoup

struct NoticeListDto: Decodable {
    let articles: [NoticeArticleDto]?
    let totalCount, currentCount, totalPage, currentPage: Int
    
    enum CodingKeys: String, CodingKey {
        case articles
        case totalCount = "total_count"
        case currentCount = "current_count"
        case totalPage = "total_page"
        case currentPage = "current_page"
    }
}

struct NoticeArticleDto: Decodable {
    let id, boardId: Int
    let title: String?
    let author: String?
    let hit: Int?
    let type: LostItemType?
    let category: String?
    let foundPlace: String?
    let foundDate: String?
    let content: String?
    let updatedAt: String?
    let url: String?
    let attachments: [NoticeAttachmentDto]?
    let prevId: Int?
    let nextId: Int?
    let registeredAt: String
    var isReported: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id
        case boardId = "board_id"
        case title, author, hit, content, attachments, url
        case type, category
        case foundPlace = "found_place"
        case foundDate = "found_date"
        case prevId = "prev_id"
        case nextId = "next_id"
        case updatedAt = "updated_at"
        case registeredAt = "registered_at"
        case isReported = "is_reported"
    }
}

struct NoticeAttachmentDto: Decodable {
    let id: Int
    let name, url, createdAt, updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, url
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

extension NoticeListDto {
    func toDomain() -> NoticeListDto {
        var newArticles: [NoticeArticleDto] = []
        if let articles = articles {
            for article in articles {
                newArticles.append(article.toDomainWithChangedDate())
            }
        }
        return NoticeListDto(articles: newArticles, totalCount: totalCount, currentCount: currentCount, totalPage: totalPage, currentPage: currentPage)
    }
}

extension NoticeArticleDto {
    func toDomain() -> NoticeDataInfo {
        return NoticeDataInfo(title: title ?? "", boardId: boardId, content: content ?? "", author: author ?? "-", hit: hit, prevId: prevId, nextId: nextId, attachments: attachments ?? [], url: url, registeredAt: registeredAt)
    }
    
    func toDomainWithChangedDate() -> NoticeArticleDto {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.date(from: registeredAt) ?? Date()
        let newDate = date.formatDateToMMDDE()
        let newTitle = title?.replacingOccurrences(of: "\n", with: "")

        return NoticeArticleDto(
            id: id,
            boardId: boardId,
            title: newTitle,
            author: author,
            hit: hit,
            type: type,
            category: category,
            foundPlace: foundPlace,
            foundDate: foundDate,
            content: boardId == 14 ? content : modifyFontInHtml(html: content ?? ""),
            updatedAt: updatedAt,
            url: url,
            attachments: attachments ?? [],
            prevId: prevId,
            nextId: nextId,
            registeredAt: newDate, isReported: isReported
        )
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
            
            for paragraph in paragraphs {
                let paragraphText = try paragraph.text()
                if paragraphText.isEmpty && paragraph.children().array().isEmpty {
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
