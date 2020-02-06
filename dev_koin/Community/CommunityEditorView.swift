//
// Created by 정태훈 on 2020/02/01.
// Copyright (c) 2020 정태훈. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI
import RichEditorView


class ViewWithEditor : UIView {
    private var editor = RichEditorView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        editor.sizeToFit()
        editor.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        editor.placeholder = "내용을 입력해주세요."
        print(editor.frame)
        self.addSubview(editor)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func get_html() -> String {
        return editor.html
    }
    func set_html(html: String) {
        editor.html = html
    }
}


struct EditorView: UIViewRepresentable {
    
    var editor: ViewWithEditor
    var content: String
    
    init() {
        editor = ViewWithEditor(frame: CGRect.zero)
        self.content = ""
    }
    
    init(content: String) {
        editor = ViewWithEditor(frame: CGRect.zero)
        self.content = content
    }

    func makeUIView(context: Context) -> ViewWithEditor {
        return editor
    }
    

    func updateUIView(_ uiView: ViewWithEditor, context: Context) {
        print(self.content)
        uiView.set_html(html: self.content)
    }
    
    func get_html() -> String {
        return editor.get_html()
    }
    func set_html(html: String) {
        editor.set_html(html: html)
    }
}


