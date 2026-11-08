//
//  UserDataManager.swift
//  koin
//
//  Created by 김나훈 on 3/6/25.
//

import FirebaseAnalytics

final class UserDataManager {
    static let shared = UserDataManager()
    private(set) var isLoggedIn: Bool = false
    private(set) var userId: String = ""
    private(set) var id: Int = 0
    private(set) var gender: Any = ""
    private(set) var major: String = ""
    private(set) var nickname: String = ""
    // TODO: 사용자 정보 요청이 실패하거나 끝나기 전이면 로그인 사용자도 isLoggedIn == false로 보인다.
    // TODO: 앱 시작 시 이 값을 채우는 곳은 HomeViewModel.checkForceModifyUser() 하나인데, forceModal == true면 바로 return한다.
    //       그래서 한 번 강제 수정 대상이었던 학생은 재실행 후 로그인·프로필 수정 전까지 비로그인으로 보인다.
    private(set) var userType: UserType?
    var isStudent: Bool { isLoggedIn && userType == .student }
    
    private init() {}
    
    func setUserData(userData: UserDto) {
        isLoggedIn = true
        userType = UserType(rawValue: userData.userType ?? "")
        
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
        isLoggedIn = false
        userId = ""
        id = 0
        gender = ""
        major = ""
        nickname = ""
        userType = nil
        Analytics.setUserID(nil)
    }
    
}
