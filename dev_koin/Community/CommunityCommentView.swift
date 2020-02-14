//
//  CommunityCommentView.swift
//  dev_koin
//
//  Created by 정태훈 on 2020/01/30.
//  Copyright © 2020 정태훈. All rights reserved.
//

import SwiftUI
import CryptoKit
import CryptoTokenKit

func commentDateToString(string_date: String) -> String {
    let dateFormat = DateFormatter()
    dateFormat.dateFormat = "yyyy-MM-dd HH:mm:ss"
    let date = dateFormat.date(from: string_date)
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy.MM.dd HH:mm"
    let dateString = dateFormatter.string(from: date!)
    return dateString
}

struct CommunityCommentView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var controller: CommunityController
    @EnvironmentObject var user: UserSettings
    var community_id: Int
    @State var comment_content: String = ""
    @State var is_edited: Bool = false
    @State var edited_comment_id: Int = -1
    @State var edited_article_id: Int = -1
    @State var temp_password: String = ""
    @State var temp_nickname: String = ""


    init(community_id: Int) {
        self.community_id = community_id
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
    
    var body: some View {
        var article: Article = Article()
        var tempArticle: TempArticle = TempArticle()
        var articleTitle: String = "title"
        var articleHit: Int = 0
        var articleNickname: String = ""
        var articleCommentCount: Int = 0
        var articleCreatedAt: String = ""
        var articleContent: String = ""
        var articleComments: [Comment] = []
        var articleTempComments: [TempComment] = []

        if self.controller.board_id == -2 {
            tempArticle = self.controller.detail_temp_article
            
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
            if let comments = tempArticle.comments {
                for c in comments {
                    articleTempComments.append(c)
                }
            }
        } else {
            article = self.controller.detail_article
            
            articleTitle = article.title
            articleHit = article.hit
            articleNickname = article.nickname
            articleCommentCount = article.commentCount
            articleCreatedAt = dateToString(string_date: article.createdAt)
            articleContent = article.content
            if let comments = article.comments {
                for c in comments {
                    articleComments.append(c)
                }
            }
        }

        
        //print(articleContent)
        
        return Group {
            if self.controller.board_id == -2 {
                ScrollView(.vertical)  {
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

                    }
                    Divider()
                    ForEach(articleTempComments, id: \.self) { c in
                        VStack(alignment: .leading) {
                            HStack {
                                Text(c.nickname)
                                    .foregroundColor(Color("black"))
                                    .fontWeight(.medium)
                                Text(commentDateToString(string_date: c.createdAt))
                                .foregroundColor(Color("gray2"))
                                .fontWeight(.light)
                                Spacer()
                                
                                Button(action:{self.controller.delete_temp_comment(password: self.hashed(pw:self.temp_password), article_id: c.articleId, comment_id: c.id) { result in
                                        if result {
                                            self.presentationMode.wrappedValue.dismiss()
                                        } else {
                                            print("성공 못함")
                                        }
                                        }}) {
                                        Image("close")
                                            .renderingMode(.original)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                
                            }
                            HStack {
                            Text(c.content)
                                .foregroundColor(Color("black"))
                                .fontWeight(.light)
                            }.fixedSize(horizontal: false, vertical: true)
                                .padding(.bottom, 10)
                            SecureField("비밀번호", text: self.$temp_password)
                                Button(action:{
                                    self.comment_content = c.content
                                    self.edited_comment_id = c.id
                                    self.edited_article_id = c.articleId
                                    self.is_edited = true
                                    self.temp_nickname = c.nickname
                                }) {
                                    HStack {
                                    Text("수정")
                                        .fontWeight(.light)
                                        .foregroundColor(.black)
                                    }.padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .border(Color.gray.opacity(0.8), width: 1)
                                }
                            
                        }.padding(.vertical, 10)
                    }
                    Divider()
                    //수정모드일 때는 취소와 수정 버튼, 작성모드일 때는 등록 버튼만
                    VStack(alignment: .leading) {
                        VStack(alignment: .leading) {
                            if !is_edited {
                                TextField("닉네임", text: $temp_nickname)
                            } else {
                                Text(self.temp_nickname)
                            }
                           SecureField("비밀번호", text: $temp_password)
                            TextField("댓글을 작성해주세요.", text: $comment_content)
                                .font(.system(size: 16, weight: .light, design: .default))
                        }.padding(.all, 10)
                        .border(Color.gray.opacity(0.8), width: 1)
                        
                        
                    }
                    HStack {
                        
                        if is_edited {
                            
                            Button(action: {
                                self.edited_article_id = -1
                                self.edited_comment_id = -1
                                self.comment_content = ""
                                self.is_edited = false
                            }) {
                                VStack{
                                Text("취소")
                                }
                                .padding(.all, 10)
                                .border(Color.gray.opacity(0.8), width: 1).fixedSize(horizontal: false, vertical: true)
                                    
                            }
                            
                            Button(action: {self.controller.update_temp_comment(password: self.hashed(pw:self.temp_password), article_id: self.edited_article_id, comment_id: self.edited_comment_id, content: self.comment_content) { result in
                                    if result {
                                        self.presentationMode.wrappedValue.dismiss()
                                    } else {
                                        print("성공 못함")
                                    }
                                }}) {
                                    VStack{
                                Text("수정")
                                    }.padding(.all, 10)
                                    .border(Color.gray.opacity(0.8), width: 1).fixedSize(horizontal: false, vertical: true)
                                        
                            }
                            
                        } else {
                            
                            Button(action: {self.controller.put_temp_comment(password: self.hashed(pw:self.temp_password), article_id: self.community_id, nickname: self.temp_nickname, content: self.comment_content) { result in
                                    if result {
                                        self.presentationMode.wrappedValue.dismiss()
                                    } else {
                                        print("성공 못함")
                                    }
                                }}) {
                                    VStack{
                                Text("등록")
                                    }.padding(.all, 10)
                                    .border(Color.gray.opacity(0.8), width: 1).fixedSize(horizontal: false, vertical: true)
                                        
                        }
                        }
                        
                    }.fixedSize(horizontal: false, vertical: true)

                }.padding()
            } else {
                ScrollView(.vertical)  {
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

                    }
                    Divider()
                    ForEach(articleComments, id: \.self) { c in
                        VStack(alignment: .leading) {
                            HStack {
                                Text(c.nickname)
                                    .foregroundColor(Color("black"))
                                    .fontWeight(.medium)
                                Text(commentDateToString(string_date: c.createdAt))
                                .foregroundColor(Color("gray2"))
                                .fontWeight(.light)
                                Spacer()
                                if(c.userId == self.user.get_userId()) {
                                    Button(action:{self.controller.delete_comment(token: self.user.get_token(),article_id: c.articleId, comment_id: c.id) { result in
                                        if result {
                                            self.presentationMode.wrappedValue.dismiss()
                                        } else {
                                            print("성공 못함")
                                        }
                                        }}) {
                                        Image("close")
                                            .renderingMode(.original)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                }
                            }
                            HStack {
                            Text(c.content)
                                .foregroundColor(Color("black"))
                                .fontWeight(.light)
                            }.fixedSize(horizontal: false, vertical: true)
                                .padding(.bottom, 10)
                            
                            if(c.userId == self.user.get_userId()) {
                                Button(action:{
                                    self.comment_content = c.content
                                    self.edited_comment_id = c.id
                                    self.edited_article_id = c.articleId
                                    self.is_edited = true
                                    
                                }) {
                                    HStack {
                                    Text("수정")
                                        .fontWeight(.light)
                                        .foregroundColor(.black)
                                    }.padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .border(Color.gray.opacity(0.8), width: 1)
                                }
                            }
                        }.padding(.vertical, 10)
                    }
                    Divider()
                    //수정모드일 때는 취소와 수정 버튼, 작성모드일 때는 등록 버튼만
                    VStack(alignment: .leading) {
                        VStack(alignment: .leading) {
                        Text(self.user.get_nickname()).foregroundColor(Color("black"))
                        .fontWeight(.medium)
                            TextField("댓글을 작성해주세요.", text: $comment_content)
                                .font(.system(size: 16, weight: .light, design: .default))
                        }.padding(.all, 10)
                        .border(Color.gray.opacity(0.8), width: 1)
                        
                        
                    }
                    HStack {
                        
                        if is_edited {
                            
                            Button(action: {
                                self.edited_article_id = -1
                                self.edited_comment_id = -1
                                self.comment_content = ""
                                self.is_edited = false
                            }) {
                                VStack{
                                Text("취소")
                                }
                                .padding(.all, 10)
                                .border(Color.gray.opacity(0.8), width: 1).fixedSize(horizontal: false, vertical: true)
                                    
                            }
                            
                            Button(action: {self.controller.update_comment(token: self.user.get_token(), article_id: self.edited_article_id, comment_id: self.edited_comment_id, content: self.comment_content) { result in
                                    if result {
                                        self.presentationMode.wrappedValue.dismiss()
                                    } else {
                                        print("성공 못함")
                                    }
                                }}) {
                                    VStack{
                                Text("수정")
                                    }.padding(.all, 10)
                                    .border(Color.gray.opacity(0.8), width: 1).fixedSize(horizontal: false, vertical: true)
                                        
                            }
                            
                        } else {
                            
                            Button(action: {self.controller.put_comment(token: self.user.get_token(),article_id: self.community_id, content: self.comment_content) { result in
                                    if result {
                                        self.presentationMode.wrappedValue.dismiss()
                                    } else {
                                        print("성공 못함")
                                    }
                                }}) {
                                    VStack{
                                Text("등록")
                                    }.padding(.all, 10)
                                    .border(Color.gray.opacity(0.8), width: 1).fixedSize(horizontal: false, vertical: true)
                                        
                        }
                        }
                        
                    }.fixedSize(horizontal: false, vertical: true)

                }.padding()
            }
        }
        
    }
}

struct CommunityCommentView_Previews: PreviewProvider {
    static var previews: some View {
        CommunityCommentView(community_id: 13851)
    }
}
