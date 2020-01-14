//
// Created by 정태훈 on 2020/01/12.
// Copyright (c) 2020 정태훈. All rights reserved.
//

import Foundation
import SwiftUI
import PKHUD




struct MyInfoView: View {
    @EnvironmentObject var settings: UserSettings
    @State var showingDeleteAlert: Bool = false

    func loadUserInfo() -> [[[String]]] {
        var listData: [[[String]]] = []
        if let data = UserDefaults.standard.object(forKey:"user") as? Data {
            let decoder = JSONDecoder()
            if let loaded = try? decoder.decode(UserRequest.self, from: data) {
                if let userInfo = loaded.user {
                    var name: String = "이름 없음"
                    var nickname: String = "닉네임 없음"
                    var phoneNumber: String = "휴대폰 번호 없음"
                    var gender: String = "성별 없음"
                    var studentNumber: String = "학번 없음"
                    var major: String = "전공 없음"

                    if let infoName = userInfo.name { name = infoName }
                    if let infoNickname = userInfo.nickname {nickname = infoNickname}
                    if let infoPhoneNumber = userInfo.phoneNumber {phoneNumber = infoPhoneNumber}
                    if let infoGender = userInfo.gender {
                        gender = infoGender == 0 ? "남자":"여자"
                    }
                    if let infoStudentNumber = userInfo.studentNumber {studentNumber = infoStudentNumber}
                    if let infoMajor = userInfo.major {major = infoMajor}

                    listData = [[["아이디", userInfo.portalAccount], ["이름", name], ["닉네임", nickname], ["익명닉네임", userInfo.anonymousNickname], ["휴대전화", phoneNumber], ["성별", gender]], [["학번",studentNumber], ["전공",major]]]


                }
            }
        }
        return listData
    }

    var body: some View {
        var listData = loadUserInfo()

        return List{
            if !listData.isEmpty {
                Section(header: Text("기본정보")) {
                    ForEach(listData[0], id:\.self) { general in
                        HStack {
                            Text(general[0])
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            Spacer()
                            Text(general[1])
                                    .font(.subheadline)
                                    .fontWeight(.light)
                        }
                    }
                }

                Section(header: Text("학교정보")) {
                    ForEach(listData[1], id: \.self) { school in
                        HStack {
                            Text(school[0])
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            Spacer()
                            Text(school[1])
                                    .font(.subheadline)
                                    .fontWeight(.light)
                        }
                    }
                }

            }



            HStack {

                Spacer()
                Text("회원탈퇴").onTapGesture {
                    self.showingDeleteAlert = true
                }
                Spacer()
                Divider()
                Spacer()
                Text("로그아웃").onTapGesture {
                    self.settings.logout_session()
                }
                Spacer()
            }

        }
                .listStyle(GroupedListStyle())
                .alert(isPresented: $showingDeleteAlert) {
                    Alert(title: Text("탈퇴하시겠습니까?"), message: Text("모든 정보가 사라집니다."), primaryButton: .destructive(Text("탈퇴하기")) {
                        self.showingDeleteAlert = false
                        self.settings.delete_session(token: self.settings.get_token())
                    }, secondaryButton: .default(Text("취소")) {self.showingDeleteAlert = false})
                }


    }
}