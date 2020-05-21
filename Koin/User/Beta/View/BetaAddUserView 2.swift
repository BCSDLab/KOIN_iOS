//
//  BetaAddUserView.swift
//  Koin
//
//  Created by 정태훈 on 2020/05/13.
//  Copyright © 2020 정태훈. All rights reserved.
//

import SwiftUI

struct TermsView: View {
    var terms: Bool = true
    
    @State var content: String = ""
    
    var body : some View {
        return ScrollView(.vertical) {
            Text(content)
                .padding()
        }.onAppear() {
            var path: String?
            if self.terms {
                path = Bundle.main.path(forResource: "Terms_personal_information", ofType: "txt")
            } else {
                path = Bundle.main.path(forResource: "Terms_koin_sign_up", ofType: "txt")
            }
            self.content = try! String(contentsOfFile: path!, encoding: String.Encoding.utf8)
        }
    }
}

struct BetaAddUserView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    // 회원가입 성공 시 Alert를 띄우는 목적의 변수
    
    @ObservedObject var viewModel: AddUserViewModel
    
    var FILTERPASSWORD = "^.*(?=^.{6,18}$)(?=.*\\d)(?=.*[a-zA-Z])(?=.*[!@#$%^&+=]).*$"
    var FILTER_EMAIL = "^[a-z_0-9]{1,12}$"
    
    init() {
        self.viewModel = AddUserViewModel(userFetcher: UserFetcher())
        // 네비게이션 바 글자색 설정(흰색)
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.black]
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.black]
        
    }
    
    var body: some View {
        
        VStack(alignment: .leading){
            Text("회원가입")
                .font(.title)
                .fontWeight(.bold)
            Spacer()
            VStack{
                HStack {
                    TextField("KOREATECH 이메일", text: $viewModel.email)
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
                        .font(.subheadline)
                        .onReceive(self.viewModel.$email) { email in
                            
                            if (checkRegex(target: email, pattern: self.FILTER_EMAIL)) {
                                self.viewModel.error = nil
                                self.viewModel.errorResult.send(UserError.parsing(description: ""))
                            } else {
                                self.viewModel.error = UserError.parsing(description: "이메일 형식에 맞지 않습니다.")
                                self.viewModel.errorResult.send(UserError.parsing(description: "이메일 형식에 맞지 않습니다."))
                            }
                    }
                    Text("@ koreatech.ac.kr")
                        .fontWeight(.regular)
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 10))
                        .font(.subheadline)
                }
                Divider()
                
                
                SecureField("비밀번호", text: $viewModel.password)
                    .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
                    .font(/*@START_MENU_TOKEN@*/.subheadline/*@END_MENU_TOKEN@*/)
                    .onReceive(self.viewModel.$password) { password in
                        
                        if (checkRegex(target: password, pattern: self.FILTERPASSWORD)) {
                            self.viewModel.error = nil
                            self.viewModel.errorResult.send(UserError.parsing(description: ""))
                        } else {
                            self.viewModel.error = UserError.parsing(description: "비밀번호 형식에 맞지 않습니다.")
                            self.viewModel.errorResult.send(UserError.parsing(description: "비밀번호 형식에 맞지 않습니다."))
                        }
                }
                
                Divider()
                
                SecureField("비밀번호 확인", text: $viewModel.validPassword)
                    .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
                    .font(.subheadline)
                    .onReceive(self.viewModel.$validPassword) { valid in
                        if (self.viewModel.password == valid) {
                            self.viewModel.error = nil
                            self.viewModel.errorResult.send(UserError.parsing(description: ""))
                        } else {
                            self.viewModel.error = UserError.parsing(description: "비밀번호가 서로 다릅니다.")
                            self.viewModel.errorResult.send(UserError.parsing(description: "비밀번호가 서로 다릅니다."))
                        }
                        
                }
                
                Divider()
                Text("* 특수문자를 포함한 영어와 숫자 6~18 자리로 입력해주세요")
                    .font(.system(size: 10))
                    .foregroundColor(Color("squash"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(self.viewModel.errorText)
                    .font(.system(size: 10))
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            HStack {
                Button(action: {
                    self.viewModel.showingPersonal.toggle()
                }) {
                    Text("개인정보 이용약관")
                        .foregroundColor(Color("grey2"))
                        .font(.system(size: 12))
                        .underline()
                }
                .sheet(isPresented: self.$viewModel.showingPersonal) {
                    TermsView(terms: true)
                }
                Spacer()
                Button(action: {
                    // 개인정보 이용약관이 체크되어있지 않으면 체크해주고
                    // 체크되어있으면, 체크를 해제해준다.
                    self.viewModel.checkPersonality.toggle()
                }) {
                    Image(systemName: self.viewModel.checkPersonality ? "checkmark.circle.fill" : "circle.fill")
                    Text("동의")
                        .font(.system(size: 12))
                        .foregroundColor(self.viewModel.checkPersonality ? Color("squash") : Color.white)
                }.accentColor(Color("squash"))
                
            }.padding()
                .frame(maxWidth: .infinity, alignment: .leading)
            HStack {
                
                Button(action: {
                    self.viewModel.showingKoin.toggle()
                }) {
                    Text("코인 이용약관")
                        .foregroundColor(Color("grey2"))
                        .font(.system(size: 12))
                        .underline()
                }.sheet(isPresented: self.$viewModel.showingKoin) {
                    TermsView(terms: false)
                }
                
                Spacer()
                Button(action: {
                    // 코인 이용약관이 체크되어있지 않으면 체크해주고
                    // 체크되어있으면, 체크를 해제해준다.
                    self.viewModel.checkKoin.toggle()
                }) {
                    Image(systemName: self.viewModel.checkKoin ? "checkmark.circle.fill" : "circle.fill")
                    Text("동의")
                        .font(.system(size: 12))
                        .foregroundColor(self.viewModel.checkKoin ? Color("squash") : Color.white)
                }.accentColor(Color("squash"))
                
                
            }.padding()
                .frame(maxWidth: .infinity, alignment: .leading)
            Button(action: {
                self.viewModel.addUser()
            }) {
                HStack {
                    Spacer()
                    Text("이메일로 인증하기")
                        .foregroundColor(Color.white)
                    Spacer()
                }
            }.padding().background(Color("squash"))
                .padding(EdgeInsets(top: 10, leading: 0, bottom: 5, trailing: 0))
                .onReceive(self.viewModel.loginResult) { result in
                    self.viewModel.showingAlert.toggle()
            }
            
            
            Spacer()
            HStack(alignment: .center, spacing: 0) {
                Text("Copyright @ ")
                    .font(.caption)
                    .fontWeight(.light)
                Text("BCSD Lab")
                    .font(.caption)
                    .fontWeight(.medium)
                Text(" All rights reserved.")
                    .font(.caption)
                    .fontWeight(.light)
            }
            .frame(maxWidth: .infinity)
            .offset(y: 15)
            .padding(.bottom, CGFloat(30))
            
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding([.leading, .trailing], CGFloat(50))
            .alert(isPresented: self.$viewModel.showingAlert) {
                // 이메일을 확인해보라는 Alert을 띄운 다음
                self.viewModel.showingSuccessAlert ?
                    Alert(title: Text("이메일 확인"), message: Text("회원 가입을 완료하시려면 메일을 확인해보세요."), dismissButton: .default(Text("돌아가기")) {
                    // 돌아가기 버튼을 누르면 Alert은 꺼지고
                    self.viewModel.showingAlert = false
                    self.presentationMode.wrappedValue.dismiss()
                    }) :
                    Alert(title: Text("에러"), message: Text(self.viewModel.errorText), dismissButton: .default(Text("닫기")) {
                        // 돌아가기 버튼을 누르면 Alert은 꺼지고
                        self.viewModel.showingAlert = false
                        })
        }
            
    }
}

struct BetaAddUserView_Previews: PreviewProvider {
    static var previews: some View {
        BetaAddUserView()
    }
}
