//
//  EditorViewController.swift
//  dev_koin
//
//  Created by 정태훈 on 2020/02/02.
//  Copyright © 2020 정태훈. All rights reserved.
//

import UIKit
import SwiftUI
import RichEditorView


struct RichEditor: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> RichEditorViewController {
        let controller = RichEditorViewController()
        print("aaa")
        return controller
    }
    
    func updateUIViewController(_ uiViewController: RichEditorViewController, context: Context) {
        
    }
    
    
    typealias UIViewControllerType = RichEditorViewController
    
}
//375, 640
class RichEditorViewController: UIViewController {
    var editorView: RichEditorView = {
        var editor = RichEditorView(frame: CGRect(x: 0, y: 0, width: 375, height: 640))
        return editor
    }()
    var toolbar: RichEditorToolbar = {
        let toolbar = RichEditorToolbar(frame: CGRect(x: 0, y: 0, width: 375, height: 45))
        toolbar.options = RichEditorDefaultOption.all
        return toolbar
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("eee")
        editorView.delegate = self
        editorView.inputAccessoryView = toolbar
        editorView.placeholder = "Type some text..."
        print(editorView.frame)

        toolbar.delegate = self
        toolbar.editor = editorView

        // We will create a custom action that clears all the input text when it is pressed
        let item = RichEditorOptionItem(image: nil, title: "Clear") { toolbar in
            toolbar.editor?.html = ""
        }

        var options = toolbar.options
        options.append(item)
        toolbar.options = options
         
    }
}

extension RichEditorViewController: RichEditorDelegate {

    func richEditor(_ editor: RichEditorView, contentDidChange content: String) {
        
    }
    
}

extension RichEditorViewController: RichEditorToolbarDelegate {

    fileprivate func randomColor() -> UIColor {
        let colors: [UIColor] = [
            .red,
            .orange,
            .yellow,
            .green,
            .blue,
            .purple
        ]
        
        let color = colors[Int(arc4random_uniform(UInt32(colors.count)))]
        return color
    }

    func richEditorToolbarChangeTextColor(_ toolbar: RichEditorToolbar) {
        let color = randomColor()
        toolbar.editor?.setTextColor(color)
    }

    func richEditorToolbarChangeBackgroundColor(_ toolbar: RichEditorToolbar) {
        let color = randomColor()
        toolbar.editor?.setTextBackgroundColor(color)
    }

    func richEditorToolbarInsertImage(_ toolbar: RichEditorToolbar) {
        toolbar.editor?.insertImage("https://gravatar.com/avatar/696cf5da599733261059de06c4d1fe22", alt: "Gravatar")
    }

    func richEditorToolbarInsertLink(_ toolbar: RichEditorToolbar) {
        // Can only add links to selected text, so make sure there is a range selection first
        if toolbar.editor?.hasRangeSelection == true {
            toolbar.editor?.insertLink("http://github.com/cjwirth/RichEditorView", title: "Github Link")
        }
    }
}
