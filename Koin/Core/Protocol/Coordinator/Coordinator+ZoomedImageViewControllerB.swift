//
//  ZoomedImageViewControllerBPresentable.swift
//  koin
//
//  Created by 홍기정 on 1/5/26.
//

import UIKit

extension Coordinator {
    
    func presentZoomedImageViewControllerB(
        urls: [String],
        initialIndexPath: IndexPath
    ) {
        let zoomedViewController = ZoomedImageViewControllerB()
        zoomedViewController.configure(urls: urls, initialIndexPath: initialIndexPath)
        navigationController.present(zoomedViewController, animated: true)
    }
}
