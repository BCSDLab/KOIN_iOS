//
//  LottieAnimationManageable.swift
//  koin
//
//  Created by 이은지 on 9/8/25.
//

import UIKit
import Lottie
import Combine

/// Lottie 애니메이션 생명주기 관리 프로토콜
protocol LottieAnimationManageable: AnyObject {

    var lottieAnimationView: LottieAnimationView { get }
    
    func setupLottie()
    
    func startLottieAnimation()
    
    func clearLottieAnimation()
}

extension LottieAnimationManageable {
    
    func setupLottie() {
        lottieAnimationView.backgroundBehavior = .pauseAndRestore
    }
    
    func startLottieAnimation() {
        guard lottieAnimationView.animation != nil else { return }
        lottieAnimationView.play()
    }
    
    func clearLottieAnimation() {
        lottieAnimationView.stop()
        lottieAnimationView.animation = nil // 메모리 해제를 위한 nil 할당
    }
}
