//
//  RecruitDataContentView.swift
//  koin
//

import SwiftUI

struct RecruitDataContentView: View {
    let data: RecruitData?
    let onButtonTapped: () -> Void
    
    private var buttonText: String {
        guard let data else {
            return ""
        }
        if data.isAuthor {
            return "지원자 확인하기"
        } else if data.canApply {
            return "지원하기"
        } else {
            return "모집 마감"
        }
    }
    
    private var isButtonEnabled: Bool {
        guard let data else {
            return false
        }
        if data.isAuthor || data.canApply {
            return true
        } else {
            return false
        }
    }
    
    init(
        data: RecruitData?,
        onButtonTapped: @escaping () -> Void
    ) {
        self.data = data
        self.onButtonTapped = onButtonTapped
    }

    var body: some View {
        if let data {
            GeometryReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        RecruitDataHeaderView(data: data)
                            .padding(.horizontal, 40)
                            .padding(.top, 16)
                        
                        Divider()
                            .backgroundStyle(Color.appColor(.neutral300))
                            .frame(height: 1)
                            .padding(.vertical, 16)
                            .padding(.horizontal, 20)
                        
                        VStack(alignment: .leading, spacing: 20) {
                            RecruitDataMetadataView(data: data)
                            
                            if data.type == .roleBased, !data.roles.isEmpty {
                                RecruitDataRolesView(roles: data.roles)
                            }
                            
                            RecruitDataTextSectionView(title: "모집 소개", text: data.description)
                            
                            if let qualification = data.qualification, !qualification.isEmpty {
                                RecruitDataTextSectionView(title: "지원 자격", text: qualification)
                            }
                            
                            if let url = data.relatedUrl {
                                RecruitDataRelatedUrlView(url: url)
                            }
                        }
                        .padding(.horizontal, 36)
                        
                        Spacer(minLength: 32)
                
                        RecruitDataButton(
                            text: buttonText,
                            isEnabled: isButtonEnabled,
                            action: onButtonTapped
                        )
                        .padding(.horizontal, 32)
                    }
                    .frame(minHeight: proxy.size.height)
                }
                .scrollIndicators(.hidden)
                .scrollBounceBehavior(.basedOnSize, axes: .vertical)
            }
        } else {
            Color.appColor(.newBackground)
        }
    }
}
