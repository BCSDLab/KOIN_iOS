//
//  BetaLoginView.swift
//  Koin
//
//  Created by 정태훈 on 2020/05/13.
//  Copyright © 2020 정태훈. All rights reserved.
//

import SwiftUI
import Alamofire
import CryptoKit
import CryptoTokenKit
import Foundation
import PKHUD


struct BetaLoginView: View {
    @EnvironmentObject var config: UserConfig
    @ObservedObject var viewModel: LoginViewModel = LoginViewModel(userFetcher: UserFetcher())
    
    
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
                            TextField("KOREATECH 이메일", text: $viewModel.email)
                                .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
                                .font(.subheadline)
                            Text("@ koreatech.ac.kr")
                                .fontWeight(.regular)
                                .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 10))
                                .font(.subheadline)
                        }
                        Divider()
                        
                        
                        SecureField("비밀번호", text: $viewModel.password)
                            .padding(EdgeInsets(top: 20, leading: 0, bottom: 10, trailing: 0))
                            .font(/*@START_MENU_TOKEN@*/.subheadline/*@END_MENU_TOKEN@*/)
                        
                        Divider()
                    }
                    
                    // 로그인 버튼을 누르면
                    Button(action: {
                        self.viewModel.login()
                    }) {
                        HStack {
                            Spacer()
                            Text("로그인")
                                    .foregroundColor(Color.white)
                            Spacer()
                        }
                    }.onReceive(viewModel.loginResult) { user in
                                self.config.checkUser(user: user)
                            }.onReceive(self.viewModel.errorResult) { result in
                                self.viewModel.showingAlert.toggle()
                            }.padding().background(Color("squash"))
                        .padding(EdgeInsets(top: 10, leading: 0, bottom: 5, trailing: 0))
                    
                    
                    
                    HStack {
                        Spacer()
                        NavigationLink(destination: BetaAddUserView()) {
                            Text("회원가입")
                                .foregroundColor(Color.white)
                        }
                        Spacer()
                    }.padding().background(Color("light_navy"))
                    
                    
                    HStack(alignment: .center) {
                        
                        NavigationLink(destination: BetaFindPasswordView()) {
                            HStack {
                                Image("password").accentColor(.gray)
                                Text("비밀번호 찾기")
                                    .font(.subheadline)
                                    .foregroundColor(Color.gray)
                            }
                        }
                        
                         Divider()
                         .frame(width: 0, height: 20)
                         
                        Button(action: {
                            self.config.isLogin = true
                        }) {
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
        }.alert(isPresented: self.$viewModel.showingAlert) {
            // 이메일을 확인해보라는 Alert을 띄운 다음
            Alert(title: Text("에러"), message: Text(self.viewModel.errorText), dismissButton: .default(Text("닫기")) {
                // 돌아가기 버튼을 누르면 Alert은 꺼지고
                self.viewModel.showingAlert = false
            })

        }
        
        
    }
}

