//
//  RecruitDataContentView.swift
//  koin
//

import SwiftUI

struct RecruitDataContentView: View {
    let data: RecruitData?
    let onButtonTapped: () -> Void
    
    init(
        data: RecruitData?,
        onButtonTapped: @escaping () -> Void
    ) {
        self.data = data
        self.onButtonTapped = onButtonTapped
    }

    var body: some View {
        if let data {
            VStack(spacing: 16) {
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
                    }
                }
                .scrollIndicators(.hidden)
                .scrollBounceBehavior(.basedOnSize, axes: .vertical)

                RecruitDataButton(
                    text: data.buttonText,
                    isEnabled: data.isButtonEnabled,
                    action: onButtonTapped
                )
                .padding(.horizontal, 32)
            }
        } else {
            Color.appColor(.newBackground)
        }
    }
}
