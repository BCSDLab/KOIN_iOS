//
//  ViewModelProtocol.swift
//  Koin
//
//  Created by 김나훈 on 3/10/24.
//

import Combine
import Foundation

protocol ViewModelProtocol {
  associatedtype Input
  associatedtype Output

  func transform(with input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never>
}
