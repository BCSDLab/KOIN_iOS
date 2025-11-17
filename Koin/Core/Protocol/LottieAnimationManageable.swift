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
    
    var subscriptions: Set<AnyCancellable> { get set }
    
    func setupLottieObservers()
    
    func startLottieAnimation()
    
    func stopLottieAnimation()
    
    func pauseLottieAnimation()
    
    func clearLottieAnimation()
}

extension LottieAnimationManageable where Self: UIViewController {
    
    func setupLottieObservers() {
        // 앱이 백그라운드로 갈 때 애니메이션 일시 정지
        NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)
            .sink { [weak self] _ in
                self?.pauseLottieAnimation()
            }
            .store(in: &subscriptions)
        
        // 앱이 포그라운드로 돌아올 때 애니메이션 재시작
        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
            .sink { [weak self] _ in
                self?.startLottieAnimation()
            }
            .store(in: &subscriptions)
    }
    
    func startLottieAnimation() {
        guard lottieAnimationView.animation != nil else { return }
        lottieAnimationView.play()
    }
    
    func stopLottieAnimation() {
        lottieAnimationView.stop()
    }
    
    func pauseLottieAnimation() {
        lottieAnimationView.pause()
    }
    
    func clearLottieAnimation() {
        stopLottieAnimation()
        lottieAnimationView.animation = nil // 메모리 해제를 위한 nil 할당
    }
}
