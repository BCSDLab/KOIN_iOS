//
//  BetaFindPasswordView.swift
//  Koin
//
//  Created by 정태훈 on 2020/05/13.
//  Copyright © 2020 정태훈. All rights reserved.
//

import SwiftUI

import SwiftUI
import PKHUD

struct BetaFindPasswordView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @ObservedObject var viewModel: FindPasswordViewModel

    var FILTER_EMAIL = "^[a-z_0-9]{1,12}$"
    
    init() {
        // 네비게이션 바 글자색 설정(흰색)
        self.viewModel = FindPasswordViewModel(userFetcher: UserFetcher())
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.black]
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.black]
    }
    
    var body: some View {
        
        return VStack(alignment: .leading) {
            Text("비밀번호 찾기")
                .font(.title)
                .fontWeight(.bold)
            Spacer()
            VStack{
                HStack {
                    TextField("KOREATECH 이메일", text: self.$viewModel.email)
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
            }
            Text(self.viewModel.errorText)
                .font(.system(size: 10))
                .foregroundColor(.red)
                .frame(maxWidth: .infinity, alignment: .leading)
            Spacer()
            
            Button(action: {
                self.viewModel.findPassword()
            }) {
                HStack {
                    Spacer()
                    Text("이메일로 인증하기")
                        .foregroundColor(Color.white)
                    Spacer()
                }
            }.padding().background(Color("squash"))
                .padding(EdgeInsets(top: 10, leading: 0, bottom: 5, trailing: 0))
                .onReceive(self.viewModel.result) { result in
                    
                    self.viewModel.showingAlert = true
            }
            
            
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding([.leading, .trailing], CGFloat(50))
            //showingSuccessAlert이 true일 때 Alert을 표시한다.
            .alert(isPresented: self.$viewModel.showingAlert) {
                self.viewModel.showingSuccessAlert ?
                    Alert(title: Text("이메일 확인"), message: Text("이메일로 비밀번호 찾기 안내 메일을 보냈습니다. 확인해보세요."), dismissButton: .default(Text("돌아가기")) {
                        // 돌아가기 버튼을 누르면 Alert은 꺼지고
                        self.viewModel.showingSuccessAlert = false
                        // 로그인 페이지로 돌아간다.
                        self.presentationMode.wrappedValue.dismiss()
                        }) :
                    Alert(title: Text("에러"), message: Text(self.viewModel.errorText), dismissButton: .default(Text("닫기")) {
                        // 돌아가기 버튼을 누르면 Alert은 꺼지고
                        self.viewModel.showingAlert = false
                        })
        }
        
    }
}

struct BetaFindPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        BetaFindPasswordView()
    }
}
