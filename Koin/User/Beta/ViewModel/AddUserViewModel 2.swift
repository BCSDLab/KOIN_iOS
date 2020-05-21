//
//  AddUserViewModel.swift
//  Koin
//
//  Created by 정태훈 on 2020/05/13.
//  Copyright © 2020 정태훈. All rights reserved.
//

import Foundation
import Combine

class AddUserViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var validPassword = ""
    @Published var checkKoin = false
    @Published var checkPersonality = false
    
    @Published var showingSuccessAlert = false
    @Published var showingAlert = false
    @Published var showingKoin = false
    @Published var showingPersonal = false
    
    var loginResult = PassthroughSubject<AddUserResponseData, Never>()
    var errorResult = PassthroughSubject<UserError, Never>()
    private var disposables = Set<AnyCancellable>()
    let userFetcher: UserFetchable
    
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
    
    func addUser() {
        if (checkKoin && checkPersonality) {
            userFetcher.AddUser(email: email, password: password)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { value in
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
                }, receiveValue: { result in
                    print(result)
                    self.showingSuccessAlert = true
                    self.loginResult.send(result)
                }).store(in: &disposables)
        } else {
            self.error = UserError.parsing(description: "체크되지 않은 이용약관이 있습니다.")
            self.showingSuccessAlert = false
            self.errorResult.send(UserError.parsing(description: "체크되지 않은 이용약관이 있습니다."))
        }
    }
}
