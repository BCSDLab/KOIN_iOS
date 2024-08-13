//
//  UIViewController+ToastMessage.swift
//  koin
//
//  Created by 김나훈 on 8/13/24.
//

import UIKit

extension UIViewController {
    func showToast(message: String) {
        let toastLabel = PaddingLabel(frame: CGRect(x: 16, y: view.frame.height - 81, width: view.frame.width - 32, height: 54))
        toastLabel.backgroundColor = UIColor.appColor(.primary900).withAlphaComponent(0.8)
        toastLabel.textColor = UIColor.appColor(.neutral0)
        toastLabel.font = UIFont.appFont(.pretendardRegular, size: 14)
        toastLabel.textAlignment = .left
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 5
        toastLabel.clipsToBounds = true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 3.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}

// TODO: 이거 공통으로 사용가능한 컴포넌트로 만들기. left를 init으로 받기
final class PaddingLabel: UILabel {
    var textInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textInsets))
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + textInsets.left + textInsets.right,
                      height: size.height + textInsets.top + textInsets.bottom)
    }
}
