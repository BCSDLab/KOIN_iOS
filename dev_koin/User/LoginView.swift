//
//  LoginView.swift
//  dev_koin
//
//  Created by 정태훈 on 2019/12/10.
//  Copyright © 2019 정태훈. All rights reserved.
//

import SwiftUI
import Alamofire
import CryptoKit
import CryptoTokenKit
import Foundation
import PKHUD


struct UserLoginView: View {
    // 이메일 변수
    @State var login_email: String = ""
    // 비밀번호 변수
    @State var login_password: String = ""
    // 유저 정보 변수
    @EnvironmentObject var settings: UserSettings
    
    var body: some View {
    return NavigationView {
        VStack {
            Spacer()
            Image("logo_koin_color")
                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: ContentMode.fit)
                .frame(width: CGFloat(200))
                .padding(Edge.Set.bottom, CGFloat(20))
            Spacer()
            VStack {
                VStack{
                HStack {
                    TextField("KOREATECH 이메일", text: $login_email)
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
                        .font(.subheadline)
                    Text("@ koreatech.ac.kr")
                        .fontWeight(.regular)
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 10))
                        .font(.subheadline)
                }
                    Divider()
                

                    SecureField("비밀번호", text: $login_password)
                        .padding(EdgeInsets(top: 20, leading: 0, bottom: 10, trailing: 0))
                        .font(/*@START_MENU_TOKEN@*/.subheadline/*@END_MENU_TOKEN@*/)
                
                    Divider()
                }

                // 로그인 버튼을 누르면
                Button(action: {
                    // 로딩 HUD를 띄우고
                    HUD.show(.progress)
                    DispatchQueue.main.async {
                        // 로그인 과정을 진행하고
                        self.settings.login_session(email: self.login_email, password: self.login_password)
                        // 0.5초동안 성공 HUD를 띄운다
                        HUD.flash(.success, delay: 0.5)
                    }
                }) {
                    HStack {
                        Spacer()
                        Text("로그인")
                            .foregroundColor(Color.white)
                        Spacer()
                    }
                }.padding().background(Color("squash"))
                    .padding(EdgeInsets(top: 10, leading: 0, bottom: 5, trailing: 0))
                
                
                
                HStack {
                    Spacer()
                    NavigationLink(destination: AddUserView().environmentObject(AddUserProperty())) {
                        Text("회원가입")
                            .foregroundColor(Color.white)
                    }
                    Spacer()
                }.padding().background(Color("light_navy"))
                 
                
                HStack(alignment: .center) {
                    
                    NavigationLink(destination: FindPasswordView()) {
                        HStack {
                            Image("password").accentColor(.gray)
                            Text("비밀번호 찾기")
                                .font(.subheadline)
                                .foregroundColor(Color.gray)
                        }
                    }
                    Divider()
                        .frame(width: 0, height: 20)
                    /*
                    Button(action: submit) {
                        HStack {
                            Image("face").accentColor(.gray)
                            Text("둘러보기")
                                .font(.subheadline)
                                .foregroundColor(Color.gray)
                        }
                    }*/
                }
                .padding()
                
            }.padding([.leading, .trailing], CGFloat(50))
            Spacer()
            HStack(spacing: 0) {
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
                .offset(y: 15)
                .padding(.bottom, CGFloat(30))
        }
    }
        

    }
}


func submit() {
    
}





struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        UserLoginView()
    }
}
