//
//  CommunityCommentView.swift
//  dev_koin
//
//  Created by 정태훈 on 2020/01/30.
//  Copyright © 2020 정태훈. All rights reserved.
//

import SwiftUI

struct CommunityCommentView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var controller: CommunityController
    var community_id: Int
    @State var comment_content: String = ""


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
        print(articleContent)
        
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

            }
            Divider()
            ForEach(articleComments, id: \.self) { c in
                VStack {
                    HStack {
                        Text(c.nickname)
                        Text(c.createdAt)
                    }
                    Text(c.content)
                }
            }
            Divider()
            VStack {
                TextField("댓글을 작성해주세요.", text: $comment_content)
                HStack {
                    Button(action: {}) {
                        Text("취소")
                    }
                    Button(action: {}) {
                        Text("등록")
                    }
                }
            }

        }.padding()
        
    }
}

struct CommunityCommentView_Previews: PreviewProvider {
    static var previews: some View {
        CommunityCommentView(community_id: 13851)
    }
}
