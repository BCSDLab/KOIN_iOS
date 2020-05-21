//
//  BetaMyInfoView.swift
//  Koin
//
//  Created by 정태훈 on 2020/05/16.
//  Copyright © 2020 정태훈. All rights reserved.
//

import SwiftUI

struct BetaMyInfoView: View {
    @EnvironmentObject var config: UserConfig
    @ObservedObject var viewModel: MyInfoViewModel
    @State var showingDeleteAlert: Bool = false
    
    
    //@State var showNicknameModal: Bool = false
    //@State var showPhoneModal: Bool = false
    //@State var showNameModal: Bool = false
    //@State var showStudentNumberModal: Bool = false
    
    
    /*
     public final static String FILTERPASSWORD = "^(?=.[a-zA-Z])(?=.[`₩~!@#$%<>^&*()\-=+?<>:;"',.{}|[]/\\]])(?=.*[0-9]).{6,18}$";
     public final static String FILTER_EMAIL = "^[a-z_0-9]{1,12}$";
     */
    var filterName = "^[ㄱ-ㅎㅏ-ㅣ가-힣a-zA-Z\\u318D\\u119E\\u11A2\\u2022\\u2025a\\u00B7\\uFE55]{1,5}$"
    
    var filterNickname = "^[ㄱ-ㅎㅏ-ㅣ가-힣a-zA-Z0-9\\u318D\\u119E\\u11A2\\u2022\\u2025a\\u00B7\\uFE55]{1,10}$"
    
    
    init(viewModel: MyInfoViewModel) {
        self.viewModel = viewModel
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
    
    
    
    var body: some View {
        return List{
            if (self.config.hasUser) {
                Section(header: Text("기본정보")) {
                    HStack {
                        Text("아이디")
                            .font(.system(size: 15))
                            .foregroundColor(Color("warm_grey_two"))
                            .frame(width: 75, alignment: .leading)
                            .padding(.trailing)
                        Text(self.viewModel.portalAccount)
                            .foregroundColor(Color("black"))
                            .font(.system(size: 15))
                            .fontWeight(.light)
                    }
                    HStack {
                        Text("이름")
                            .font(.system(size: 15))
                            .foregroundColor(Color("warm_grey_two"))
                            .frame(width: 75, alignment: .leading)
                            .padding(.trailing)
                        Text(self.viewModel.name)
                            .foregroundColor(Color("black"))
                            .font(.system(size: 15))
                            .fontWeight(.light)
                        Spacer()
                        if(self.viewModel.name.isEmpty) {
                            Button(action:{self.viewModel.showNameModal.toggle()}) {
                                Text("추가").foregroundColor(Color("light_navy"))
                            }
                        }
                    }.sheet(isPresented: self.$viewModel.showNameModal) {
                        return NavigationView {
                            VStack(alignment: .leading) {
                                Text("이름").foregroundColor(Color("warm_grey_two"))
                                TextField("이름", text: self.$viewModel.editName).textFieldStyle(DefaultTextFieldStyle()).padding(.vertical)
                                    .onReceive(self.viewModel.$editName) { name in
                                        if (checkRegex(target: name, pattern: self.filterName)) {
                                            self.viewModel.error = nil
                                            self.viewModel.errorResult.send(UserError.parsing(description: ""))
                                        } else {
                                            self.viewModel.error = UserError.parsing(description: "이름 형식에 맞지 않습니다.")
                                            self.viewModel.errorResult.send(UserError.parsing(description: "이름 형식에 맞지 않습니다."))
                                        }
                                        
                                }
                                Text(self.viewModel.errorText)
                                    .foregroundColor(.red)
                                Spacer()
                            }.padding().navigationBarItems(
                                leading: Button(action: {
                                    self.viewModel.showNameModal = false
                                }) {
                                    Text("닫기").foregroundColor(Color("light_navy"))
                                }, trailing:
                                Button(action: {
                                    self.viewModel.updateUser()
                                }) {
                                    Text("수정").foregroundColor(Color("light_navy"))
                                }.onReceive(self.viewModel.userResult) { user in
                                    if (user != nil) {
                                        self.config.updateUser(user: user)
                                        self.viewModel.showNameModal = false
                                    }
                            })
                        }
                    }
                    HStack {
                        Text("닉네임")
                            .font(.system(size: 15))
                            .foregroundColor(Color("warm_grey_two"))
                            .frame(width: 75, alignment: .leading)
                            .padding(.trailing)
                        Text(self.viewModel.nickname)
                            .foregroundColor(Color("black"))
                            .font(.system(size: 15))
                            .fontWeight(.light)
                        Spacer()
                        if(self.viewModel.nickname.isEmpty) {
                            Button(action:{self.viewModel.showNicknameModal.toggle()}) {
                                Text("추가").foregroundColor(Color("light_navy"))
                            }
                        } else {
                            Button(action: {self.viewModel.showNicknameModal.toggle()}) {
                                Text("수정").foregroundColor(Color("light_navy"))
                            }
                        }
                        
                    }.sheet(isPresented: self.$viewModel.showNicknameModal) {
                        // 닉네임 10글자 제한
                        return NavigationView {
                            VStack(alignment: .leading) {
                                TextField("닉네임", text: self.$viewModel.editNickname).textFieldStyle(DefaultTextFieldStyle()).padding(.vertical)
                                    .onReceive(self.viewModel.$editNickname) { nickname in
                                        if (checkRegex(target: nickname, pattern: self.filterNickname)) {
                                            self.viewModel.error = nil
                                            self.viewModel.errorResult.send(UserError.parsing(description: ""))
                                        } else {
                                            self.viewModel.error = UserError.parsing(description: "닉네임 형식에 맞지 않습니다.")
                                            self.viewModel.errorResult.send(UserError.parsing(description: "닉네임 형식에 맞지 않습니다."))
                                        }
                                        
                                }
                                Text(self.viewModel.errorText)
                                    .foregroundColor(.red)
                                Spacer()
                            }
                            .padding()
                            .navigationBarItems(
                                leading:
                                Button(action: {
                                    self.viewModel.showNicknameModal = false
                                }) {
                                    Text("닫기").foregroundColor(Color("light_navy"))
                                }, trailing:
                                Button(action: {
                                    self.viewModel.updateUser()
                                }) {
                                    Text("수정").foregroundColor(Color("light_navy"))
                                }.onReceive(self.viewModel.userResult) { user in
                                    if (user != nil) {
                                        self.config.updateUser(user: user)
                                        self.viewModel.showNicknameModal = false
                                    }
                            })
                            
                            
                            
                            
                        }
                    }
                    HStack {
                        Text("익명넥네임")
                            .font(.system(size: 15))
                            .foregroundColor(Color("warm_grey_two"))
                            .frame(width: 75, alignment: .leading)
                            .padding(.trailing)
                        Text(self.viewModel.anonymousNickname)
                            .foregroundColor(Color("black"))
                            .font(.system(size: 15))
                            .fontWeight(.light)
                    }
                    HStack {
                        Text("휴대전화")
                            .font(.system(size: 15))
                            .foregroundColor(Color("warm_grey_two"))
                            .frame(width: 75, alignment: .leading)
                            .padding(.trailing)
                        Text(self.viewModel.phoneNumber)
                            .foregroundColor(Color("black"))
                            .font(.system(size: 15))
                            .fontWeight(.light)
                        Spacer()
                        if(self.viewModel.phoneNumber.isEmpty) {
                            Button(action:{self.viewModel.showPhoneModal = true}) {
                                Text("추가").foregroundColor(Color("light_navy"))
                            }
                        } else {
                            Button(action: {
                                self.viewModel.showPhoneModal = true
                            }) {
                                Text("수정").foregroundColor(Color("light_navy"))
                            }
                        }
                        
                    }.sheet(isPresented: self.$viewModel.showPhoneModal) {
                        NavigationView {
                            VStack(alignment: .leading) {
                                //무조건 숫자로 하기
                                TextField("폰번호", text: self.$viewModel.editPhoneNumber).keyboardType(.numberPad).textFieldStyle(DefaultTextFieldStyle()).padding(.vertical)
                                .onReceive(self.viewModel.$editPhoneNumber) { phone in
                                    if (phone.count == 11 || phone.count == 0) {
                                        self.viewModel.error = nil
                                        self.viewModel.errorResult.send(UserError.parsing(description: ""))
                                    } else {
                                        self.viewModel.error = UserError.parsing(description: "휴대폰 번호 길이가 맞지 않습니다.")
                                        self.viewModel.errorResult.send(UserError.parsing(description: "휴대폰 번호 길이가 맞지 않습니다."))
                                    }
                                    
                                }
                                Text("숫자로만 입력해주세요.")
                                    .font(.system(size: 10))
                                    .foregroundColor(Color("light_navy"))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text(self.viewModel.errorText)
                                    .foregroundColor(.red)
                                Spacer()
                            }.padding().navigationBarItems(
                                leading:
                                Button(action: {
                                    self.viewModel.showPhoneModal = false
                                }) {
                                    Text("닫기").foregroundColor(Color("light_navy"))
                                }, trailing:
                                Button(action: {
                                    self.viewModel.updateUser()
                                }) {
                                    Text("수정").foregroundColor(Color("light_navy"))
                                }.onReceive(self.viewModel.userResult) { user in
                                    if (user != nil) {
                                        self.config.updateUser(user: user)
                                        self.viewModel.showPhoneModal = false
                                    }
                            })
                            
                            
                        }
                    }
                    HStack {
                        Text("성별")
                            .font(.system(size: 15))
                            .foregroundColor(Color("warm_grey_two"))
                            .frame(width: 75, alignment: .leading)
                            .padding(.trailing)
                        Picker(selection: self.$viewModel.gender, label: Text("성별")) {
                            Text("남자").tag(0)
                            Text("여자").tag(1)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        
                    }.onReceive(self.viewModel.$gender) { gender in
                        if (gender != self.viewModel.gender) {
                            print(gender)
                            self.viewModel.updateGender(genderId: gender)
                        }
                        
                    }.onReceive(self.viewModel.genderResult) { user in
                        if (user != nil) {
                            self.config.updateUser(user: user)
                        }
                    }
                    
                }
                
                Section(header: Text("학교정보")) {
                    //ForEach(listData[1], id: \.self) { school in
                    HStack() {
                        Text("학번")
                            .font(.system(size: 15))
                            .foregroundColor(Color("warm_grey_two"))
                            .frame(width: 75, alignment: .leading)
                            .padding(.trailing)
                        Text(self.viewModel.studentNumber)
                            .foregroundColor(Color("black"))
                            .font(.system(size: 15))
                            .fontWeight(.light)
                        Spacer()
                        if(self.viewModel.studentNumber.isEmpty) {
                            Button(action:{self.viewModel.showStudentNumberModal.toggle()}) {
                                Text("추가").foregroundColor(Color("light_navy"))
                            }
                        }
                    }.sheet(isPresented: self.$viewModel.showStudentNumberModal) {
                        NavigationView() {
                            VStack(alignment: .leading) {
                                TextField("학번", text: self.$viewModel.editStudentNumber).textFieldStyle(DefaultTextFieldStyle()).padding(.vertical).keyboardType(.numberPad)
                                    .onReceive(self.viewModel.$editStudentNumber) { student in
                                        if (student.count == 10 || student.count == 0) {
                                            self.viewModel.error = nil
                                            self.viewModel.errorResult.send(UserError.parsing(description: ""))
                                        } else {
                                            self.viewModel.error = UserError.parsing(description: "학번 길이가 맞지 않습니다.")
                                            self.viewModel.errorResult.send(UserError.parsing(description: "학번 길이가 맞지 않습니다."))
                                        }
                                        
                                }
                                Text(self.viewModel.errorText)
                                    .foregroundColor(.red)
                                Spacer()
                            }.padding().navigationBarItems(
                                leading:
                                Button(action: {
                                    self.viewModel.showStudentNumberModal = false
                                }) {
                                    Text("닫기").foregroundColor(Color("light_navy"))
                                }, trailing:
                                Button(action: {
                                    self.viewModel.updateUser()
                                }) {
                                    Text("수정").foregroundColor(Color("light_navy"))
                                }.onReceive(self.viewModel.userResult) { user in
                                    if (user != nil) {
                                        self.config.updateUser(user: user)
                                        self.viewModel.showStudentNumberModal = false
                                    }
                            })
                            
                            
                            
                        }
                    }
                    HStack {
                        Text("전공")
                            .font(.system(size: 15))
                            .foregroundColor(Color("warm_grey_two"))
                            .frame(width: 75, alignment: .leading)
                            .padding(.trailing)
                        Text(self.viewModel.major)
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
                
                if (self.config.hasUser) {
                    Spacer()
                    //회원탈퇴 글자를 누르면 Delete Alert가 열린다.
                    Text("회원탈퇴").onTapGesture {
                        self.showingDeleteAlert = true
                    }.onReceive(self.viewModel.deleteResult) { result in
                        if (result) {
                            self.config.logoutUser()
                        }
                    }
                    Spacer()
                    Divider()
                }
                Spacer()
                //로그아웃 글자를 누르면, setting의 로그아웃 기능이 수행된다.
                if(self.config.hasUser) {
                    Text("로그아웃").onTapGesture {
                        self.config.logoutUser()
                    }
                } else {
                    Text("나가기").onTapGesture {
                        self.config.logoutUser()
                    }
                }
                Spacer()
            }
        }
        .onReceive(self.viewModel.errorResult) { result in
            self.viewModel.showingErrorAlert.toggle()
        }
        .listStyle(GroupedListStyle())
        .alert(isPresented: $showingDeleteAlert) {
            Alert(title: Text("탈퇴하시겠습니까?"), message: Text("모든 정보가 사라집니다."), primaryButton: .destructive(Text("탈퇴하기")) {
                // Alert를 닫고
                self.showingDeleteAlert = false
                // setting 내의 회원 탈퇴 기능에 토큰을 보내 기능을 수행한다.
                self.viewModel.deleteUser()
                }, secondaryButton: .default(Text("취소")) {
                    // Alert를 닫는다.(아무 일도 일어나지 않는다.)
                    self.showingDeleteAlert = false
                }
            )
        }
        
        
    }
}
