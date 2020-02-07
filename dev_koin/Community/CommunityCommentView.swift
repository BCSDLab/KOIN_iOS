//
//  CommunityCommentView.swift
//  dev_koin
//
//  Created by 정태훈 on 2020/01/30.
//  Copyright © 2020 정태훈. All rights reserved.
//

import SwiftUI

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


    init(community_id: Int) {
        self.community_id = community_id
    }
    
    var body: some View {
        var articleTitle: String = "title"
        var articleHit: Int = 0
        var articleNickname: String = ""
        var articleCommentCount: Int = 0
        var articleCreatedAt: String = ""
        var articleContent: String = ""
        var articleComments: [Comment] = []


        let article = self.controller.detail_article

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
        //print(articleContent)
        
        return ScrollView(.vertical)  {
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

struct CommunityCommentView_Previews: PreviewProvider {
    static var previews: some View {
        CommunityCommentView(community_id: 13851)
    }
}
