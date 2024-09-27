//
//  IndicatorView.swift
//  koin
//
//  Created by JOOMINKYUNG on 9/19/24.
//

import UIKit

class IndicatorView {
    static func show() {
        DispatchQueue.main.async {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let window = windowScene.windows.first(where: { $0.isKeyWindow }) else { return }
            
            let loadingIndicatorView: UIActivityIndicatorView
            if let existingView = window.subviews.first(where: { $0 is UIActivityIndicatorView }) as? UIActivityIndicatorView {
                loadingIndicatorView = existingView
            } else {
                loadingIndicatorView = UIActivityIndicatorView(style: .large)
                loadingIndicatorView.frame = window.bounds
                loadingIndicatorView.backgroundColor = UIColor.black.withAlphaComponent(0.5) 
                window.addSubview(loadingIndicatorView)
            }
            
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
