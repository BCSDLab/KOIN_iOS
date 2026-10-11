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
        case showMyPost
        case showMyApplication
        case showToast(message: String)
    }
    
    // MARK: - Properties
    var sendAction: (Action) -> Void = { _ in }
    @State private var viewModel: RecruitProfileViewModel

    // MARK: - Initializer
    init(viewModel: RecruitProfileViewModel) {
        self.viewModel = viewModel
    }
    
    // MARK: - Public
    func updateProfile(_ profile: RecruitProfile) {
        viewModel.execute(.profileUpdated(profile))
    }

    // MARK: - Body
    var body: some View {
        ScrollView {
            if viewModel.didLoad {
                VStack(spacing: 24) {
                    if let profile = viewModel.profile {
                        RecruitProfileCardView(profile: profile) {
                            viewModel.execute(.logEvent(EventParameter.EventLabel.Campus.teamRecruitmentProfileModify, .click, "프로필 수정하기"))
                            sendAction(.showProfileModify(profile: profile))
                        }
                    } else {
                        RecruitProfileEmptyCardView {
                            viewModel.execute(.logEvent(EventParameter.EventLabel.Campus.teamRecruitmentProfileCreate, .click, "프로필 작성하기"))
                            sendAction(.showProfilePost)
                        }
                    }
                    
                    RecruitProfileActionCardView(
                        icon: .recruitProfileMyPost,
                        title: viewModel.profile == nil ? "내가 작성한 모집글 모아보기" : "내가 작성한 모집글",
                        description: "작성자 모집글과 지원자를 한눈에 확인할 수 있어요."
                    ) {
                        viewModel.execute(.logEvent(EventParameter.EventLabel.Campus.teamRecruitmentProfileCreated, .click, "내가 작성한 모집글"))
                        sendAction(.showMyPost)
                    }
                    
                    RecruitProfileActionCardView(
                        icon: .recruitProfileMyApplication,
                        title: viewModel.profile == nil ? "내가 지원한 모집글 모아보기" : "내가 지원한 모집글",
                        description: "지원한 모집글과 지원 상태를 확인 할 수 있어요."
                    ) {
                        viewModel.execute(.logEvent(EventParameter.EventLabel.Campus.teamRecruitmentProfileApplied, .click, "내가 지원한 모집글"))
                        sendAction(.showMyApplication)
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
        .onFirstAppear {
            viewModel.execute(.didAppear)
        }
        .onChange(of: viewModel.errorMessage) {
            guard let message = viewModel.errorMessage else { return }
            sendAction(.showToast(message: message))
            viewModel.execute(.didShowToast)
        }
    }
}
