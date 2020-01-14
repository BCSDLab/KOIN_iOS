//
// Created by 정태훈 on 2020/01/12.
// Copyright (c) 2020 정태훈. All rights reserved.
//

import Foundation
import PKHUD
import SwiftUI

struct EditUserView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var settings: UserSettings
    @State var updated_password: String = ""
    @State var updated_name: String = ""
    @State var updated_nickname: String = ""
    @State var updated_gender: Int = -1
    @State var updated_studentNumber: String = ""
    @State var updated_phoneNumber: String = ""
    var username: String = ""
    var anonymous_nickname: String = ""
    

    @State var text = ""

    var disableName: Bool = false
    var disableGender: Bool = false
    var disablePhoneNumber: Bool = false
    var disableStudentNumber: Bool = false

    init() {
        if let data = UserDefaults.standard.object(forKey:"user") as? Data {
            let decoder = JSONDecoder()
            if let loaded = try? decoder.decode(UserRequest.self, from: data) {
                if let userInfo = loaded.user {
                    username = userInfo.portalAccount
                    anonymous_nickname = userInfo.anonymousNickname

                    if let infoName = userInfo.name {
                        if !infoName.isEmpty {
                            _updated_name = State(initialValue: infoName)
                            self.disableName = true
                        }}
                    if let infoNickname = userInfo.nickname {
                        if !infoNickname.isEmpty {
                            _updated_nickname = State(initialValue: infoNickname)
                        }}
                    if let infoPhoneNumber = userInfo.phoneNumber {
                        if !infoPhoneNumber.isEmpty {
                            _updated_phoneNumber = State(initialValue: infoPhoneNumber)
                            self.disablePhoneNumber = true
                        }}
                    if let infoGender = userInfo.gender {
                        if infoGender != -1 {
                            _updated_gender = State(initialValue: infoGender)
                            self.disableGender = true
                        }}
                    if let infoStudentNumber = userInfo.studentNumber {
                        if !infoStudentNumber.isEmpty {
                            _updated_studentNumber = State(initialValue: infoStudentNumber)
                            self.disableStudentNumber = true
                        } }


                }
            }
        }

    }


    func putUserData() {
        var changedNickname: Bool = false
        var token: String = ""
        if let data = UserDefaults.standard.object(forKey:"user") as? Data {
            let decoder = JSONDecoder()
            if let loaded = try? decoder.decode(UserRequest.self, from: data) {
                if let token_data = loaded.token {
                    token = token_data
                }
                if let userInfo = loaded.user {
                    if userInfo.nickname != updated_nickname {
                        changedNickname = true
                    }

                }
            }
        }

        self.settings.update_session(token: token, updated_password: updated_password, updated_name: updated_name, updated_nickname: updated_nickname, updated_gender: updated_gender, updated_isGraduated: false, updated_studentNumber: updated_studentNumber, updated_phoneNumber: updated_phoneNumber, changed_name: !self.disableName, changed_gender: !self.disableGender, changed_phoneNumber: !self.disablePhoneNumber, changed_studentNumber: !self.disableStudentNumber, changed_nickname: changedNickname) { result in
            if result {
                self.presentationMode.wrappedValue.dismiss()
            }
        }
    }

    func check_nickname() {
        let uiview = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 100))
        let yourLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
        yourLabel.center = CGPoint(x: uiview.frame.size.width  / 2,
                y: uiview.frame.size.height / 2)
        yourLabel.textAlignment = .center

        self.settings.check_nickname(nickname: updated_nickname) { result in
            if result {
                self.text = "겹치지 않아요."
                yourLabel.text = self.text
                uiview.addSubview(yourLabel)
                PKHUD.sharedHUD.contentView = uiview
                PKHUD.sharedHUD.show()
                PKHUD.sharedHUD.hide(afterDelay: 1.0)
            } else {
                self.text = "겹쳐요."
                yourLabel.text = self.text
                uiview.addSubview(yourLabel)
                PKHUD.sharedHUD.contentView = uiview
                PKHUD.sharedHUD.show()
                PKHUD.sharedHUD.hide(afterDelay: 1.0)
            }
        }
    }
    
    var body: some View {
        let someNumberProxy = Binding<String>(
                get: { String(format: "%d", Int(self.updated_gender)) },
                set: {
                    if let value = NumberFormatter().number(from: $0) {
                        self.updated_gender = value.intValue
                    }
                }
        )
        
        return List{
            Section(header: Text("기본정보")) {
                HStack {
                    Text("아이디")
                    Text("\(username)@koreatech.ac.kr")
                }
                HStack {
                    Text("이름")
                    TextField("이름", text: $updated_name)
                    .disabled(disableName)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
                    .font(.subheadline)
                }
                HStack {
                    Text("닉네임")
                    TextField("닉네임", text: $updated_nickname)
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
                            .font(.subheadline)
                    Button(action: check_nickname) {
                        Text("닉네임 중복")
                    }
                }
                HStack {
                    Text("익명닉네임")
                    Text("\(anonymous_nickname)")
                }
                HStack {
                    Text("휴대전화")
                    TextField("핸드폰 번호", text: $updated_phoneNumber)
                        .disabled(disablePhoneNumber)
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
                        .font(.subheadline)
                }
                HStack {
                    Text("성별")
                    Picker(selection: $updated_gender, label: Text("성별")) {
                        Text("남자").tag(0)
                        Text("여자").tag(1)
                    }.pickerStyle(SegmentedPickerStyle())
                    .disabled(disableGender)
                }
            }

            Section(header: Text("학교정보")) {
                HStack {
                    Text("학번")
                    TextField("학번", text: $updated_studentNumber)
                    .disabled(disableStudentNumber)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
                    .font(.subheadline)
                }
            }
            
            Section(header: Text("비밀번호 변경")) {
                HStack {
                    Text("변경할 비밀번호")
                    SecureField("비밀번호", text: $updated_password)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
                    .font(.subheadline)
                }
            }
            
            Button(action: putUserData){
                Text("보내기")
            }

        }
        
    }
}

struct EditUserView_Previews: PreviewProvider {
    static var previews: some View {
        EditUserView()
    }
}
