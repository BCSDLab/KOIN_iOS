//
//  RevokeModalViewController.swift
//  koin
//
//  Created by 홍기정 on 8/16/26.
//


import UIKit

final class RevokeModalViewController: KoinModalViewController {
    
    init(onRevokeButtonTapped: @escaping ()->Void) {
        let mainTitle = {
            let text = "회원탈퇴를 하시겠습니까?"
            let revokeRange = (text as NSString).range(of: "회원탈퇴")
            let fullRange = (text as NSString).range(of: text)
            return NSMutableAttributedString(string: text).then {
                $0.addAttribute(.foregroundColor, value: UIColor.appColor(.neutral700), range: fullRange)
                $0.addAttribute(.foregroundColor, value: UIColor.appColor(.danger600), range: revokeRange)
                $0.addAttribute(.font, value: UIFont.appFont(.pretendardMedium, size: 18), range: fullRange)
                $0.addAttribute(.font, value: UIFont.appFont(.pretendardBold, size: 18), range: revokeRange)
            }
        }()
        let subTitle = {
            let text = "회원탈퇴를 하면 계정 복구가 불가능합니다."
            let fullRange = (text as NSString).range(of: text)
            return NSMutableAttributedString(string: text).then {
                $0.addAttribute(.font, value: UIFont.appFont(.pretendardRegular, size: 14), range: fullRange)
                $0.addAttribute(.foregroundColor, value: UIColor.appColor(.neutral500), range: fullRange)
            }
        }()
        
        super.init(configuration: .init(
            appearance: .destructive,
            content: .attributedTitles(
                mainTitle: mainTitle,
                subTitle: subTitle
            ),
            button: .buttons(
                leftButtonTitle: "취소",
                rightButtonTitle: "회원탈퇴",
                rightButtonAction: onRevokeButtonTapped
            )
        ))
    }
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
