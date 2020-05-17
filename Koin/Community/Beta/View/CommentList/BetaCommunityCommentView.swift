//
//  BetaCommunityCommentView.swift
//  Koin
//
//  Created by 정태훈 on 2020/04/06.
//  Copyright © 2020 정태훈. All rights reserved.
//

import Foundation
import SwiftUI

// 익명 댓글 적용

struct BetaCommunityCommentView<T:CommonArticle, C: CommonComment>: View {
    //@EnvironmentObject var user: UserSettings
    @EnvironmentObject var config: UserConfig
    @ObservedObject var viewModel: CommunityCommentViewModel<T,C>
    
    @State var showDelete: Bool = false
    @State var showEdit: Bool = false
    @State var showSend: Bool = false
    
    init(viewModel: CommunityCommentViewModel<T,C>) {
        self.viewModel = viewModel
    }
    
    
    var deleteActionSheet: ActionSheet {
        ActionSheet(title: Text("삭제하시겠습니까?"), buttons: [
            .destructive(Text("삭제"), action: {
                if (C.self == TempComment.self) {
                    self.viewModel.deleteAnonymousComment()
                } else {
                    self.viewModel.deleteComment()
                }
            }),
            .cancel(Text("닫기"), action: {self.showDelete.toggle()})
        ])
    }
    
    var editActionSheet: ActionSheet {
        ActionSheet(title: Text("수정하시겠습니까?"), buttons: [
            .destructive(Text("수정"), action: {
                if (C.self == TempComment.self) {
                    self.viewModel.updateAnonymousComment()
                } else {
                    self.viewModel.updateComment()
                }
                
            }),
            .cancel(Text("닫기"), action: {self.showEdit.toggle()})
        ])
    }
    
    var sendActionSheet: ActionSheet {
        ActionSheet(title: Text("제출하시겠습니까?"), buttons: [
            .destructive(Text("제출"), action: {
                print(C.self)
                if (C.self == TempComment.self) {
                    print("Temp Comment Send")
                    self.viewModel.putAnonymousComment()
                } else {
                    self.viewModel.putComment()
                }
                
            }),
            .cancel(Text("닫기"), action: {self.showSend.toggle()})
        ])
    }
    
    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading) {
                HStack {
                    Text("\(viewModel.title)")
                        .font(.system(size: 16))
                        .foregroundColor(Color.black.opacity(0.87))
                    Text("(\(viewModel.commentCount))")
                        .font(.system(size: 16))
                        .foregroundColor(Color("light_navy"))
                    Spacer()
                }.padding(.bottom, 8)
                HStack {
                    Text("조회\(viewModel.hit) · \(viewModel.nickname)")
                        .font(.system(size: 13))
                        .foregroundColor(Color("warm_grey"))
                        .lineLimit(1)
                    Spacer()
                    Text(viewModel.createdAt)
                        .font(.system(size: 12))
                        .fontWeight(.light)
                        .foregroundColor(Color("warm_grey"))
                }
                
            }.padding(.bottom, 8)
            Divider()
            ForEach(viewModel.dataSource) { r in
                CommentRow<T,C>(viewModel: r).environmentObject(self.viewModel)
            }
            VStack {
                //수정모드일 때는 취소와 수정 버튼, 작성모드일 때는 등록 버튼만
                VStack(alignment: .leading) {
                    
                    if(C.self == TempComment.self) {
                        TextField("닉네임", text: self.$viewModel.tempNickname)
                            .font(.system(size: 14))
                            .foregroundColor(Color("black"))
                            .lineLimit(1)
                            //.frame(height: 36.7)
                            .padding(.horizontal, 15.5)
                            .padding(.vertical, 7.8)
                            .border(Color.gray.opacity(0.8), width: 1)
                        SecureField("비밀번호", text: self.$viewModel.password)
                            .font(.system(size: 14))
                            .foregroundColor(Color("black"))
                            .lineLimit(1)
                            //.frame(height: 36.7)
                            .padding(.horizontal, 15.5)
                            .padding(.vertical, 7.8)
                            .border(Color.gray.opacity(0.8), width: 1)
                    } else {
                        Text(self.config.nickname)
                            .font(.system(size: 14))
                            .foregroundColor(Color("black"))
                            .padding(.top, 6)
                    }
                    
                    if(self.config.hasUser || C.self == TempComment.self) {
                        TextField("댓글을 작성해주세요.", text: self.$viewModel.content)
                            .font(.system(size: 14))
                            .foregroundColor(Color("black"))
                            .lineLimit(.max)
                            .multilineTextAlignment(.leading)
                            .frame(height: 112, alignment: .top)
                            .padding(.all, 15.5)
                            .border(Color.gray.opacity(0.8), width: 1)
                    }
                    
                    
                }
                
                HStack(spacing: 17) {
                    if self.viewModel.isEdited {
                        Button(action: {
                            self.viewModel.clearComment()
                        }) {
                            Text("취소")
                                .foregroundColor(.black)
                                .font(.system(size: 12))
                                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 27)
                                .border(Color.gray.opacity(0.8), width: 1)
                            
                        }
                        
                        Button(action: {
                            self.showDelete.toggle()
                        }) {
                            Text("삭제")
                                .font(.system(size: 12))
                                .foregroundColor(.red)
                                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 27)
                                .border(Color.gray.opacity(0.8), width: 1)
                            
                        }.actionSheet(isPresented: $showDelete) {
                            self.deleteActionSheet
                        }
                        
                        Button(action: {
                            self.showEdit.toggle()
                        }) {
                            Text("수정")
                                .font(.system(size: 12))
                                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 27)
                                .border(Color.gray.opacity(0.8), width: 1)
                            
                        }.actionSheet(isPresented: $showEdit) {
                            self.editActionSheet
                        }
                    } else {
                        if(self.config.hasUser || C.self == TempComment.self) {
                            Button(action: {
                                self.showSend.toggle()
                            }) {
                                Text("등록")
                                    .font(.system(size: 12))
                                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 27)
                                    .border(Color.gray.opacity(0.8), width: 1)
                                
                            }.actionSheet(isPresented: $showSend) {
                                self.sendActionSheet
                            }
                        }
                    }
                }.frame(height: 27)
                    .padding(.top, 9)
            }
        }.padding()
            
    }
}
