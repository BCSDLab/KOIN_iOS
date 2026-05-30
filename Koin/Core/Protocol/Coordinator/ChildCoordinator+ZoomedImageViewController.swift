//
//  ChildCoordinator+ZoomedImageViewController.swift
//  koin
//
//  Created by 홍기정 on 2026-05-29.
//

import UIKit

extension ChildCoordinator {
    func presentZoomedImageViewController(image: UIImage) {
        presentZoomedImageViewController(images: [image])
    }
    
    func presentZoomedImageViewController(images: [UIImage]) {
        let zoomedImageViewController = ZoomedImageViewController()
        zoomedImageViewController.setImages(images)
        
        navigationController.present(zoomedImageViewController, animated: true)
    }
    
    func presentZoomedImageViewControllerB(
        imageUrl: String,
        shouldShowTitle: Bool = true
    ) {
        presentZoomedImageViewControllerB(
            imageUrls: [imageUrl],
            shouldShowTitle: shouldShowTitle
        )
    }
    
    func presentZoomedImageViewControllerB(
        imageUrls: [String],
        initialIndexPath: IndexPath = IndexPath(row: 0, section: 0),
        shouldShowTitle: Bool = true
    ) {
        let zoomedImageViewControllerB = ZoomedImageViewControllerB(shouldShowTitle: shouldShowTitle)
        zoomedImageViewControllerB.configure(
            urls: imageUrls,
            initialIndexPath: initialIndexPath
        )
        
        navigationController.present(zoomedImageViewControllerB, animated: true)
    }
}
