//
//  BetaCommunityDetailView.swift
//  Koin
//
//  Created by 정태훈 on 2020/04/06.
//  Copyright © 2020 정태훈. All rights reserved.
//

import Foundation
import SwiftUI
import CryptoKit
import CryptoTokenKit
import Firebase
import FirebaseFirestoreSwift

// TODO: 수정 완료 시 수정된 게시글 불러오게 하기

struct BetaCommunityDetailView<T: CommonArticle, C: CommonComment>: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @ObservedObject var controller = CommunityController()
    //@EnvironmentObject var user: UserSettings
    @EnvironmentObject var config: UserConfig
    @EnvironmentObject var parentViewModel: CommunityViewModel<T>
    @ObservedObject var viewModel: CommunityDetailViewModel<T, C>
    @State var showDelete: Bool = false
    @State var showDeclaration: Bool = false
    @State var showingBlock: Bool = false
    @State var showingAlert: Bool = false
    @State var grantValue : Bool = false
    var htmlView: HTMLView = HTMLView()
    
    var deleteActionSheet: ActionSheet {
        ActionSheet(title: Text("삭제하시겠습니까?"), buttons: [
            .destructive(Text("삭제"), action: {
                if (T.self == TempArticle.self) {
                    self.viewModel.deleteAnonymousCommunity()
                } else {
                    self.viewModel.deleteCommunity()
                }
            }),
            .cancel(Text("닫기"), action: {self.showDelete.toggle()})
        ])
    }
    
    var declarationActionSheet: ActionSheet {
        ActionSheet(title: Text("신고사유"), buttons: [
            .default(Text("유출/사칭/사기"), action: {
                self.viewModel.declarationArticle(type: "유출/사칭/사기")
                self.showDeclaration.toggle()
                self.showingAlert.toggle()
            }),
            .default(Text("부적절한 내용"), action: {
                self.viewModel.declarationArticle(type: "부적절한 내용")
                self.showDeclaration.toggle()
                self.showingAlert.toggle()
            }),
            .default(Text("스팸"), action: {
                self.viewModel.declarationArticle(type: "스팸")
                self.showDeclaration.toggle()
                self.showingAlert.toggle()
            }),
            .default(Text("낚시/도배"), action: {
                self.viewModel.declarationArticle(type: "낚시/도배")
                self.showDeclaration.toggle()
                self.showingAlert.toggle()
            }),
            .default(Text("정치 관련 비하 및 선거운동"), action: {
                self.viewModel.declarationArticle(type: "정치 관련 비하 및 선거운동")
                self.showDeclaration.toggle()
                self.showingAlert.toggle()
            }),
            .default(Text("음란물/불건전한 내용"), action: {
                self.viewModel.declarationArticle(type: "음란물/불건전한 내용")
                self.showDeclaration.toggle()
                self.showingAlert.toggle()
            }),
            .default(Text("욕설/비하"), action: {
                self.viewModel.declarationArticle(type: "욕설/비하")
                self.showDeclaration.toggle()
                self.showingAlert.toggle()
            }),
            .cancel(Text("취소"), action: {self.showDeclaration.toggle()})
        ])
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
    
    init(viewModel: CommunityDetailViewModel<T, C>) {
        self.viewModel = viewModel
    }

    var body: some View {
        self.htmlView.loadHTML(self.viewModel.content)
        return VStack {
            VStack(alignment: .leading) {
                HStack {
                    Text("\(viewModel.title)")
                        .font(.system(size: 16))
                        .foregroundColor(Color.black.opacity(0.87))
                        .lineLimit(nil)
                    Text("(\(viewModel.commentCount))")
                        .font(.system(size: 16))
                        .foregroundColor(Color("light_navy"))
                    Spacer()
                    Button(action: {
                        self.showDeclaration.toggle()
                        }){
                        Text("신고")
                            .font(.system(size: 12))
                            .foregroundColor(Color("warm_grey"))
                    }.actionSheet(isPresented: $showDeclaration) {
                        self.declarationActionSheet
                    }.alert(isPresented: $showingAlert) {
                        // 이메일을 확인해보라는 Alert을 띄운 다음
                        self.config.hasUser ?
                            Alert(title: Text("신고해 주셔서 감사합니다."), message: Text("회원님의 의견은 코인 커뮤니티를 안전하게 유지하기 위해 사용하겠습니다."), primaryButton: .default(Text("돌아가기")) {
                            self.showingAlert = false
                            },
                            secondaryButton: .destructive(Text("게시글 차단하기"), action: {
                            self.viewModel.blockArticle(userId: -1)
                            self.showingAlert = false
                            self.presentationMode.wrappedValue.dismiss()
                            })) : Alert(title: Text("신고해 주셔서 감사합니다."), message: Text("회원님의 의견은 코인 커뮤니티를 안전하게 유지하기 위해 사용하겠습니다."),dismissButton: .default(Text("돌아가기")) {
                                self.showingAlert = false
                                })
                    }
                }.padding(.bottom, 8)
                
                HStack {
                    Text("조회\(viewModel.hit) · \(viewModel.nickname)")
                        .font(.system(size: 13))
                        .foregroundColor(Color("warm_grey"))
                        .lineLimit(nil)
                    Spacer()
                    Text("\(viewModel.createdAt)")
                        .font(.system(size: 12))
                        .fontWeight(.light)
                        .foregroundColor(Color("warm_grey"))
                }
                
                HStack {
                    NavigationLink(destination: BetaCommunityCommentView(viewModel: CommunityCommentViewModel(token: self.config.token, article: viewModel.item, comments: viewModel.comments ?? [C()])).environmentObject(self.config).onDisappear {
                        if(T.self == Article.self) {
                            self.viewModel.fetchDetailCommunity()
                        } else {
                            self.viewModel.fetchAnonymousDetailCommunity()
                        }
                    }) {
                        HStack {
                            Text("댓글")
                                .font(.system(size: 13))
                                .foregroundColor(Color.black)
                            Text("\(viewModel.commentCount)")
                                .font(.system(size: 13))
                                .foregroundColor(Color("light_navy"))
                        }
                        .frame(width: 71, height: 29, alignment: .center)
                        .border(Color.gray.opacity(0.8), width: 1)
                    }
                    if(T.self == TempArticle.self) {
                        SecureField("비밀번호", text: $viewModel.password)
                        NavigationLink(destination: TempRichEditor(is_edit: true, title: viewModel.title, content: viewModel.content, nickname: viewModel.nickname, article_id: viewModel.id).onDisappear {
                            self.viewModel.fetchAnonymousDetailCommunity()
                        }, isActive: self.$grantValue) {
                            Button(action : {
                                self.controller.grant_article_check(password: self.hashed(pw: self.viewModel.password), article_id: self.viewModel.id) { (result, error) in
                                    if result {
                                        self.grantValue = true
                                    } else {
                                        self.grantValue = false
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
                            self.showDelete.toggle()
                        }) {
                            Text("삭제")
                                .font(.system(size: 13))
                                .foregroundColor(Color.red)
                                .frame(width: 35, height: 29, alignment: .center)
                                .border(Color.gray.opacity(0.8), width: 1)
                        }.actionSheet(isPresented: $showDelete) {
                            self.deleteActionSheet
                        }
                    }
                    
                    if(viewModel.granted) {
                        NavigationLink(destination: RichEditor(is_edit: true, board_id: viewModel.boardId, title: viewModel.title, content: viewModel.content, article_id: viewModel.article, token: self.config.token).onDisappear {
                            self.viewModel.fetchDetailCommunity()
                            }
                        ) {
                            Text("수정")
                                .font(.system(size: 13))
                                .foregroundColor(Color.black)
                                .frame(width: 71, height: 29, alignment: .center)
                                .border(Color.gray.opacity(0.8), width: 1)
                        }
                        Button(action: {
                            self.showDelete.toggle()
                        }) {
                            Text("삭제")
                                .font(.system(size: 13))
                                .foregroundColor(Color.red)
                                .frame(width: 71, height: 29, alignment: .center)
                                .border(Color.gray.opacity(0.8), width: 1)
                        }.actionSheet(isPresented: $showDelete) {
                            self.deleteActionSheet
                        }
                        
                    }
                    
                    
                    
                }.padding(.top, 16.5)
                    .padding(.bottom, 8)
                
            }
            Divider()
            VStack {
               htmlView
            }
            
            //viewModel.html
            
            
            
        }.padding()
            .onReceive(viewModel.viewDismissalModePublisher) { shouldDismiss in
                if shouldDismiss {
                    self.presentationMode.wrappedValue.dismiss()
                }
        }.onAppear {
            self.viewModel.password = ""
            self.viewModel.loadBlockComment(userId: -1)
        }

    }
}

struct BetaCommunityDetailView_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
