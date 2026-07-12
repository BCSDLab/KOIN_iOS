//
//  ProfileUserInfoView.swift
//  koin
//
//  Created by 홍기정 on 7/11/26.
//

import SwiftUI

struct ProfileUserInfoView: View {
    
    let userInfo: UserDto?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            HStack(alignment: .center, spacing: 13) {
                Image.appImage(asset: .profileHuman)
                    .frame(width: 44, height: 44, alignment: .center)
                    .background(Color.appColor(.neutral0))
                    .clipShape(.circle)
                    .border(.appColor(.neutral100), width: 0.5, radius: 22)
                
                if let userInfo {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(userInfo.name ?? userInfo.nickname ?? "익명")
                            .font(.appFont(.pretendardSemiBold, size: 16))
                            .foregroundStyle(Color(hex: "0B0B0D"))
                            .frame(height: 26, alignment: .center)
                        
                        if let studentNumber = userInfo.studentNumber {
                            Text(studentNumber)
                                .font(.appFont(.pretendardRegular, size: 12))
                                .foregroundStyle(Color.appColor(.neutral500))
                                .frame(minHeight: 19, alignment: .center)
                        }
                    }
                } else {
                    Text("로그인해주세요")
                        .font(.appFont(.pretendardSemiBold, size: 16))
                        .foregroundStyle(Color(hex: "0B0B0D"))
                }
                
                Spacer()
            }
            .padding(EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20))
            
            
            Button(action: { }) {
                HStack(spacing: 16) {
                    Image.appImage(asset: userInfo == nil ? .profileLogin : .profileLogout)
                        .frame(width: 40, height: 40, alignment: .center)
                        .background(Color.ColorSystem.Neutral.gray100)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    Text(userInfo == nil ? "로그인" : "로그아웃")
                        .font(.appFont(.pretendardSemiBold, size: 15))
                        .foregroundStyle(Color.appColor(.neutral800))
                        .frame(alignment: .center)
                    
                    Spacer()
                }
                .padding(EdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 0))
                .contentShape(.rect)
            }
            .buttonStyle(.plain)
            
            Button(action: { }) {
                HStack(spacing: 16) {
                    Image.appImage(asset: .profileSetting)
                        .frame(width: 40, height: 40, alignment: .center)
                        .background(Color.ColorSystem.Neutral.gray100)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    Text("설정")
                        .font(.appFont(.pretendardSemiBold, size: 15))
                        .foregroundStyle(Color.appColor(.neutral800))
                        .frame(alignment: .center)
                    
                    Spacer()
                }
                .padding(EdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 0))
                .contentShape(.rect)
            }
            .buttonStyle(.plain)
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}
