//
//  AddUserView.swift
//  dev_koin
//
//  Created by 정태훈 on 2019/12/27.
//  Copyright © 2019 정태훈. All rights reserved.
//

import SwiftUI


struct AddUserView: View {
    @State var login_email: String = ""
    @State var login_password: String = ""
    @State var login_valid_password: String = ""
    
    @EnvironmentObject var property: AddUserProperty
    
    
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
            
                Text("개인정보 이용약관")
                .font(.system(size: 12))
                .underline()
                Spacer()
                Button(action: {
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
                
                Text("코인 이용약관")
                .font(.system(size: 12))
                .underline()
                
                Spacer()
                Button(action: {
                    
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
        
        
        
    }
}

struct AddUserView_Previews: PreviewProvider {
    static var previews: some View {
        AddUserView()
    }
}
