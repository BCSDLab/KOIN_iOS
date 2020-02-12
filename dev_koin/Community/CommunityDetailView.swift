//
// Created by 정태훈 on 2020/01/26.
// Copyright (c) 2020 정태훈. All rights reserved.
//

import SwiftUI
import UIKit
import CryptoKit
import CryptoTokenKit

struct CommunityDetailView: View {
    @ObservedObject var controller:CommunityController
    @EnvironmentObject var user: UserSettings
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var community_id: Int
    var board_id: Int
    let baseFontSize: CGFloat = 16
    @State var isCommentOn: Bool = false
    var htmlView: HTMLView = HTMLView()
    var getUserId: Int = -1
    @State var temp_password: String = ""


    init(community_id: Int, board_id: Int, user_id: Int) {
        self.board_id = board_id
        self.controller = CommunityController(board_id: board_id)
        self.community_id = community_id
        self.getUserId = user_id
        if board_id == -2 {
            self.controller.load_temp_community(article_id: self.community_id)
        } else {
            self.controller.load_community(article_id: self.community_id)
        }
        print(community_id)
    }
    
    init(community_id: Int) {
        self.board_id = -2
        self.controller = CommunityController(board_id: -2)
        self.community_id = community_id
        self.controller.load_temp_community(article_id: community_id)
        print(community_id)
    }
    
    func hashed(pw: String) -> String{
        // 비밀번호를 먼전 Data로 변환하여
        let inputData = Data(pw.utf8)
        // SHA256을 이용해 해시 처리한 다음
        let hashed = SHA256.hash(data: inputData)
        // 해시 당 16진수 2자리로 설정하여 합친다.
        let hashPassword = hashed.compactMap {String(format: "%02x", $0)}.joined().trimmingCharacters(in: CharacterSet.newlines)
        return hashPassword
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
        var article: Article = Article()
        var tempArticle: TempArticle = TempArticle()
        var articleTitle: String = "title"
        var articleHit: Int = 0
        var articleNickname: String = ""
        var articleCommentCount: Int = 0
        var articleCreatedAt: String = ""
        var articleContent: String = ""
        
        
        
        //var articleAttrContent: NSAttributedString = NSAttributedString()

        if self.board_id == -2 {
            tempArticle = self.controller.detail_temp_article
            print(tempArticle)
            articleTitle = tempArticle.title
            articleHit = tempArticle.hit
            articleNickname = tempArticle.nickname
            if let commentCount = tempArticle.commentCount {
                articleCommentCount = commentCount
            }
            articleCreatedAt = dateToString(string_date: tempArticle.createdAt)
            if let content = tempArticle.content {
                articleContent = content
            }
            self.htmlView.loadHTML(articleContent)
        } else {
            article = self.controller.detail_article
            
            articleTitle = article.title
            articleHit = article.hit
            articleNickname = article.nickname
            articleCommentCount = article.commentCount
            articleCreatedAt = dateToString(string_date: article.createdAt)
            articleContent = article.content
            self.htmlView.loadHTML(articleContent)
        }
        
        
        //getUserId = self.user.get_userId()
        

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
                            
                            //익명일 경우, 비밀번호 맞을 경우에만 접근 가능하게 하기
                            if(self.board_id == -2) {
                                SecureField("비밀번호", text: $temp_password)
                                NavigationLink(destination: AddCommunityView(board_id: self.board_id, title: articleTitle, content: article.content, article_id: community_id, is_edit: true).environmentObject(self.controller).navigationBarTitle("수정", displayMode: .inline)) {
                                Text("수정")
                                    .foregroundColor(Color.black)
                                        .padding(.all, 10)
                                .border(Color.gray.opacity(0.8), width: 1)
                            }
                                Button(action: {self.controller.delete_temp_article(password: self.hashed(pw:self.temp_password), article_id: self.community_id) { result in
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
