//
// Created by 정태훈 on 2020/01/26.
// Copyright (c) 2020 정태훈. All rights reserved.
//

import SwiftUI
import RichEditorView
import Aztec
import CryptoKit
import CryptoTokenKit

//수정 기능 확인

func hashed(pw: String) -> String{
    // 비밀번호를 먼전 Data로 변환하여
    let inputData = Data(pw.utf8)
    // SHA256을 이용해 해시 처리한 다음
    let hashed = SHA256.hash(data: inputData)
    // 해시 당 16진수 2자리로 설정하여 합친다.
    let hashPassword = hashed.compactMap {String(format: "%02x", $0)}.joined().trimmingCharacters(in: CharacterSet.newlines)
    return hashPassword
}

struct AEditorView: View {
    @State var title:String = ""
    @State var article_id: Int = -1
    @State var content: String = ""
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var communityData: CommunityController
    @EnvironmentObject var user: UserSettings
    var is_edit: Bool = false
    var board_id: Int
    var aztecView: AztecView = AztecView()
    
    init(is_edit: Bool, board_id: Int, title: String, content: String, article_id: Int) {
        self.board_id = board_id
        self.is_edit = is_edit
        if is_edit {
            _title = State(initialValue: title)
            _article_id = State(initialValue: article_id)
            _content = State(initialValue: content)
        }
    }
    
    var body: some View {
        if self.is_edit {
            aztecView.set_html(html: content)
        }
        return VStack {
            TextField("제목을 입력해주세요.", text: $title)
            Divider()
            self.aztecView
            ScrollView(.horizontal) {
                // TODO : 사진, 링크
                HStack {
                    Button(action: {self.aztecView.toggleH1()}) {
                        Text("H1")
                    }
                    Button(action: {self.aztecView.toggleH2()}) {
                        Text("H2")
                    }
                    Button(action: {self.aztecView.toggleH3()}) {
                        Text("H3")
                    }
                    Button(action: {self.aztecView.toggleBold()}) {
                        Text("B")
                    }
                    Button(action: {self.aztecView.toggleUnderline()}) {
                        Text("U")
                    }
                    Button(action: {self.aztecView.toggleItalic()}) {
                        Text("I")
                    }
                    Button(action: {self.aztecView.insertHorizontalRuler()}) {
                        Text("H")
                    }
                    Button(action: {self.aztecView.toggleBlockquote()}) {
                        Text("Q")
                    }
                    Button(action: {self.aztecView.toggleUnorderedList()}) {
                        Text("uO")
                    }
                    Button(action: {self.aztecView.toggleOrderedList()}) {
                        Text("O")
                    }
                }
            }
        }.padding()
        .navigationBarTitle("새 글 작성")
            .navigationBarItems(trailing: Button(action: {
                if self.is_edit {
                    print([self.article_id, self.board_id, self.title, self.aztecView.get_html()])
                    
                    self.communityData.update_article(token: self.user.get_token(),article_id: self.article_id, board_id: self.board_id, title: self.title, content: self.aztecView.get_html()) { result in
                    if result {
                        self.presentationMode.wrappedValue.dismiss()
                    } else {
                        print("성공 못함")
                    }
                    }
                    
                } else {
                    print([self.article_id, self.board_id, self.title, self.aztecView.get_html()])
                    self.communityData.put_article(token: self.user.get_token(), board_id: self.board_id, title: self.title, content: self.aztecView.get_html()) { result in
                    if result {
                        self.presentationMode.wrappedValue.dismiss()
                    } else {
                        print("성공 못함")
                    }
                    }
                }
            }) {
                Text("제출")
            })
    }
}

