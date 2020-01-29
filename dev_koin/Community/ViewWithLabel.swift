//
// Created by 정태훈 on 2020/01/27.
// Copyright (c) 2020 정태훈. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

class ViewWithLabel : UIView {
    private var label = UILabel()

    override init(frame: CGRect) {
        super.init(frame:frame)
        self.addSubview(label)
        label.numberOfLines = 0
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func setString(_ attributedString:NSAttributedString) {
        self.label.attributedText = attributedString
    }
}