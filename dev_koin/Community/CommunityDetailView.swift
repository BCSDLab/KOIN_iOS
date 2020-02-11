//
// Created by 정태훈 on 2020/01/26.
// Copyright (c) 2020 정태훈. All rights reserved.
//

import SwiftUI
import UIKit
//import SwiftRichString
//import AttributedTextView

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
    @ObservedObject var controller:CommunityController
    @EnvironmentObject var user: UserSettings
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var community_id: Int
    var board_id: Int
    let baseFontSize: CGFloat = 16
    @State var isCommentOn: Bool = false
    var htmlView: HTMLView = HTMLView()
    var getUserId: Int


    init(community_id: Int,board_id: Int, user_id: Int) {
        self.board_id = board_id
        self.controller = CommunityController(board_id: board_id)
        self.community_id = community_id
        self.getUserId = user_id
        self.controller.load_community(article_id: self.community_id)
        print(community_id)
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
        var articleUserId: Int = -1
        
        //var articleAttrContent: NSAttributedString = NSAttributedString()


        let article = self.controller.detail_article
        //getUserId = self.user.get_userId()
        articleTitle = article.title
        articleHit = article.hit
        articleNickname = article.nickname
        articleCommentCount = article.commentCount
        articleCreatedAt = dateToString(string_date: article.createdAt)
        articleContent = article.content
        self.htmlView.loadHTML(article.content)
        print(self.user.get_userId() == self.getUserId)

        //print(article.userId == self.user.get_userId())

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
                            if(self.user.get_userId() == self.getUserId) {
                                NavigationLink(destination: AddCommunityView(board_id: self.board_id, title: articleTitle, content: article.content, article_id: community_id, is_edit: true).environmentObject(self.controller).navigationBarTitle("수정", displayMode: .inline)) {
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

                    }
                    Divider()
                    
                    htmlView
                    


                }.padding()
            
        

    }
}

struct CommunityDetailView_Previews: PreviewProvider {
    static var previews: some View {
        CommunityDetailView(community_id: 13851, board_id: 1, user_id: 316)
    }
}