struct TempAEditorView: View {
    @State var title:String = ""
    @State var temp_password:String = ""
    @State var temp_nickname:String = ""
    @State var content:String = ""
    @State var article_id: Int = -1
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var communityData: CommunityController
    @EnvironmentObject var user: UserSettings
    var is_edit: Bool = false
    var aztecView: AztecView = AztecView()
    
    
    init(is_edit: Bool, title: String, content: String, nickname: String, article_id: Int) {
        print("isEdit : \(is_edit)")
        self.is_edit = is_edit
        if is_edit {
            aztecView.set_html(html: content)
            _title = State(initialValue: title)
            _article_id = State(initialValue: article_id)
            _temp_nickname = State(initialValue: nickname)
            _content = State(initialValue: content)
        }
    }
    
    var body: some View {
        if is_edit{
        aztecView.set_html(html: self.content)
        }
        return VStack {
            TextField("제목을 입력해주세요.", text: $title)
            Divider()
            TextField("닉네임을 입력해주세요.", text: $temp_nickname)
            Divider()
            SecureField("비밀번호를 입력해주세요.", text: $temp_password)
            Divider()
            self.aztecView
            ScrollView(.horizontal) {
                // TODO : 사진, 링크
                HStack {
                    Button(action: {self.aztecView.toggleH1()}) {
                        Text("H1")
                    }
                    Button(action: {self.aztecView.toggleH2()}) {
                        Text("H2")
                    }
                    Button(action: {self.aztecView.toggleH3()}) {
                        Text("H3")
                    }
                    Button(action: {self.aztecView.toggleBold()}) {
                        Text("B")
                    }
                    Button(action: {self.aztecView.toggleUnderline()}) {
                        Text("U")
                    }
                    Button(action: {self.aztecView.toggleItalic()}) {
                        Text("I")
                    }
                    Button(action: {self.aztecView.insertHorizontalRuler()}) {
                        Text("H")
                    }
                    Button(action: {self.aztecView.toggleBlockquote()}) {
                        Text("Q")
                    }
                    Button(action: {self.aztecView.toggleUnorderedList()}) {
                        Text("uO")
                    }
                    Button(action: {self.aztecView.toggleOrderedList()}) {
                        Text("O")
                    }
                }
            }
        }.padding()
        .navigationBarTitle("새 글 작성")
            .navigationBarItems(trailing: Button(action: {
                if self.is_edit {
                    print(self.aztecView.get_html())
                    self.communityData.update_temp_article(password: hashed(pw:self.temp_password),article_id: self.article_id, title: self.title, content: self.aztecView.get_html()) { result in
                    if result {
                        self.presentationMode.wrappedValue.dismiss()
                    } else {
                        print("성공 못함")
                    }
                    }
                } else {
                    print(self.aztecView.get_html())
                    self.communityData.put_temp_article(password: hashed(pw:self.temp_password), title: self.title, nickname: self.temp_nickname, content: self.aztecView.get_html()) { result in
                    if result {
                        self.presentationMode.wrappedValue.dismiss()
                    } else {
                        print("성공 못함")
                    }
                    }
                }
            }) {
                Text("제출")
            })
    }
}

struct AddCommunityView: View {
    var title:String = ""
    var temp_password:String = ""
    var temp_nickname:String = ""
    var content:String = ""
    var article_id: Int = -1
    @EnvironmentObject var communityData: CommunityController
    @EnvironmentObject var user: UserSettings
    var is_edit: Bool = false
    var aztecView: AztecView = AztecView()
    var board_id: Int
    
    init(board_id: Int) {
        self.board_id = board_id
    }
    init(board_id: Int, title: String, content: String, article_id: Int, is_edit: Bool) {
        self.board_id = board_id
        self.title = title
        self.content = content
        self.article_id = article_id
        self.is_edit = is_edit
        print(content)
    }
    
    var body: some View {
            if self.board_id == -2 {
                return AnyView(TempAEditorView(is_edit: self.is_edit, title: self.title, content: self.content, nickname: self.temp_nickname, article_id: self.article_id))
            } else {
                return AnyView(AEditorView(is_edit: self.is_edit, board_id: self.board_id, title: self.title, content: self.content, article_id: self.article_id))
            }
            
    }
    
}

struct AddCommunityView_Previews: PreviewProvider {
    static var previews: some View {
        AddCommunityView(board_id: 1)
    }
}
