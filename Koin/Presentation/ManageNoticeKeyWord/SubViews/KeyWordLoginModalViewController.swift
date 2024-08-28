//
//  KeyWordLoginModalViewController.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/28/24.
//

import Foundation

final class KeyWordLoginModalViewController: LoginModalViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        updateMessageLabel(text: "카워드 알림을 받으려면\n로그인이 필요해요.", textColor: .appColor(.neutral700))
        updateSubMessageLabel(text: "로그인 후 간편하게 공지사항 키워드\n알림을 받아보세요!", textColor: .appColor(.gray))
    }
}
