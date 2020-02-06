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
    var body: some View {
        if is_edit{
        aztecView.set_html(html: self.content)
        }
        return VStack {
            TextField("제목을 입력해주세요.", text: $title)
            Divider()
            self.aztecView
        }.padding()
        .navigationBarTitle("새 글 작성")
            .navigationBarItems(trailing: Button(action: {
                if self.is_edit {
                    print(self.aztecView.get_html())
                    self.communityData.update_article(token: self.user.get_token(),article_id: self.article_id, board_id: 1, title: self.title, content: self.aztecView.get_html()) { result in
                    if result {
                        self.presentationMode.wrappedValue.dismiss()
                    } else {
                        print("성공 못함")
                    }
                    }
                } else {
                    print(self.aztecView.get_html())
                    self.communityData.put_article(token: self.user.get_token(), board_id: 1, title: self.title, content: self.aztecView.get_html()) { result in
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
        AddCommunityView()
    }
}
