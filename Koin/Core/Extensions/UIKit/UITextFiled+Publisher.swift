//
//  UITextFiled+Publisher.swift
//  koin
//
//  Created by 김나훈 on 8/13/24.
//

import Combine
import UIKit

extension UITextField {
    func textPublisher() -> AnyPublisher<String, Never> {
        NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: self)
            .compactMap { ($0.object as? UITextField)?.text }
            .eraseToAnyPublisher()
    }
}
