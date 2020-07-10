//
//  MyInfoViewModel.swift
//  Koin
//
//  Created by 정태훈 on 2020/05/16.
//  Copyright © 2020 정태훈. All rights reserved.
//

import Foundation
import Combine

class MyInfoViewModel: ObservableObject {
    @Published var editName: String = ""
    @Published var editNickname: String = ""
    @Published var editPhoneNumber: String = ""
    @Published var editStudentNumber: String = ""
    @Published var gender: Int = -1
    
    @Published var showNicknameModal: Bool = false
    @Published var showPhoneModal: Bool = false
    @Published var showNameModal: Bool = false
    @Published var showStudentNumberModal: Bool = false
    
    var user: UserData? = nil
    
    //@Published var showingSuccessAlert = false
    @Published var showingErrorAlert = false
    @Published var showingAlert = false
    
    var errorResult = PassthroughSubject<UserError, Never>()
    var deleteResult = PassthroughSubject<Bool, Never>()
    var userResult = PassthroughSubject<UserData, Never>()
    var genderResult = PassthroughSubject<UserData, Never>()
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
    
    func loadUser(user: UserData?) {
        self.user = user
        self.gender = user?.user?.gender ?? -1
    }
    
    var token: String {
        return user?.token ?? ""
    }
    
    var portalAccount: String {
        return user?.user?.portalAccount ?? ""
    }
    var name: String {
        return user?.user?.name ?? ""
    }
    var nickname: String {
        return user?.user?.nickname ?? ""
    }
    var anonymousNickname: String {
        return user?.user?.anonymousNickname ?? ""
    }
    var phoneNumber: String {
        return user?.user?.phoneNumber ?? ""
    }
    var studentNumber: String {
        return user?.user?.studentNumber ?? ""
    }
    var major: String {
        return user?.user?.major ?? ""
    }
    
    // 해당 형식으로 보내주기
    
    func updateUser() {
        userFetcher.PutUser(token: token, password: nil, name: editName.isEmpty ? nil : editName, nickname: editNickname.isEmpty ? nil : editNickname, gender: gender == -1 ? nil : gender, identity: nil, isGraduated: nil, studentNumber: editStudentNumber.isEmpty ? nil:editStudentNumber, phoneNumber: editPhoneNumber.isEmpty ? nil: editPhoneNumber.toPhoneNumber())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { value in
                print(value)
                switch value {
                    case .failure(let error):
                        print(error)
                        self.error = error
                        self.errorResult.send(error)
                        break
                    case .finished:
                        break
                }
            }, receiveValue: { user in
                self.user?.user = user
                self.userResult.send(self.user!)
            }).store(in: &disposables)
    }
    
    func updateGender(genderId: Int = -1) {
        userFetcher.PutUser(token: token, password: nil, name: nil, nickname: nil, gender: genderId == -1 ? nil : genderId, identity: nil, isGraduated: nil, studentNumber: nil, phoneNumber: nil)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { value in
                print(value)
                switch value {
                    case .failure(let error):
                        self.error = error
                        self.errorResult.send(error)
                        break
                    case .finished:
                        break
                }
            }, receiveValue: { user in
                self.user?.user = user
                self.genderResult.send(self.user!)
            }).store(in: &disposables)
    }
    
    //receive에 따라 로그아웃
    func deleteUser() {
        userFetcher.DeleteUser(token: token)
            .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: { value in
            print(value)
            switch value {
                case .failure(let error):
                    self.error = error
                    self.errorResult.send(error)
                    self.deleteResult.send(false)
                    break
                case .finished:
                    break
            }
        }, receiveValue: { result in
            print(result)
            self.deleteResult.send(true)
        }).store(in: &disposables)
    }
}
