//
//  LoginView.swift
//  dev_koin
//
//  Created by 정태훈 on 2019/12/10.
//  Copyright © 2019 정태훈. All rights reserved.
//

import SwiftUI
import Alamofire
import ObjectMapper
import AlamofireObjectMapper
import CryptoKit
import CryptoTokenKit
import Foundation



struct UserLoginView: View {
    @State var login_email: String = ""
    @State var login_password: String = ""
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var settings: UserSettings
    
    var body: some View {
    return ZStack {
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

                
                Button(action: {
                    if isLoginSuccess(email: self.login_email, password: self.login_password) {
                        UserDefaults.standard.set(true, forKey: "Loggedin")
                        UserDefaults.standard.synchronize()
                        self.settings.loggedIn = true
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
                .padding(.bottom, CGFloat(30))
        }
    }
        

    }
}


func submit() {
    
}

func isLoginSuccess(email: String, password: String) -> Bool {
    login_session(email: email, password: password) { user in
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(user) {
            UserDefaults.standard.set(encoded, forKey: "user")
        }
    }
    
    if let data = UserDefaults.standard.object(forKey:"user") as? Data {
        let decoder = JSONDecoder()
        if let loaded = try? decoder.decode(UserRequest.self, from: data) {
            return true
        }
    }
    return false
    
}

func login_session(email: String, password: String, completion: @escaping (UserRequest?) -> Void) {
    let inputData = Data(password.utf8)
    let hashed = SHA256.hash(data: inputData)
    let hashPassword = hashed.compactMap {String(format: "%02x", $0)}.joined().trimmingCharacters(in: CharacterSet.newlines)
    do {
        Alamofire
        .request("http://api.koreatech.in/user/login", method: .post, parameters:  ["portal_account": email,"password": hashPassword], encoding: JSONEncoding.prettyPrinted)
        .validate { request, response, data in
            return .success
        }
        .response { response in
            guard let data = response.data else { return }
            do {
                let decoder = JSONDecoder()
                let userRequest = try decoder.decode(UserRequest.self, from: data)
                
                completion(userRequest)
            } catch let error {
                print(error)
                completion(nil)
            }
        }
    }
}



struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        UserLoginView()
    }
}
