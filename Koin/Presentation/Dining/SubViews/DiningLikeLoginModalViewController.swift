//
//  DiningLikeLoginModalViewController.swift
//  koin
//
//  Created by 김나훈 on 7/30/24.
//

import Combine
import Then
import UIKit

final class DiningLikeLoginModalViewController: LoginModalViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        updateMessageLabel(text: "더 맛있는 학식을 먹는 방법,\n로그인하고 좋아요를 남겨주세요!", textColor: .appColor(.neutral700))
        updateSubMessageLabel(text: "여러분의 좋아요가 영양사님이 더 나은,\n식단을 제공할 수 있도록 도와줍니다.", textColor: .appColor(.gray))
    }
}
