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
    private var disposables = Set<AnyCancellable>()
    let userFetcher: UserFetchable
    
    var error = UserError.parsing(description: "")
    
    init(userFetcher: UserFetcher) {
        self.userFetcher = userFetcher
    }
    
    func login() {
        userFetcher.LogIn(email: email, password: password)
            .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: { value in
            print(value)
            switch value {
                case .failure:
                    break
                case .finished:
                break
            }
        }, receiveValue: { user in
            print(user.token!)
            self.loginResult.send(user)
        }).store(in: &disposables)
    }
}
