//
//  LottieView.swift
//  Koin
//
//  Created by 정태훈 on 2020/07/05.
//  Copyright © 2020 정태훈. All rights reserved.
//

import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    
    //makeCoordinator를 구현하여 제약사항을 구현합니다.
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    
    //json파일명을 받을 프로퍼티
    var filename: String
    
    //lottie View
    var animationView = AnimationView()
    
    
    class Coordinator: NSObject {
        var parent: LottieView
        
        init(_ animationView: LottieView) {
            //frame을 LottieView로 할당합니다.
            self.parent = animationView
            super.init()
        }
    }
    
    func makeUIView(context: UIViewRepresentableContext<LottieView>) -> UIView {
        let view = UIView()
        
        let path = Bundle.main.path(forResource: filename, ofType: "json")
        
        //lottie 구현뷰
        animationView.animation = Animation.named(path!)
        animationView.insetsLayoutMarginsFromSafeArea = false
        animationView.contentMode = .scaleAspectFill
        animationView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(animationView)
        
        NSLayoutConstraint.activate([
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor),
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])
        
        //애니메이션이 계속 반복되게합니다.
        animationView.loopMode = .loop
        animationView.play()
        return view
    }
    
    //updateView가 구현되어있지않습니다.
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<LottieView>) {
        //변경된 json으로 애니메이션을 변경합니다.
        animationView.animation = Animation.named(filename)
        animationView.play()
    }
}
