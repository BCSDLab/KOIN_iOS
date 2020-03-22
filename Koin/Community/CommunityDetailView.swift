//
// Created by 정태훈 on 2020/01/26.
// Copyright (c) 2020 정태훈. All rights reserved.
//

import SwiftUI
import UIKit
import CryptoKit
import CryptoTokenKit
import PKHUD


struct CommunityDetailView: View {
    @ObservedObject var controller: CommunityController
    @EnvironmentObject var user: UserSettings
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var community_id: Int
    var board_id: Int
    let baseFontSize: CGFloat = 16
    @State var isCommentOn: Bool = false
    var htmlView: HTMLView = HTMLView()
    var getUserId: Int = -1
    @State var grantValue : Bool = false
    @State var temp_password: String = ""
    
    @State var errorText: String = ""
    @State var showError: Bool = false
    
    @State var article: Article = Article()
    @State var tempArticle: TempArticle = TempArticle()
    @State var articleTitle: String = "title"
    @State var articleHit: Int = 0
    @State var articleNickname: String = ""
    @State var articleCommentCount: Int = 0
    @State var articleCreatedAt: String = ""
    @State var articleContent: String = ""


    init(community_id: Int, board_id: Int, user_id: Int) {
        self.board_id = board_id
        controller = CommunityController(board_id: board_id)
        self.community_id = community_id
        self.getUserId = user_id
        
    }
    
