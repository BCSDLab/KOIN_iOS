//
//  IndicatorView.swift
//  koin
//
//  Created by JOOMINKYUNG on 9/19/24.
//

import UIKit
import SnapKit

final class IndicatorView {
    /// dimmed가 false면 배경 없이 인디케이터만 보인다. 바깥 터치는 그대로 막는다.
    static func show(dimmed: Bool = true) {
        DispatchQueue.main.async {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let window = windowScene.windows.first(where: { $0.isKeyWindow }) else { return }
            
            let loadingIndicatorView: UIActivityIndicatorView
            if let existingView = window.subviews.first(where: { $0 is UIActivityIndicatorView }) as? UIActivityIndicatorView {
                loadingIndicatorView = existingView
            } else {
                loadingIndicatorView = UIActivityIndicatorView(style: .large)
                window.addSubview(loadingIndicatorView)
                loadingIndicatorView.snp.makeConstraints {
                    $0.edges.equalToSuperview()
                }
            }
            loadingIndicatorView.backgroundColor = dimmed ? UIColor.black.withAlphaComponent(0.5) : .clear

            loadingIndicatorView.startAnimating()
        }
    }
    
    static func dismiss() {
        DispatchQueue.main.async {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first(where: { $0.isKeyWindow }) else { return }
            
            window.subviews.filter({ $0 is UIActivityIndicatorView }).forEach { $0.removeFromSuperview() }
        }
    }
}
