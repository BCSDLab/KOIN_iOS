//
//  RecruitProfileView.swift
//  koin
//
//  Created by 홍기정 on 9/13/26.
//

import SwiftUI

struct RecruitProfileView: ActionBindableView {
    enum Action {
        case showProfilePost
        case showProfileModify(profile: RecruitProfile)
        case showMyPosts
        case showMyApplications
        case showToast(message: String)
    }
    
    // MARK: - Properties
    var sendAction: (Action) -> Void = { _ in }
    @State private var viewModel: RecruitProfileViewModel

    // MARK: - Initializer
    init(viewModel: RecruitProfileViewModel) {
        self.viewModel = viewModel
    }

    // MARK: - Body
    var body: some View {
        ScrollView {
            if viewModel.didLoad {
                VStack(spacing: 24) {
                    if let profile = viewModel.profile {
                        RecruitProfileCardView(profile: profile) {
                            sendAction(.showProfileModify(profile: profile))
                        }
                    } else {
                        RecruitProfileEmptyCardView {
                            sendAction(.showProfilePost)
                        }
                    }
                    
                    RecruitProfileActionCardView(
                        icon: .recruitProfileMyPosts,
                        title: viewModel.profile == nil ? "내가 작성한 모집글 모아보기" : "내가 작성한 모집글",
                        description: "작성자 모집글과 지원자를 한눈에 확인할 수 있어요."
                    ) {
                        sendAction(.showMyPosts)
                    }
                    
                    RecruitProfileActionCardView(
                        icon: .recruitProfileMyApplications,
                        title: viewModel.profile == nil ? "내가 지원한 모집글 모아보기" : "내가 지원한 모집글",
                        description: "지원한 모집글과 지원 상태를 확인 할 수 있어요."
                    ) {
                        sendAction(.showMyPosts)
                    }
                }
                .padding(.top, 16)
                .padding(.horizontal, 24)
                .frame(maxWidth: .infinity)
            } else {
                Color.appColor(.newBackground)
            }
        }
        .background(Color.appColor(.newBackground).ignoresSafeArea())
        .loadingOverlay(viewModel.isLoading)
        .onAppear {
            viewModel.execute(.didAppear)
        }
        .onChange(of: viewModel.errorMessage) {
            guard let message = viewModel.errorMessage else { return }
            sendAction(.showToast(message: message))
            viewModel.execute(.didShowToast)
        }
    }
}
