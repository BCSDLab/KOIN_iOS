//
// Created by 정태훈 on 2020/01/27.
// Copyright (c) 2020 정태훈. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

struct TextWithAttributedString: UIViewRepresentable {

    //var content:String

    var attributedString: NSAttributedString

    func makeUIView(context: Context) -> ViewWithLabel {
        let view = ViewWithLabel(frame:CGRect.zero)
        return view
    }

    func updateUIView(_ uiView: ViewWithLabel, context: Context) {
            uiView.setString(attributedString)
    }
}
