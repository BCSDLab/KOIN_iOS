//
//  ZoomedImageViewNavigationController.swift
//  koin
//
//  Created by 홍기정 on 11/14/25.
//

import UIKit

final class ZoomedImageViewControllerB: UINavigationController {
    
    // MARK: - Properties
    let rootViewController = ZoomedImageRootViewController()
    
    // MARK: - Initializer
    init() {
        super.init(rootViewController: rootViewController)
        
        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configure
    func configure(urls: [String], initialIndexPath: IndexPath) {
        rootViewController.configure(urls: urls, initialIndexPath: initialIndexPath)
    }
}
