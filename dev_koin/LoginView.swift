//
//  LoginView.swift
//  dev_koin
//
//  Created by 정태훈 on 2019/12/10.
//  Copyright © 2019 정태훈. All rights reserved.
//

import SwiftUI

let store_email = "test"
let store_password = "test"

struct LoginView: View {
    @State var login_email: String = ""
    @State var login_password: String = ""
    
    
    
    @State var authenticationDidFail: Bool = false
    @State var authenticationDidSucceed: Bool = false
    
    var body: some View {
        return ZStack {
            if authenticationDidSucceed {
                Text("Login succeeded!")
            }
            if authenticationDidFail {
                Text("Login failed!")
            }
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
                            .font(/*@START_MENU_TOKEN@*/.subheadline/*@END_MENU_TOKEN@*/)
                        Text("@ koreatech.ac.kr")
                            .fontWeight(.regular)
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 10))
                            .font(/*@START_MENU_TOKEN@*/.footnote/*@END_MENU_TOKEN@*/)
                    }
                        Divider()
                    

                        SecureField("비밀번호", text: $login_password)
                            .padding(EdgeInsets(top: 20, leading: 0, bottom: 10, trailing: 0))
                            .font(/*@START_MENU_TOKEN@*/.subheadline/*@END_MENU_TOKEN@*/)
                    
                        Divider()
                    }

                    
                    
                    Button(action: {
                        if self.login_email == store_email && self.login_password == store_password {
                            self.authenticationDidSucceed = true
                            self.authenticationDidFail = false
                        } else {
                            self.authenticationDidFail = true
                            self.authenticationDidSucceed = false
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
                    
                    
                    Button(action: submit) {
                    HStack {
                        Spacer()
                        Text("회원가입")
                            .foregroundColor(Color.white)
                        Spacer()
                    }
                     }.padding().background(Color("light_navy"))
                    
                    HStack(alignment: .center) {
                        Button(action: submit) {
                            HStack {
                                Image("password").accentColor(.gray)
                                Text("비밀번호 찾기")
                                    .font(.subheadline)
                                    .foregroundColor(Color.gray)
                            }
                        }
                        Divider()
                            .frame(width: 0, height: 20)
                        
                        Button(action: submit) {
                            HStack {
                                Image("face").accentColor(.gray)
                                Text("둘러보기")
                                    .font(.subheadline)
                                    .foregroundColor(Color.gray)
                            }
                        }
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
                    .padding(.bottom, 30)
            }
        }
            

        }
        
        
        
        
    }
    


func submit() {
    // to be implement
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
