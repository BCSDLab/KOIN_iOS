//
// Created by 정태훈 on 2020/01/12.
// Copyright (c) 2020 정태훈. All rights reserved.
//

import Foundation
import SwiftUI
import PKHUD

extension Binding {
    func onChange(_ handler: @escaping (Value) -> Void) -> Binding<Value> {
        return Binding(
            get: { self.wrappedValue },
            set: { selection in
                self.wrappedValue = selection
                handler(selection)
        })
    }
}

extension String {
    public func toPhoneNumber() -> String {
        return self.replacingOccurrences(of: "(\\d{3})(\\d{4})(\\d{3})", with: "$1-$2-$3", options: .regularExpression, range: nil)
    }
}
/*
struct MyInfoView: View {
    // 유저 정보가 들어있는 오브젝트
    @EnvironmentObject var settings: UserSettings
    // 회원 탈퇴 전 Alert표시를 위한 값(true일시 Alert 표시)
    @State var showingDeleteAlert: Bool = false
    //@State var showingAlert: Bool = false
    
    @State var updated_gender: Int = -1
    @State var change_name: String = ""
    @State var change_nickname: String = ""
    @State var change_phoneNumber: String = ""
    @State var change_studentNumber: String = ""
    
    @State var showNicknameModal: Bool = false
    @State var showPhoneModal: Bool = false
    @State var showNameModal: Bool = false
    @State var showStudentNumberModal: Bool = false
    
    @State var errorText = ""
    
    /*
     public final static String FILTERPASSWORD = "^(?=.[a-zA-Z])(?=.[`₩~!@#$%<>^&*()\-=+?<>:;"',.{}|[]/\\]])(?=.*[0-9]).{6,18}$";
     public final static String FILTER_EMAIL = "^[a-z_0-9]{1,12}$";
     */
    
    var listData: [[[String]]] = []
    
    init() {
        listData = loadUserInfo()
        // 네비게이션 바 색 설정
        UINavigationBar.appearance().barTintColor = UIColor(named: "light_navy")
        // 네비게이션 바 글자색 설정(흰색)
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
        
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(named: "light_navy")
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor(named: "light_navy")], for: .normal)
        UISegmentedControl.appearance().backgroundColor = UIColor.white
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
    }
    
    func genderChange(_ tag: Int) {
        self.settings.update_gender(token: self.settings.get_token(), updated_gender: tag) { (result, error)  in
            if result {
                print("success")
            } else {
                print(error.debugDescription)
            }
        }
    }
    

    // 유저 정보를 불러와서 리스트에 맞는 데이터로 반환
    func loadUserInfo() -> [[[String]]] {
        // 빈 배열을 생성(해당 배열에 데이터 삽입)
        var listData: [[[String]]] = []
        //UserDefaults에 유저 정보를 불러와서
        if let data = UserDefaults.standard.object(forKey:"user") as? Data {
            // JSON 디코더를 불러온 다음
            let decoder = JSONDecoder()
            // UserRequest에 맞게 데이터를 가공한 다음
            if let loaded = try? decoder.decode(UserData.self, from: data) {
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
                        gender = infoGender == 0 ? "0":"1"
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
        
        return List{
            // 데이터가 비어있지 않을때만 표시
            if !listData.isEmpty {
                Section(header: Text("기본정보")) {
                    HStack {
                        Text(listData[0][0][0])
                                .font(.system(size: 15))
                                .foregroundColor(Color("warm_grey_two"))
                        .frame(width: 75, alignment: .leading)
                        .padding(.trailing)
                        Text(listData[0][0][1])
                            .foregroundColor(Color("black"))
                            .font(.system(size: 15))
                            .fontWeight(.light)
                    }
                    HStack {
                        Text(listData[0][1][0])
                                .font(.system(size: 15))
                                .foregroundColor(Color("warm_grey_two"))
                        .frame(width: 75, alignment: .leading)
                        .padding(.trailing)
                        Text(listData[0][1][1])
                        .foregroundColor(Color("black"))
                        .font(.system(size: 15))
                        .fontWeight(.light)
                        Spacer()
                        if(listData[0][1][1] == "이름 없음") {
                            Button(action:{self.showNameModal.toggle()}) {
                                Text("추가").foregroundColor(Color("light_navy"))
                            }
                        }
                        
                    }.sheet(isPresented: $showNameModal) {
                        return NavigationView {
                            VStack(alignment: .leading) {
                                Text("이름").foregroundColor(Color("warm_grey_two"))
                                TextField("이름", text: self.$change_name).textFieldStyle(DefaultTextFieldStyle()).padding(.vertical)
                                Text(self.errorText)
                                .foregroundColor(.red)
                                Spacer()
                                }.padding().navigationBarItems(
                                leading:
                                Button(action: {
                                    self.showNameModal = false
                                }) {
                                    Text("닫기").foregroundColor(Color("light_navy"))
                            }, trailing:
                                Button(action: {
                                    
                                    self.settings.update_name(token: self.settings.get_token(), updated_name: self.change_name) { (result, error) in
                                        if result {
                                            self.errorText = ""
                                            self.showNameModal = false
                                        } else {
                                            self.errorText = (error?.localizedDescription)!
                                        }
                                    }
                                    
                                }) {
                                    Text("수정").foregroundColor(Color("light_navy"))
                            })
                            

                        }
                    }
                    HStack {
                        Text(listData[0][2][0])
                                .font(.system(size: 15))
                                .foregroundColor(Color("warm_grey_two"))
                        .frame(width: 75, alignment: .leading)
                        .padding(.trailing)
                        Text(listData[0][2][1])
                        .foregroundColor(Color("black"))
                        .font(.system(size: 15))
                        .fontWeight(.light)
                        Spacer()
                        if(listData[0][2][1] == "닉네임 없음") {
                            Button(action:{self.showNicknameModal.toggle()}) {
                                Text("추가").foregroundColor(Color("light_navy"))
                            }
                        } else {
                            
                            Button(action: {self.showNicknameModal.toggle()}) {
                                Text("수정").foregroundColor(Color("light_navy"))
                            }
                        }
                        
                    }.sheet(isPresented: $showNicknameModal) {
                        // 닉네임 10글자 제한
                        return NavigationView {
                            VStack(alignment: .leading) {
                                //Text("닉네임").foregroundColor(Color("warm_grey_two"))
                                TextField("닉네임", text: self.$change_nickname).textFieldStyle(DefaultTextFieldStyle()).padding(.vertical)
                                Text(self.errorText)
                                .foregroundColor(.red)
                                Spacer()
                                }
                            .padding()
                            .navigationBarItems(
                                leading:
                                Button(action: {
                                    self.showNicknameModal = false
                                }) {
                                    Text("닫기").foregroundColor(Color("light_navy"))
                            }, trailing:
                                Button(action: {
                                    self.settings.update_nickname(token: self.settings.get_token(), updated_nickname: self.change_nickname) { (result, error) in
                                        if result {
                                            self.errorText = ""
                                            self.showNicknameModal = false
                                        } else {
                                            self.errorText = (error?.localizedDescription)!
                                        }
                                    }
                                }) {
                                    Text("수정").foregroundColor(Color("light_navy"))
                                })
                            
                            
                            

                        }
                    }
                    HStack {
                        Text(listData[0][3][0])
                                .font(.system(size: 15))
                                .foregroundColor(Color("warm_grey_two"))
                                .frame(width: 75, alignment: .leading)
                        .padding(.trailing)
                        Text(listData[0][3][1])
                                .foregroundColor(Color("black"))
                                .font(.system(size: 15))
                                .fontWeight(.light)
                    }
                    HStack {
                        Text(listData[0][4][0])
                                .font(.system(size: 15))
                                .foregroundColor(Color("warm_grey_two"))
                                .frame(width: 75, alignment: .leading)
                        .padding(.trailing)
                        Text(listData[0][4][1])
                        .foregroundColor(Color("black"))
                        .font(.system(size: 15))
                        .fontWeight(.light)
                        Spacer()
                        if(listData[0][4][1] == "휴대폰 번호 없음") {
                            Button(action:{self.showPhoneModal = true}) {
                                Text("추가").foregroundColor(Color("light_navy"))
                            }
                        } else {
                            Button(action: {
                                self.showPhoneModal = true
                            }) {
                                Text("수정").foregroundColor(Color("light_navy"))
                            }
                        }
                        
                    }.sheet(isPresented: $showPhoneModal) {
                        NavigationView {
                            VStack(alignment: .leading) {
                                //Text("폰번호").foregroundColor(Color("warm_grey_two"))
                                TextField("폰번호", text: self.$change_phoneNumber).textFieldStyle(DefaultTextFieldStyle()).padding(.vertical)
                                Text("- 기호를 포함한 형태(010-0000-0000)로 입력해주세요.")
                                .font(.system(size: 10))
                                .foregroundColor(Color("light_navy"))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text(self.errorText)
                                    .foregroundColor(.red)
                                Spacer()
                                }.padding().navigationBarItems(
                                leading:
                                Button(action: {
                                    self.showPhoneModal = false
                                }) {
                                    Text("닫기").foregroundColor(Color("light_navy"))
                            }, trailing:
                                Button(action: {
                                    self.settings.update_phoneNumber(token: self.settings.get_token(), updated_phoneNumber: self.change_phoneNumber) { (result, error) in
                                        if result {
                                            self.errorText = ""
                                            self.showPhoneModal = false
                                        } else {
                                            self.errorText = (error?.localizedDescription)!
                                        }
                                    }
                                }) {
                                    Text("수정").foregroundColor(Color("light_navy"))
                            })
                            

                        }
                    }
                    HStack {
                        Text(listData[0][5][0])
                            .font(.system(size: 15))
                        .foregroundColor(Color("warm_grey_two"))
                        .frame(width: 75, alignment: .leading)
                            .padding(.trailing)
                        Picker(selection: $updated_gender.onChange(genderChange), label: Text("성별")) {
                            Text("남자").tag(0)
                            Text("여자").tag(1)
                            }
                            .pickerStyle(SegmentedPickerStyle())
                    
                        
                            
                    }
                
                }

                Section(header: Text("학교정보")) {
                    //ForEach(listData[1], id: \.self) { school in
                        HStack() {
                            Text(listData[1][0][0])
                                    .font(.system(size: 15))
                                    .foregroundColor(Color("warm_grey_two"))
                                .frame(width: 75, alignment: .leading)
                            .padding(.trailing)
                            Text(listData[1][0][1])
                            .foregroundColor(Color("black"))
                            .font(.system(size: 15))
                            .fontWeight(.light)
                            Spacer()
                            if(listData[1][0][1] == "학번 없음") {
                                Button(action:{self.showStudentNumberModal.toggle()}) {
                                    Text("추가").foregroundColor(Color("light_navy"))
                                }
                            } else {
                                
                            }
                        }.sheet(isPresented: $showStudentNumberModal) {
                            NavigationView() {
                                VStack(alignment: .leading) {
                                    //Text("학번").foregroundColor(Color("warm_grey_two"))
                                    TextField("학번", text: self.$change_studentNumber).textFieldStyle(DefaultTextFieldStyle()).padding(.vertical).keyboardType(.numberPad)
                                    Text(self.errorText)
                                    .foregroundColor(.red)
                                    Spacer()
                                    }.padding().navigationBarItems(
                                    leading:
                                    Button(action: {
                                        self.showStudentNumberModal = false
                                    }) {
                                        Text("닫기").foregroundColor(Color("light_navy"))
                                }, trailing:
                                    Button(action: {
                                        self.settings.update_studentNumber(token: self.settings.get_token(), updated_studentNumber: self.change_studentNumber){ (result, error) in
                                            if result {
                                                self.errorText = ""
                                                self.showStudentNumberModal = false
                                            } else {
                                                self.errorText = (error?.localizedDescription)!
                                            }
                                        }
                                    }) {
                                        Text("수정").foregroundColor(Color("light_navy"))
                                })
                                
                                

                            }
                        }
                    HStack {
                        Text(listData[1][1][0])
                                .font(.system(size: 15))
                                .foregroundColor(Color("warm_grey_two"))
                        .frame(width: 75, alignment: .leading)
                        .padding(.trailing)
                        Text(listData[1][1][1])
                                .foregroundColor(Color("black"))
                                .font(.system(size: 15))
                                .fontWeight(.light)
                    }
                    //}
                    HStack {
                        Spacer()
                        Text("* 전과 등의 이유로 학번과 학부 정보가 불일치하는 경우\nbcsdlab@gmail.com으로 문의바랍니다.")
                            .font(.system(size: 11))
                        .foregroundColor(Color("warm_grey_two"))
                            .multilineTextAlignment(.center)
                        Spacer()
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
                        self.settings.delete_session(token: self.settings.get_token()) { (_, _) in
                            
                        }
                    }, secondaryButton: .default(Text("취소")) {
                        // Alert를 닫는다.(아무 일도 일어나지 않는다.)
                        self.showingDeleteAlert = false
                        }
                        )
        }.onAppear() {
            if !self.listData[0][5][1].isEmpty {
                if let gender = Int(self.listData[0][5][1]) {
                    self.updated_gender = gender
                }
                
            }
        }


    }
}*/