    init(community_id: Int) {
        self.board_id = -2
        self.controller = CommunityController(board_id: -2)
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
        
            return VStack {
                        VStack(alignment: .leading) {
                            HStack {
                                Text("\(self.articleTitle)")
                                .font(.system(size: 16))
                                .foregroundColor(Color.black.opacity(0.87))
                                .lineLimit(nil)
                            Text("(\(self.articleCommentCount))")
                                .font(.system(size: 16))
                            .foregroundColor(Color("light_navy"))
                            }.padding(.bottom, 8)
                            HStack {
                                Text("조회\(self.articleHit) · \(self.articleNickname)")
                                    .font(.system(size: 13))
                                    .foregroundColor(Color("warm_grey"))
                                .lineLimit(nil)
                                Spacer()
                                Text(self.articleCreatedAt)
                                    .font(.system(size: 12))
                                    .fontWeight(.light)
                                    .foregroundColor(Color("warm_grey"))
                            }
                            HStack {
                                NavigationLink(destination: CommunityCommentView(community_id: self.community_id).environmentObject(self.controller).navigationBarTitle("댓글", displayMode: .inline)) {
                                    HStack {
                                    Text("댓글")
                                        .font(.system(size: 13))
                                        .foregroundColor(Color.black)
                                        Text("\(self.articleCommentCount)")
                                            .font(.system(size: 13))
                                        .foregroundColor(Color("light_navy"))
                                    }
                                        .frame(width: 71, height: 29, alignment: .center)
                                    .border(Color.gray.opacity(0.8), width: 1)
                                }
                                if(self.user.get_userId() == self.getUserId) {
                                    NavigationLink(destination: RichEditor(is_edit: true, board_id: self.board_id, title: self.articleTitle, content: self.articleContent, article_id: self.community_id, token: self.user.get_token())
                                    ) {
                                    Text("수정")
                                        .font(.system(size: 13))
                                        .foregroundColor(Color.black)
                                        .frame(width: 71, height: 29, alignment: .center)
                                    .border(Color.gray.opacity(0.8), width: 1)
                                }
                                Button(action: {
                                self.controller.delete_article(token: self.user.get_token(), article_id: self.community_id) { (result, error) in
                                    if result {
                                        self.errorText = ""
                                        self.showError = false
                                        self.presentationMode.wrappedValue.dismiss()
                                    } else {
                                        self.errorText = (error?.localizedDescription)!
                                        self.showError = true
                                    }
                                }}) {
                                    Text("삭제")
                                        .font(.system(size: 13))
                                            .foregroundColor(Color.red)
                                            .frame(width: 71, height: 29, alignment: .center)
                                    .border(Color.gray.opacity(0.8), width: 1)
                                }
                                
                                }
                                
                                //익명일 경우, 비밀번호 맞을 경우에만 접근 가능하게 하기
                                if(self.board_id == -2) {
                                    SecureField("비밀번호", text: self.$temp_password)
                                    NavigationLink(destination: TempRichEditor(is_edit: true, title: self.articleTitle, content: self.articleContent, nickname: self.articleNickname, article_id: self.community_id), isActive: self.$grantValue) {
                                        Button(action : {
                                            self.controller.grant_article_check(password: self.hashed(pw: self.temp_password), article_id: self.community_id) { (result, error) in
                                                //self.grantValue = true
                                                if result {
                                                    self.errorText = ""
                                                    self.grantValue = true
                                                    self.showError = false
                                                } else {
                                                    self.grantValue = false
                                                    self.errorText = (error?.localizedDescription)!
                                                    self.showError = true
                                                }
                                                }
                                        }) {
                                            Text("수정")
                                                .font(.system(size: 13))
                                            .foregroundColor(Color.black)
                                            .frame(width: 35, height: 29, alignment: .center)
                                            .border(Color.gray.opacity(0.8), width: 1)
                                        }
                                }
                                    Button(action: {
                                        self.controller.delete_temp_article(password: self.hashed(pw:self.temp_password), article_id: self.community_id) { (result, error) in
                                if result {
                                    self.errorText = ""
                                    self.showError = false
                                    self.presentationMode.wrappedValue.dismiss()
                                } else {
                                    self.errorText = (error?.localizedDescription)!
                                    self.showError = true
                                }
                                }}
                                    
                                    ) {
                                    Text("삭제")
                                        .font(.system(size: 13))
                                            .foregroundColor(Color.red)
                                            .frame(width: 35, height: 29, alignment: .center)
                                    .border(Color.gray.opacity(0.8), width: 1)
                                }
                                
                                }
                                Button(action: {
                                    let url: NSURL = URL(string: "http://pf.kakao.com/_twMBd")! as NSURL

                                    UIApplication.shared.open(url as URL)
                                }) {
                                    HStack {
                                    Text("신고")
                                        .font(.system(size: 13))
                                        .foregroundColor(Color.red)
                                    }
                                        .frame(width: 35, height: 29, alignment: .center)
                                    .border(Color.gray.opacity(0.8), width: 1)
                                }
                            }.padding(.top, 16.5)
                                .padding(.bottom, 8)

                        }
                        Divider()
                        
                        self.htmlView
                        


                    }.padding()
                .alert(isPresented: self.$showError) {
                    // 이메일을 확인해보라는 Alert을 띄운 다음
                    Alert(title: Text("에러"), message: Text(self.errorText), dismissButton: .default(Text("닫기")) {
                    // 돌아가기 버튼을 누르면 Alert은 꺼지고
                    self.showError = false
                    })
                }
                .onAppear{
                    print("CommunityDetail appear")
                    
                    HUD.show(.progress)
                    DispatchQueue.main.async {
                        if (self.board_id == -2) {
                            self.controller.load_temp_community(article_id: self.community_id) { (result, error) in
                                if result {
                                    self.errorText = ""
                                    self.showError = false
                                    self.tempArticle = self.controller.detail_temp_article
                                    self.articleTitle = self.tempArticle.title
                                    self.articleHit = self.tempArticle.hit
                                    self.articleNickname = self.tempArticle.nickname
                                    if let commentCount = self.tempArticle.commentCount {
                                        self.articleCommentCount = commentCount
                                    }
                                    self.articleCreatedAt = self.dateToString(string_date: self.tempArticle.createdAt)
                                    if let content = self.tempArticle.content {
                                        self.articleContent = content
                                    }
                                    self.htmlView.loadHTML(self.articleContent)
                                    print("set")
                                } else {
                                    self.errorText = (error?.localizedDescription)!
                                    self.showError = true
                                }
                            }
                            
                        } else {
                            self.controller.load_community(article_id: self.community_id) { (result, error) in
                                if result {
                                    self.errorText = ""
                                    self.showError = false
                                    self.article = self.controller.detail_article
                                    self.articleTitle = self.article.title
                                        self.articleHit = self.article.hit
                                        self.articleNickname = self.article.nickname
                                        self.articleCommentCount = self.article.commentCount
                                    self.articleCreatedAt = self.dateToString(string_date: self.article.createdAt)
                                        self.articleContent = self.article.content
                                        //print(self.articleContent)
                                        self.htmlView.loadHTML(self.articleContent)
                                        print("set")
                                } else {
                                    self.errorText = (error?.localizedDescription)!
                                    self.showError = true
                                }
                            }
                            
                        }
                        HUD.hide()
                    }
                    
                    
            }.onDisappear{
                print("CommunityDetail disappear")
            }

        }
}

struct CommunityDetailView_Previews: PreviewProvider {
    static var previews: some View {
        CommunityDetailView(community_id: 13851, board_id: 1, user_id: 316)
    }
}
