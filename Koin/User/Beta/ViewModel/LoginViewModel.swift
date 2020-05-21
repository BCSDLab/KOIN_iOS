//
//  LoginViewModel.swift
//  Koin
//
//  Created by 정태훈 on 2020/05/13.
//  Copyright © 2020 정태훈. All rights reserved.
//

import Foundation
import Combine

class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    
    var loginResult = PassthroughSubject<UserData, Never>()
    var errorResult = PassthroughSubject<UserError, Never>()
    private var disposables = Set<AnyCancellable>()
    let userFetcher: UserFetchable
    
    @Published var showingSuccessAlert = false
    @Published var showingAlert = false
    
    var error: UserError? = nil
    
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
    
    func login() {
        userFetcher.LogIn(email: email, password: password)
            .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: { value in
            print(value)
            switch value {
                case .failure(let error):
                    print(error)
                    self.error = error
                    self.showingSuccessAlert = false
                    self.errorResult.send(error)
                    break
                case .finished:
                break
            }
        }, receiveValue: { user in
            self.showingSuccessAlert = true
            self.loginResult.send(user)
        }).store(in: &disposables)
    }
}
