//
//  AddUserView.swift
//  dev_koin
//
//  Created by 정태훈 on 2019/12/27.
//  Copyright © 2019 정태훈. All rights reserved.
//

import SwiftUI
import PKHUD

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


struct AddUserView: View {
    // 이메일 정보를 담는 변수
    @State var login_email: String = ""
    // 패스워드 정보를 담는 변수
    @State var login_password: String = ""
    // 패스워드가 일치하는지 확인하는 변수
    @State var login_valid_password: String = ""
    // 로그인 페이지로 돌아갈 때 사용하는 객체
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    // 회원가입 성공 시 Alert를 띄우는 목적의 변수
    @State private var showingSuccessAlert = false
    
    @State private var showingKoin = false
    @State private var showingPersonal = false
    
    // 실패시, 에러 HUD를 띄울 때의 String 변수
    @State var errorText = ""
    // 약관 동의 여부를 확인하는 객체
    @EnvironmentObject var property: AddUserProperty
    // 유저 정보가 담겨있는 객체
    @EnvironmentObject var settings: UserSettings
    
    init() {
        // 네비게이션 바 글자색 설정(흰색)
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.black]
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.black]
    }
    
    // 회원가입 기능을 제공하는 함수
    func check_register(email: String, password: String, valid_password: String) {
        // 에러 HUD를 위한 임의의 뷰 객체
        let uiview = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 100))
        // 에러 HUD 내에서의 에러 문자 뷰 객체
        let yourLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
        yourLabel.center = CGPoint(x: uiview.frame.size.width  / 2,
        y: uiview.frame.size.height / 2)
        yourLabel.textAlignment = .center
        
        // settings 내의 패스워드 일치 여부를 확인하고
        if settings.check_valid_password(password: password, valid_password: valid_password) {
            // 이용약관 동의 여부를 모두 확인한 다음
            if self.property.personality_checked && self.property.koin_checked {
                // 회원가입 정보를 서버로 보내준 후에
                self.settings.register_session(email: email, password: password) { result in
                    if result { // 성공하면
                        // 성공했다고 알려주는 Alert을 열고
                        self.showingSuccessAlert = true
                    } else { // 아니면
                        // 에러 문자로 회원 가입에 실패했다고 알려주고
                        self.errorText = "회원가입에 실패하였습니다."
                        // 에러 HUD를 보여준다.
                        yourLabel.text = self.errorText
                        uiview.addSubview(yourLabel)
                        PKHUD.sharedHUD.contentView = uiview
                        PKHUD.sharedHUD.show()
                        PKHUD.sharedHUD.hide(afterDelay: 1.0)
                    }
                }
            } else { // 동의되지 않은 약관이 있으면
                // 동의되지 않은 약관이 있다고 알려주고
                self.errorText = "동의되지 않은 약관이 있습니다."
                // 에러 HUD를 보여준다.
                yourLabel.text = self.errorText
                uiview.addSubview(yourLabel)
                PKHUD.sharedHUD.contentView = uiview
                PKHUD.sharedHUD.show()
                PKHUD.sharedHUD.hide(afterDelay: 1.0)
            }
        } else { // 비밀번호가 다르다면
            // 비밀번호가 다르다고 알려주고
            self.errorText = "비밀번호가 다릅니다."
            // 에러 HUD를 보여준다.
            yourLabel.text = self.errorText
            uiview.addSubview(yourLabel)
            PKHUD.sharedHUD.contentView = uiview
            PKHUD.sharedHUD.show()
            PKHUD.sharedHUD.hide(afterDelay: 1.0)
        }
        
    }
    
    
    var body: some View {
        
        VStack(alignment: .leading){
            Text("회원가입")
                .font(.title)
                .fontWeight(.bold)
            Spacer()
            VStack{
            HStack {
                TextField("KOREATECH 이메일", text: $login_email)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
                    .font(.subheadline)
                Text("@ koreatech.ac.kr")
                    .fontWeight(.regular)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 10))
                    .font(.subheadline)
            }
                Divider()
            

                SecureField("비밀번호", text: $login_password)
                    .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
                    .font(/*@START_MENU_TOKEN@*/.subheadline/*@END_MENU_TOKEN@*/)
            
                Divider()
                
                SecureField("비밀번호 확인", text: $login_valid_password)
                .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
                .font(.subheadline)
                
                Divider()
                Text("* 특수문자를 포함한 영어와 숫자 6~18 자리로 입력해주세요")
                .font(.system(size: 10))
                .foregroundColor(Color("squash"))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            HStack {
                Button(action: {
                    self.showingPersonal.toggle()
                }) {
                    Text("개인정보 이용약관")
                        .foregroundColor(Color("gray2"))
                    .font(.system(size: 12))
                    .underline()
                }
                .sheet(isPresented: $showingPersonal) {
                    TermsView(terms: true)
                }
                Spacer()
                Button(action: {
                    // 개인정보 이용약관이 체크되어있지 않으면 체크해주고
                    // 체크되어있으면, 체크를 해제해준다.
                    self.property.personality_checked.toggle()
                }) {
                    Image(systemName: self.property.personality_checked ? "checkmark.circle.fill" : "circle.fill")
                        Text("동의")
                            .font(.system(size: 12))
                            .foregroundColor(self.property.personality_checked ? Color("squash") : Color.white)
                }.accentColor(Color("squash"))
                
            }.padding()
                .frame(maxWidth: .infinity, alignment: .leading)
            HStack {
                
                Button(action: {
                    self.showingKoin.toggle()
                }) {
                    Text("코인 이용약관")
                    .foregroundColor(Color("gray2"))
                    .font(.system(size: 12))
                    .underline()
                }.sheet(isPresented: $showingKoin) {
                    TermsView(terms: false)
                }
                
                
                
                Spacer()
                Button(action: {
                    // 코인 이용약관이 체크되어있지 않으면 체크해주고
                    // 체크되어있으면, 체크를 해제해준다.
                    self.property.koin_checked.toggle()
                }) {
                    Image(systemName: self.property.koin_checked ? "checkmark.circle.fill" : "circle.fill")
                    Text("동의")
                    .font(.system(size: 12))
                    .foregroundColor(self.property.koin_checked ? Color("squash") : Color.white)
                }.accentColor(Color("squash"))
            
                
            }.padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            Button(action: {
                self.check_register(email: self.login_email, password: self.login_password, valid_password: self.login_valid_password)
            }) {
                HStack {
                    Spacer()
                    Text("이메일로 인증하기")
                        .foregroundColor(Color.white)
                    Spacer()
                }
            }.padding().background(Color("squash"))
                .padding(EdgeInsets(top: 10, leading: 0, bottom: 5, trailing: 0))
            
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
            
            //showingSuccessAlert이 true일 때 Alert을 표시한다.
        .alert(isPresented: $showingSuccessAlert) {
            // 이메일을 확인해보라는 Alert을 띄운 다음
                Alert(title: Text("이메일 확인"), message: Text("회원 가입을 완료하시려면 메일을 확인해보세요."), dismissButton: .default(Text("돌아가기")) {
                    // 돌아가기 버튼을 누르면 Alert은 꺼지고
                    self.showingSuccessAlert = false
                   // 로그인 페이지로 돌아간다.
                self.presentationMode.wrappedValue.dismiss()
                    })
        }
        
        
        
    }
}

struct AddUserView_Previews: PreviewProvider {
    static var previews: some View {
        AddUserView()
    }
}
