//
//  FindPasswordViewModel.swift
//  Koin
//
//  Created by 정태훈 on 2020/05/13.
//  Copyright © 2020 정태훈. All rights reserved.
//

import Foundation
import Combine

class FindPasswordViewModel: ObservableObject {
    @Published var email = ""
    
    private var disposables = Set<AnyCancellable>()
    let userFetcher: UserFetchable
    
    var error: UserError? = nil
    
    @Published var showingSuccessAlert = false
    @Published var showingAlert = false
    
    var result = PassthroughSubject<Bool, Never>()
    var errorResult = PassthroughSubject<UserError, Never>()
    
    var errorText: String {
        switch(error) {
            case .network(let description):
                return description
            case .parsing(let description):
                return description
            default:
                return ""
        }
    }
    
    init(userFetcher: UserFetcher) {
        self.userFetcher = userFetcher
    }
    
    func findPassword() {
        userFetcher.FindPassword(email: email)
            .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: { value in
            switch value {
                case .failure(let error):
                    self.error = error
                    self.showingSuccessAlert = false
                    self.errorResult.send(error)
                    self.result.send(false)
                    break
                case .finished:
                    break
            }
        }, receiveValue: { result in
            self.showingSuccessAlert = true
            self.result.send(true)
            }).store(in: &disposables)
    }
}
