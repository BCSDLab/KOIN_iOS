//
//  ChildCoordinator+PHPickerController.swift
//  koin
//
//  Created by 홍기정 on 2026-05-29.
//

import UIKit
import PhotosUI

extension ChildCoordinator {
    func presentPHPickerViewController(
        filter: PHPickerFilter = .images,
        selectionLimit: Int = 1,
        completion: @escaping (UIImage) -> Void
    ) {
        parentCoordinator.presentPHPickerViewController(
            filter: filter,
            selectionLimit: selectionLimit,
            completion: completion
        )
    }
}
