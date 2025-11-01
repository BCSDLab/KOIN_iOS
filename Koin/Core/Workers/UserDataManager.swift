//
//  UserDataManager.swift
//  koin
//
//  Created by 김나훈 on 3/6/25.
//

import FirebaseAnalytics

final class UserDataManager {
    static let shared = UserDataManager()
    private(set) var userId: String = ""
    private(set) var id: Int = 0
    private(set) var gender: Any = ""
    private(set) var major: String = ""
    private(set) var nickname: String = ""
    
    private init() {}
    
    func setUserData(userData: UserDTO) {
        guard let id = userData.id else {
            self.id = 0
            self.userId = "anonymous"
            self.gender = ""
            self.nickname = userData.nickname ?? userData.anonymousNickname ?? ""
            self.major = userData.major ?? ""
            Analytics.setUserID(self.userId)
            return
        }
        self.id = id

        if let studentNumberValue = userData.studentNumber, !studentNumberValue.isEmpty {
            userId = "\(String(studentNumberValue.prefix(6)))_\(id)"
        } else {
            userId = "anonymous_\(id)"
        }

        if let genderValue = userData.gender {
            gender = (genderValue == 0) ? "0" : (genderValue == 1) ? "1" : ""
        } else {
            gender = ""
        }
        nickname = userData.nickname ?? userData.anonymousNickname ?? ""
        major = userData.major ?? ""
        Analytics.setUserID(self.userId)
    }

    func resetUserData() {
        userId = ""
        id = 0
        gender = ""
        major = ""
        nickname = ""
        Analytics.setUserID(nil)
    }
    
}
