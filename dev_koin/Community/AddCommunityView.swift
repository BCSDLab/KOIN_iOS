//
// Created by 정태훈 on 2020/01/26.
// Copyright (c) 2020 정태훈. All rights reserved.
//

import SwiftUI
import RichEditorView
import Aztec

struct AddCommunityView: View {
    @State var title:String = ""
    @State var content:String = ""
    @State var article_id: Int = -1
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var communityData: CommunityController
    @EnvironmentObject var user: UserSettings
    var is_edit: Bool = false
    var aztecView: AztecView = AztecView()
    var board_id: Int
    init(board_id: Int) {
        self.board_id = board_id
        print(board_id)
    }
    init(board_id: Int, title: String, content: String, article_id: Int, is_edit: Bool) {
        self.board_id = board_id
        self.title = title
        self.content = content
        self.article_id = article_id
        self.is_edit = is_edit
        print(board_id)
    }
    var body: some View {
        if is_edit{
        aztecView.set_html(html: self.content)
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
                    //print(self.aztecView.get_html())
                    self.communityData.update_article(token: self.user.get_token(),article_id: self.article_id, board_id: self.board_id, title: self.title, content: self.aztecView.get_html()) { result in
                    if result {
                        self.presentationMode.wrappedValue.dismiss()
                    } else {
                        print("성공 못함")
                    }
                    }
                } else {
                    //print(self.aztecView.get_html())
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

struct AddCommunityView_Previews: PreviewProvider {
    static var previews: some View {
        AddCommunityView(board_id: 1)
    }
}
