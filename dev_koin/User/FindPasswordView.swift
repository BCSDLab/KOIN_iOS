//
//  FindPasswordView.swift
//  dev_koin
//
//  Created by 정태훈 on 2020/02/13.
//  Copyright © 2020 정태훈. All rights reserved.
//

import SwiftUI
import PKHUD

struct FindPasswordView: View {
    
    // 이메일 정보를 담는 변수
    @State var login_email: String = ""
    // 로그인 페이지로 돌아갈 때 사용하는 객체
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    // 회원가입 성공 시 Alert를 띄우는 목적의 변수
    @State private var showingSuccessAlert = false
    // 유저 정보가 담겨있는 객체
    @EnvironmentObject var settings: UserSettings
    
    
    
    var body: some View {
        // 에러 HUD를 위한 임의의 뷰 객체
        let uiview = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 100))
        // 에러 HUD 내에서의 에러 문자 뷰 객체
        let yourLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
        yourLabel.center = CGPoint(x: uiview.frame.size.width  / 2,
        y: uiview.frame.size.height / 2)
        yourLabel.textAlignment = .center
        
        return VStack(alignment: .leading){
            Text("비밀번호 찾기")
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
            }
            Spacer()
            
            Button(action: {
                self.settings.find_password(email: self.login_email) { result in
                    if result {
                        self.showingSuccessAlert = true
                    } else {
                        let errorText = "유저 정보를 찾을 수 없습니다."
                        // 에러 HUD를 보여준다.
                        yourLabel.text = errorText
                        uiview.addSubview(yourLabel)
                        PKHUD.sharedHUD.contentView = uiview
                        PKHUD.sharedHUD.show()
                        PKHUD.sharedHUD.hide(afterDelay: 1.0)
                    }
                }
            }) {
                HStack {
                    Spacer()
                    Text("이메일로 인증하기")
                        .foregroundColor(Color.white)
                    Spacer()
                }
            }.padding().background(Color("squash"))
                .padding(EdgeInsets(top: 10, leading: 0, bottom: 5, trailing: 0))
            
            
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding([.leading, .trailing], CGFloat(50))
            //showingSuccessAlert이 true일 때 Alert을 표시한다.
        .alert(isPresented: $showingSuccessAlert) {
            // 이메일을 확인해보라는 Alert을 띄운 다음
                Alert(title: Text("이메일 확인"), message: Text("이메일로 비밀번호 찾기 안내 메일을 보냈습니다. 확인해보세요."), dismissButton: .default(Text("돌아가기")) {
                    // 돌아가기 버튼을 누르면 Alert은 꺼지고
                    self.showingSuccessAlert = false
                   // 로그인 페이지로 돌아간다.
                self.presentationMode.wrappedValue.dismiss()
                    })
        }
    }
}

struct FindPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        FindPasswordView()
    }
}
