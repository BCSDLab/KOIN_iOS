//
// Created by 정태훈 on 2020/01/26.
// Copyright (c) 2020 정태훈. All rights reserved.
//

import SwiftUI
import UIKit
import SwiftRichString
/*
extension String{
    func convertHtml() -> NSAttributedString{
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do{
        return try NSAttributedString(data: data, options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html, NSAttributedString.DocumentReadingOptionKey.characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        }catch{
            return NSAttributedString()
        }
    }
}
*/
struct CommunityDetailView: View {
    @ObservedObject var controller: CommunityController = CommunityController()
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var community_id: Int
    let baseFontSize: CGFloat = 16


    init(community_id: Int) {
        self.community_id = community_id
        self.controller.load_community(article_id: self.community_id)
    }


    var body: some View {
        var articleTitle: String = "title"
        var articleHit: Int = 0
        var articleNickname: String = ""
        var articleCommentCount: Int = 0
        var articleCreatedAt: String = ""
        var articleContent: String = ""


        let article = self.controller.detail_article

        articleTitle = article.title
        articleHit = article.hit
        articleNickname = article.nickname
        articleCommentCount = article.commentCount
        articleCreatedAt = article.createdAt
        articleContent = article.content
        print(articleContent)
        articleContent = articleContent.replacingOccurrences(of: "<p>", with: "", options: .regularExpression, range: nil)
        articleContent = articleContent.replacingOccurrences(of: "</p>", with: "\n", options: .regularExpression, range: nil)
        articleContent = articleContent.replacingOccurrences(of: "<div>", with: "", options: .regularExpression, range: nil)
        articleContent = articleContent.replacingOccurrences(of: "</div>", with: "\n", options: .regularExpression, range: nil)
        articleContent = articleContent.replacingOccurrences(of: "<br>", with: "\n", options: .regularExpression, range: nil)
        articleContent = articleContent.replacingOccurrences(of: "<!--[^>]+>", with: "", options: .regularExpression, range: nil)
        articleContent = articleContent.replacingOccurrences(of: "(</h[^>]+>)", with: "$0\n", options: .regularExpression, range: nil)
        articleContent = articleContent.replacingOccurrences(of: "(</li>)", with: "$0\n", options: .regularExpression, range: nil)
        articleContent = articleContent.replacingOccurrences(of: "src", with: "url", options: .regularExpression, range: nil)
        articleContent = articleContent.replacingOccurrences(of: "(<img[^>]+)", with: "$0 /", options: .regularExpression, range: nil)
        

        print(articleContent)

        let h1Style = Style {
            $0.font = UIFont.boldSystemFont(ofSize: self.baseFontSize * 2)
            $0.lineBreakMode = .byWordWrapping
        }
        let h2Style = Style {
            $0.font = UIFont.boldSystemFont(ofSize: self.baseFontSize * 1.5)
            $0.lineBreakMode = .byWordWrapping
        }
        let h3Style = Style {
            $0.font = UIFont.boldSystemFont(ofSize: self.baseFontSize * 1.17)
            $0.lineBreakMode = .byWordWrapping
        }
        let h4Style = Style {
            $0.font = UIFont.boldSystemFont(ofSize: self.baseFontSize)
            $0.lineBreakMode = .byWordWrapping
        }
        let h5Style = Style {
            $0.font = UIFont.boldSystemFont(ofSize: self.baseFontSize * 0.83)
            $0.lineBreakMode = .byWordWrapping
        }
        let h6Style = Style {
            $0.font = UIFont.boldSystemFont(ofSize: self.baseFontSize * 0.67)
            $0.lineBreakMode = .byWordWrapping
        }
        let boldStyle = Style {
            $0.font = UIFont.boldSystemFont(ofSize: self.baseFontSize)
            if #available(iOS 11.0, *) {
                $0.dynamicText = DynamicText {
                    $0.style = .body
                    $0.maximumSize = 35.0
                    $0.traitCollection = UITraitCollection(userInterfaceIdiom: .phone)
                }
            }
        }
        let underlineStyle = Style {
            $0.underline = (.single,UIColor.black)
        }
        let italicStyle = Style {
            $0.font = UIFont.italicSystemFont(ofSize: self.baseFontSize)
        }

        let uppercasedRed = Style {
            $0.font = UIFont.italicSystemFont(ofSize: self.baseFontSize)
            $0.color = UIColor.red
            $0.textTransforms = [
                .uppercase
            ]
        }

        let styleGroup = StyleGroup(base: Style {
            $0.font = UIFont.systemFont(ofSize: self.baseFontSize)
            //$0.lineSpacing = 2
            //$0.kerning = Kerning.adobe(-15)
        }, [
            "ur": uppercasedRed,
            "h1": h1Style,
            "h2": h2Style,
            "h3": h3Style,
            "h4": h4Style,
            "h5": h5Style,
            "h6": h6Style,
            "strong": boldStyle,
            "u": underlineStyle,
            "b": boldStyle,
            "em": italicStyle,
            "i": italicStyle,
            "a": uppercasedRed,
            "li": Style {
                $0.paragraphSpacingBefore = self.baseFontSize / 2
                $0.firstLineHeadIndent = self.baseFontSize
                $0.headIndent = self.baseFontSize * 1.71
            },
            "sup": Style {
                $0.font = UIFont.systemFont(ofSize: self.baseFontSize / 1.2)
                $0.baselineOffset = Float(self.baseFontSize) / 3.5
            }])

        print(article.content)



        var attributedContent = articleContent.set(style: styleGroup)

        return VStack() {
            VStack(alignment: .leading) {
                Text("\(articleTitle) \(articleCommentCount)")
                HStack {
                    Text("조회 \(articleHit).\(articleNickname)")
                    Spacer()
                    Text(articleCreatedAt)
                }

            }
            Divider()
            TextWithAttributedString(attributedString: attributedContent)


        }.padding()

    }
}
