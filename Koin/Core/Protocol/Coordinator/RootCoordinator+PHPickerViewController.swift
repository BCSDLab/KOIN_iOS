//
//  RootCoordinator+PHPickerViewController.swift
//  koin
//
//  Created by 홍기정 on 12/17/25.
//

import UIKit
import PhotosUI

extension RootCoordinator {
    func presentPHPickerViewController(
        filter: PHPickerFilter,
        selectionLimit: Int,
        completion: @escaping (UIImage) -> Void
    ) {
        var configuration = PHPickerConfiguration()
        configuration.filter = filter
        configuration.selectionLimit = selectionLimit
        
        pickerCompletion = completion
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        navigationController.present(picker, animated: true, completion: nil)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        
        let completion = pickerCompletion
        self.pickerCompletion = nil
        
        if let provider = results.first?.itemProvider,
           provider.canLoadObject(ofClass: UIImage.self) {
            provider.loadObject(ofClass: UIImage.self) { image, error in
                DispatchQueue.main.async {
                    if let selectedImage = image as? UIImage {
                        completion?(selectedImage)
                    }
                }
            }
        }
    }
}
