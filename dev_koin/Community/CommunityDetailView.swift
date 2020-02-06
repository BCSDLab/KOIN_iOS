//
// Created by 정태훈 on 2020/01/26.
// Copyright (c) 2020 정태훈. All rights reserved.
//

import SwiftUI
import UIKit
import SwiftRichString
import AttributedTextView

/*
open class MyXMLDynamicAttributesResolver: XMLDynamicAttributesResolver {
    public func styleForUnknownXMLTag(_ tag: String, to attributedString: inout AttributedString, attributes: [String : String]?) {
        let finalStyleToApply = Style()
        switch tag {
        case "a": // href support
            finalStyleToApply.linkURL = URL(string: attributes?["href"])

        case "img":
            // Remote Image URL support
            if let url = attributes?["url"] {
                if let image = AttributedString(imageURL: url, bounds: attributes?["rect"]) {
                    attributedString.append(image)
                }
            }

            // Local Image support
            if let imageName = attributes?["named"] {
                if let image = AttributedString(imageNamed: imageName, bounds: attributes?["rect"]) {
                    attributedString.append(image)
                }
            }

        default:
            break
        }
        attributedString.add(style: finalStyleToApply)
    }
    
    
    public func applyDynamicAttributes(to attributedString: inout AttributedString, xmlStyle: XMLDynamicStyle) {
        let finalStyleToApply = Style()
        xmlStyle.enumerateAttributes { key, value  in
            switch key {
                case "style": // color support
                    var colorValue = value.replacingOccurrences(of: "color: rgb[^)](\\w+), (\\w+), (\\w+)+\\);", with: "$1, $2, $3", options: .regularExpression, range: nil)
                    
                    let color = colorValue.components(separatedBy: ", ")
                    
                    let hexColor = String(format:"%02X", Int(color[0]) ?? 0) + String(format:"%02X", Int(color[1]) ?? 0) + String(format:"%02X", Int(color[2]) ?? 0)
                    finalStyleToApply.color = Color(hexString: hexColor)
                default:
                    break
            }
        }
        
        attributedString.add(style: finalStyleToApply)
    }
}
*/

struct CommunityDetailView: View {
    @ObservedObject var controller = CommunityController()
    @EnvironmentObject var user: UserSettings
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var community_id: Int
    let baseFontSize: CGFloat = 16
    @State var isCommentOn: Bool = false
    var htmlView: HTMLView = HTMLView()


    init(community_id: Int) {
        self.community_id = community_id
        self.controller.load_community(article_id: self.community_id)
    }
    
    func dateToString(string_date: String) -> String {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormat.date(from: string_date)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        let dateString = dateFormatter.string(from: date!)
        return dateString
    }


    var body: some View {
        var articleTitle: String = "title"
        var articleHit: Int = 0
        var articleNickname: String = ""
        var articleCommentCount: Int = 0
        var articleCreatedAt: String = ""
        var articleContent: String = ""
        //var articleAttrContent: NSAttributedString = NSAttributedString()


        let article = self.controller.detail_article

        articleTitle = article.title
        articleHit = article.hit
        articleNickname = article.nickname
        articleCommentCount = article.commentCount
        articleCreatedAt = dateToString(string_date: article.createdAt)
        articleContent = article.content
        self.htmlView.loadHTML(article.content)
        //print(articleContent)
        //let ttt = articleContent.htmlToAttributedString
        //print(ttt!)
        
        
        //articleContent = articleContent.replacingOccurrences(of: "<p>", with: "", options: .regularExpression, range: nil)
        //articleContent = articleContent.replacingOccurrences(of: "</p>", with: "\n", options: .regularExpression, range: nil)
        //articleContent = articleContent.replacingOccurrences(of: "<div>", with: "", options: .regularExpression, range: nil)
        //articleContent = articleContent.replacingOccurrences(of: "</div>", with: "\n", options: .regularExpression, range: nil)
        articleContent = articleContent.replacingOccurrences(of: "<br>", with: "\n", options: .regularExpression, range: nil)
        articleContent = articleContent.replacingOccurrences(of: "<!--[^>]+>", with: "", options: .regularExpression, range: nil)
        //articleContent = articleContent.replacingOccurrences(of: "(</h[^>]+>)", with: "$0\n", options: .regularExpression, range: nil)
        //articleContent = articleContent.replacingOccurrences(of: "(</li>)", with: "$0\n", options: .regularExpression, range: nil)
        //articleContent = articleContent.replacingOccurrences(of: "src", with: "url", options: .regularExpression, range: nil)
        //articleContent = articleContent.replacingOccurrences(of: "(<img[^>]+)", with: "$0 /", options: .regularExpression, range: nil)
        

        //print(articleContent)

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
        let pStyle = Style {
            $0.font = UIFont.systemFont(ofSize: self.baseFontSize)
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

        var styleGroup = StyleGroup(base: Style {
            $0.font = UIFont.systemFont(ofSize: self.baseFontSize)
            $0.lineSpacing = 2
            //$0.kerning = Kerning.adobe(-15)
        },
            /*
            [
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
            }]*/
            [
                "p": pStyle
            ]
        )
        var defaultstyleGroup = StyleGroup(base: Style {
            $0.font = UIFont.systemFont(ofSize: self.baseFontSize)
            $0.lineSpacing = 2
            //$0.kerning = Kerning.adobe(-15)
        }, ["p": pStyle])
        //defaultstyleGroup.xmlAttributesResolver = MyXMLDynamicAttributesResolver()


        var attributedContent = articleContent.set(style: defaultstyleGroup)
        //debugPrint(attributedContent)
        //debugPrint(article.content.html)

        return VStack {
                    VStack(alignment: .leading) {
                        HStack {
                        Text("\(articleTitle)")
                        Text("(\(articleCommentCount))")
                        .foregroundColor(Color("light_navy"))
                        }
                        HStack {
                            Text("조회\(articleHit)·\(articleNickname)")
                                .foregroundColor(Color("warm_grey"))
                            Spacer()
                            Text(articleCreatedAt)
                                .foregroundColor(Color("warm_grey"))
                        }
                        HStack {
                            NavigationLink(destination: CommunityCommentView(community_id: self.community_id).environmentObject(self.controller).navigationBarTitle("댓글", displayMode: .inline)) {
                                HStack {
                                Text("댓글")
                                    .foregroundColor(Color.black)
                                    Text("\(articleCommentCount)")
                                    .foregroundColor(Color("light_navy"))
                                }
                                        .padding(.all, 10)
                                .border(Color.gray.opacity(0.8), width: 1)
                            }
                            NavigationLink(destination: AddCommunityView(title: articleTitle, content: article.content, article_id: community_id, is_edit: true).environmentObject(self.controller).navigationBarTitle("수정", displayMode: .inline)) {
                                Text("수정")
                                    .foregroundColor(Color.black)
                                        .padding(.all, 10)
                                .border(Color.gray.opacity(0.8), width: 1)
                            }
                            Button(action: {self.controller.delete_article(token: self.user.get_token(), article_id: self.community_id) { result in
                            if result {
                                self.presentationMode.wrappedValue.dismiss()
                            } else {
                                print("성공 못함")
                            }
                            }}) {
                                Text("삭제")
                                        .foregroundColor(Color.red)
                                        .padding(.all, 10)
                                .border(Color.gray.opacity(0.8), width: 1)
                            }
                        }

                    }
                    Divider()
                    
                    htmlView
                    


                }.padding()
            
        

    }
}

struct CommunityDetailView_Previews: PreviewProvider {
    static var previews: some View {
        CommunityDetailView(community_id: 13851)
    }
}
