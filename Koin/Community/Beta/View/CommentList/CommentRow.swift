//
//  CommentRow.swift
//  Koin
//
//  Created by 정태훈 on 2020/04/06.
//  Copyright © 2020 정태훈. All rights reserved.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseFirestoreSwift

struct CommentRow<T: CommonArticle, C: CommonComment>: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    private let viewModel: CommentRowViewModel<C>
    @EnvironmentObject var user: UserSettings
    @EnvironmentObject var parentViewModel: CommunityCommentViewModel<T,C>
    @State var showDeclaration: Bool = false
    @State var showingAlert: Bool = false
    
    init(viewModel: CommentRowViewModel<C>) {
        self.viewModel = viewModel
    }
    
    var declarationActionSheet: ActionSheet {
        ActionSheet(title: Text("신고사유"), buttons: [
            .default(Text("유출/사칭/사기"), action: {
                self.viewModel.declarationComment(type: "유출/사칭/사기")
                self.showDeclaration.toggle()
                self.showingAlert.toggle()
            }),
            .default(Text("부적절한 내용"), action: {
                self.viewModel.declarationComment(type: "부적절한 내용")
                self.showDeclaration.toggle()
                self.showingAlert.toggle()
            }),
            .default(Text("스팸"), action: {
                self.viewModel.declarationComment(type: "스팸")
                self.showDeclaration.toggle()
                self.showingAlert.toggle()
            }),
            .default(Text("낚시/도배"), action: {
                self.viewModel.declarationComment(type: "낚시/도배")
                self.showDeclaration.toggle()
                self.showingAlert.toggle()
            }),
            .default(Text("정치 관련 비하 및 선거운동"), action: {
                self.viewModel.declarationComment(type: "정치 관련 비하 및 선거운동")
                self.showDeclaration.toggle()
                self.showingAlert.toggle()
            }),
            .default(Text("음란물/불건전한 내용"), action: {
                self.viewModel.declarationComment(type: "음란물/불건전한 내용")
                self.showDeclaration.toggle()
                self.showingAlert.toggle()
            }),
            .default(Text("욕설/비하"), action: {
                self.viewModel.declarationComment(type: "욕설/비하")
                self.showDeclaration.toggle()
                self.showingAlert.toggle()
            }),
            .cancel(Text("취소"), action: {self.showDeclaration.toggle()})
        ])
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(viewModel.nickname)
                    .font(.system(size: 14))
                    .foregroundColor(Color("black"))
                    .lineLimit(1)
                Text(viewModel.createAt)
                    .font(.system(size: 12))
                    .foregroundColor(Color("grey2"))
                    .fontWeight(.light)
                Spacer()
                /*
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
                    Alert(title: Text("신고해 주셔서 감사합니다."), message: Text("회원님의 의견은 코인 커뮤니티를 안전하게 유지하기 위해 사용하겠습니다."), dismissButton: .default(Text("돌아가기")) {
                        self.showingAlert = false
                        })
                }*/
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
                    Alert(title: Text("신고해 주셔서 감사합니다."), message: Text("회원님의 의견은 코인 커뮤니티를 안전하게 유지하기 위해 사용하겠습니다.\n\n추가로 댓글 차단이 필요하시다면 \"댓긇 차단하기\" 버튼을 누르시면 됩니다."), primaryButton: .default(Text("돌아가기")) {
                        self.showingAlert = false
                        },
                          secondaryButton:  .destructive(Text("댓글 차단하기"), action: {
                            self.viewModel.blockComment(userId: self.user.get_userId())
                            self.showingAlert = false
                            self.presentationMode.wrappedValue.dismiss()
                          }))
                }
                
                
            }
            HStack {
                Text(viewModel.content)
                    .font(.system(size: 14))
                    .foregroundColor(Color("black"))
                    .fontWeight(.light)
            }.padding(.bottom, 8.5)
            HStack {
                Button(action:{
                    if C.self == TempComment.self {
                        self.parentViewModel.editComment(id: self.viewModel.id,nickname: self.viewModel.nickname, content: self.viewModel.content)
                    } else {
                        self.parentViewModel.editComment(id: self.viewModel.id, content: self.viewModel.content)
                    }
                }) {
                    HStack {
                        Text("수정")
                            .font(.system(size: 12))
                            .fontWeight(.light)
                            .foregroundColor(.black)
                            .frame(width: 50, height: 30, alignment: .center)
                    }
                    .border(Color.gray.opacity(0.8), width: 1)
                }
                
                
                
            }
            
        }.padding(.vertical, 10)
    }
}
