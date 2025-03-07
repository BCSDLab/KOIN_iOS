//
//  UserDataManager.swift
//  koin
//
//  Created by 김나훈 on 3/6/25.
//


final class UserDataManager {
    static let shared = UserDataManager()
    private(set) var userId: String = ""
    private(set) var id: Int = 0
    private(set) var gender: Any = ""
    private(set) var major: String = ""
    private(set) var nickname: String = ""
    
    
    private init() {}
    
    func setUserData(userData: UserDTO) {
        if let studentNumber = userData.studentNumber, !studentNumber.isEmpty {
            userId = "\(studentNumber.prefix(6))_\(userData.id)"
        } else {
            userId = "anonymous_\(userData.id)"
        }
        if let genderValue = userData.gender {
            gender = (genderValue == 0) ? "0" : (genderValue == 1) ? "1" : ""
        } else {
            gender = ""
        }
        nickname = userData.nickname ?? userData.anonymousNickname ?? ""
        if let id = userData.id {
            self.id = id
        }
        major = userData.major ?? ""
    }
    func resetUserData() {
        userId = ""
        gender = ""
        major = ""
    }
    
}
