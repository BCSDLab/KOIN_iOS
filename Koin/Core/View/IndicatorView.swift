//
//  IndicatorView.swift
//  koin
//
//  Created by JOOMINKYUNG on 9/19/24.
//

import UIKit

class IndicatorView: UIView {
    static let shared = IndicatorView()
    
    private let containerView = UIView()
    private let activityIndicator = UIActivityIndicatorView()
    
    private init() {
        super.init(frame: .zero)
        setupIndicator()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupIndicator() {
        containerView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.style = .large
        activityIndicator.color = UIColor.gray
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(activityIndicator)
    }
    
    func show() {
        guard let windowScene = UIApplication.shared.connectedScenes
            .first as? UIWindowScene,
              let window = windowScene.windows.first else { return }
        
        window.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        activityIndicator.startAnimating()
    }
   
    func dismiss() {
        activityIndicator.stopAnimating()
        containerView.removeFromSuperview()
    }
}
