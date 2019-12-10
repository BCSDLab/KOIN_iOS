//
//  LoginView.swift
//  dev_koin
//
//  Created by 정태훈 on 2019/12/10.
//  Copyright © 2019 정태훈. All rights reserved.
//

import SwiftUI

struct LoginView: View {
    @State var login_email: String = ""
    @State var login_password: String = ""
    
    var body: some View {
        return VStack {
            Spacer()
            Image("logo_koin_color")
                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: ContentMode.fit)
                .frame(width: CGFloat(200))
                .padding(Edge.Set.bottom, CGFloat(20))
            Spacer()
            VStack {
                TextField("KOREATECH 이메일", text: $login_email)
                    .padding()
                    .background(Color.gray)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 15, trailing: 0))
                
                SecureField("비밀번호", text: $login_password)
                .padding()
                    .background(Color.gray)
                    .padding(.bottom, 10)
                
                
                Button(action: submit) {
                    HStack {
                        Spacer()
                        Text("로그인")
                            .foregroundColor(Color.white)
                        Spacer()
                    }
                     }.padding().background(Color("squash")).padding(.bottom, 5)
                
                Button(action: submit) {
                HStack {
                    Spacer()
                    Text("회원가입")
                        .foregroundColor(Color.white)
                    Spacer()
                }
                 }.padding().background(Color("light_navy"))
                
                HStack {
                    Button(action: submit) {
                        HStack {
                            Image("password").accentColor(.gray)
                            Text("비밀번호 찾기")
                                .foregroundColor(Color.gray)
                        }
                    }
                    Divider()
                        .frame(width: 0, height: 20)
                    
                    Button(action: submit) {
                        HStack {
                            Image("face").accentColor(.gray)
                            Text("둘러보기")
                                .foregroundColor(Color.gray)
                        }
                    }
                }.padding()
            }.padding([.leading, .trailing], CGFloat(50))
            Spacer()
            Text("Copyright @ BCSD Lab All rights reserved.")
            Spacer()
            

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
