//
// Created by 정태훈 on 2020/01/12.
// Copyright (c) 2020 정태훈. All rights reserved.
//

import Foundation
import SwiftUI
import PKHUD




struct MyInfoView: View {
    // 유저 정보가 들어있는 오브젝트
    @EnvironmentObject var settings: UserSettings
    // 회원 탈퇴 전 Alert표시를 위한 값(true일시 Alert 표시)
    @State var showingDeleteAlert: Bool = false

    // 유저 정보를 불러와서 리스트에 맞는 데이터로 반환
    func loadUserInfo() -> [[[String]]] {
        // 빈 배열을 생성(해당 배열에 데이터 삽입)
        var listData: [[[String]]] = []
        //UserDefaults에 유저 정보를 불러와서
        if let data = UserDefaults.standard.object(forKey:"user") as? Data {
            // JSON 디코더를 불러온 다음
            let decoder = JSONDecoder()
            // UserRequest에 맞게 데이터를 가공한 다음
            if let loaded = try? decoder.decode(UserRequest.self, from: data) {
                // 유저 정보가 nil이 아니면
                if let userInfo = loaded.user {
                    // 정보가 nil일때의 기본 출력 생성
                    var name: String = "이름 없음"
                    var nickname: String = "닉네임 없음"
                    var phoneNumber: String = "휴대폰 번호 없음"
                    var gender: String = "성별 없음"
                    var studentNumber: String = "학번 없음"
                    var major: String = "전공 없음"

                    // 이름이 nil이 아니면, 해당 값을 name에 저장
                    if let infoName = userInfo.name { name = infoName }
                    // 닉네임이 nil이 아니면, 해당 값을 nickname에 저장
                    if let infoNickname = userInfo.nickname {nickname = infoNickname}
                    // 폰 번호가 nil이 아니면, 해당 값을 phoneNumber에 저장
                    if let infoPhoneNumber = userInfo.phoneNumber {phoneNumber = infoPhoneNumber}
                    // 성별이 -1이 아니면, 0일 경우에는 "남자"로, 아닐때는(1) "여자"로 저장
                    if let infoGender = userInfo.gender {
                        gender = infoGender == 0 ? "남자":"여자"
                    }
                    // 학번이 nil이 아니면, 해당 값을 studentNumber에 저장
                    if let infoStudentNumber = userInfo.studentNumber {studentNumber = infoStudentNumber}
                    // 전공이 nil이 아니면, 해당 값을 major에 저장
                    if let infoMajor = userInfo.major {major = infoMajor}

                    // 리스트 데이터를 정리해서 넣기
                    listData = [[["아이디", userInfo.portalAccount], ["이름", name], ["닉네임", nickname], ["익명닉네임", userInfo.anonymousNickname], ["휴대전화", phoneNumber], ["성별", gender]], [["학번",studentNumber], ["전공",major]]]


                }
            }
        }
        return listData
    }

    var body: some View {
        // 유저 정보 데이터 불러오기
        var listData = loadUserInfo()

        return List{
            // 데이터가 비어있지 않을때만 표시
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
                //회원탈퇴 글자를 누르면 Delete Alert가 열린다.
                Text("회원탈퇴").onTapGesture {
                    self.showingDeleteAlert = true
                }
                Spacer()
                Divider()
                Spacer()
                //로그아웃 글자를 누르면, setting의 로그아웃 기능이 수행된다.
                Text("로그아웃").onTapGesture {
                    self.settings.logout_session()
                }
                Spacer()
            }

        }
                .listStyle(GroupedListStyle())
                .alert(isPresented: $showingDeleteAlert) {
                    Alert(title: Text("탈퇴하시겠습니까?"), message: Text("모든 정보가 사라집니다."), primaryButton: .destructive(Text("탈퇴하기")) {
                        // Alert를 닫고
                        self.showingDeleteAlert = false
                        // setting 내의 회원 탈퇴 기능에 토큰을 보내 기능을 수행한다.
                        self.settings.delete_session(token: self.settings.get_token())
                    }, secondaryButton: .default(Text("취소")) {
                        // Alert를 닫는다.(아무 일도 일어나지 않는다.)
                        self.showingDeleteAlert = false}
                    )
                }


    }
}
