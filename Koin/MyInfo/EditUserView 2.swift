//
// Created by 정태훈 on 2020/01/12.
// Copyright (c) 2020 정태훈. All rights reserved.
//
/*
import Foundation
import PKHUD
import SwiftUI

struct EditUserView: View {
    // navigation뷰에서 뒤로 갈 때 필요한 오브젝트
    @Environment(\.presentationMode) var presentationMode
    // 유저 정보를 갖고 있는 오브젝트
    @EnvironmentObject var settings: UserSettings
    // 패스워드 변수(수정 가능)
    @State var updated_password: String = ""
    // 이름 변수(수정 가능)
    @State var updated_name: String = ""
    // 닉네임 변수(수정 가능)
    @State var updated_nickname: String = ""
    // 성병 변수(수정 가능)
    @State var updated_gender: Int = -1
    // 학번 변수(수정 가능)
    @State var updated_studentNumber: String = ""
    // 폰 번호 변수(수정 가능)
    @State var updated_phoneNumber: String = ""
    // 포털 아이디 변수(수정 불가능)
    var username: String = ""
    // 익명 닉네임 변수(수정 불가능)
    var anonymous_nickname: String = ""
    
    // HUD 창으로 에러 등을 알려줄 때 사용하는 String 변수
    @State var text = ""

    init() {
        // UserDefaults를 통해 유저 정보 가져오기
        if let data = UserDefaults.standard.object(forKey:"user") as? Data {
            // JSON 디코더를 불러와
            let decoder = JSONDecoder()
            // UserRequest 형태로 데이터를 가공
            if let loaded = try? decoder.decode(UserRequest.self, from: data) {
                // 유저 정보가 nil이 아니라면
                if let userInfo = loaded.user {
                    // 포탈 아이디 저장
                    username = userInfo.portalAccount
                    // 익명 닉네임 저장
                    anonymous_nickname = userInfo.anonymousNickname

                    // 이름이 nil이 아니라면
                    if let infoName = userInfo.name {
                        // 이름 저장후, 이름 필드에 표시
                            _updated_name = State(initialValue: infoName)
                }
                    // 닉네임이 nil이 아니라면
                    if let infoNickname = userInfo.nickname {
                        // 닉네임 저장 후, 닉네임 필드에 표시
                            _updated_nickname = State(initialValue: infoNickname)
                    }
                    // 폰 넘버가 nil이 아니라면
                    if let infoPhoneNumber = userInfo.phoneNumber {
                        // 폰 넘버 저장 후, 폰넘버 필드에 표시
                            _updated_phoneNumber = State(initialValue: infoPhoneNumber)
                    }
                    // 성별이 -1이 아니라면
                    if let infoGender = userInfo.gender {
                        //성별 저장 후, 성별 필드에 표시
                            _updated_gender = State(initialValue: infoGender)
                    }
                    // 학번이 nil이 아니라면
                    if let infoStudentNumber = userInfo.studentNumber {
                        // 학번 저장 후, 학번 필드에 표시
                            _updated_studentNumber = State(initialValue: infoStudentNumber)
                    }


                }
            }
        }

    }
    
    

    // 업데이트할 정보를 넘겨주는 함수
    func putUserData() {
        // 닉네임 변경 여부 체크하는 변수
        var changedNickname: Bool = false
        // 이름 변경 여부 체크하는 변수
        var changeName: Bool = false
        // 성별 변경 여부 체크하는 변수
        var changeGender: Bool = false
        // 폰 번호 변경 여부 체크하는 변수
        var changePhoneNumber: Bool = false
        // 학번 변경 여부 체크하는 변수
        var changeStudentNumber: Bool = false
        // 토큰값 저장하는 변수
        var token: String = ""
        
        // UserDefaults에서 유저 정보를 불러와서
        if let data = UserDefaults.standard.object(forKey:"user") as? Data {
            // JSON디코더를 불러온 다음
            let decoder = JSONDecoder()
            // 유저 정보를 UserRequest의 형태로 변환한 다음
            if let loaded = try? decoder.decode(UserRequest.self, from: data) {
                // 토큰 값이 nil이 아니면
                if let token_data = loaded.token {
                    // 토큰값 저장하기
                    token = token_data
                }
                // 유저 정보가 nil이 아니면
                if let userInfo = loaded.user {
                    // 유저 정보의 닉네임과 업데이트된 닉네임이 다르면
                    if userInfo.nickname != updated_nickname {
                        // 닉네임이 변경된 걸로 설정
                        changedNickname = true
                    }
                    // 유저 정보의 이름과 업데이트된 이름이 다르면
                    if userInfo.name != updated_name {
                        // 이름이 변경된 걸로 설정
                        changeName = true
                    }
                    // 유저 정보의 성별과 업데이트된 성별이 다르면
                    if userInfo.gender != updated_gender {
                        // 성별이 변경된 걸로 설정
                        changeGender = true
                    }
                    // 유저 정보의 폰 번호와 업데이트된 폰 번호가 다르면
                    if userInfo.phoneNumber != updated_phoneNumber {
                        // 폰 번호가 변경된 걸로 설정
                        changePhoneNumber = true
                    }
                    // 유저 정보의 학번과 업데이트된 학번이 다르면
                    if userInfo.studentNumber != updated_studentNumber {
                        // 학번이 변경된 걸로 설정
                        changeStudentNumber = true
                    }

                }
            }
        }
        // 유저 세팅 내부의 update sesseion 함수에 정보를 모두 보내준다.
        self.settings.update_session(token: token, updated_password: updated_password, updated_name: updated_name, updated_nickname: updated_nickname, updated_gender: updated_gender, updated_isGraduated: false, updated_studentNumber: updated_studentNumber, updated_phoneNumber: updated_phoneNumber, changed_name: changeName, changed_gender: changeGender, changed_phoneNumber: changePhoneNumber, changed_studentNumber: changeStudentNumber, changed_nickname: changedNickname) { result in
            // 결과가 좋으면
            if result {
                // 뒤로 간다.
                self.presentationMode.wrappedValue.dismiss()
            }
        }
    }


    // 닉네임이 겹치는지 확인해주는 함수
    func check_nickname() {
        // HUD로 보여주기 위한 뷰 오브젝트
        let uiview = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 100))
        // HUD 내부의 글자 뷰 오브젝트
        let yourLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
        yourLabel.center = CGPoint(x: uiview.frame.size.width  / 2,
                y: uiview.frame.size.height / 2)
        yourLabel.textAlignment = .center

        // 유저 세팅 내부의 check_nickname 함수에 업데이트할 닉네임 정보를 보내서
        self.settings.check_nickname(nickname: updated_nickname) { result in
            // 문제가 없으면
            if result {
                // 겹치지 않는다고 HUD로 표시해준다.
                self.text = "겹치지 않아요."
                yourLabel.text = self.text
                uiview.addSubview(yourLabel)
                PKHUD.sharedHUD.contentView = uiview
                PKHUD.sharedHUD.show()
                PKHUD.sharedHUD.hide(afterDelay: 1.0)
            } else { // 문제가 있으면
                // 겹친다고 HUD로 표시해준다.
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
        //
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
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
                        .font(.subheadline)
                }
                HStack {
                    Text("성별")
                    Picker(selection: $updated_gender, label: Text("성별")) {
                        Text("남자").tag(0)
                        Text("여자").tag(1)
                    }.pickerStyle(SegmentedPickerStyle())
                }
            }

            Section(header: Text("학교정보")) {
                HStack {
                    Text("학번")
                    TextField("학번", text: $updated_studentNumber)
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
*/
