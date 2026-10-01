//
//  RecruitMyPostApplicantView.swift
//  koin
//
//  Created by 홍기정 on 9/28/26.
//

import SwiftUI

struct RecruitMyPostApplicantView: ActionBindableView {

    enum Action {
        case showDecisionModal(RecruitApplicantDecision)
        case showDirectChat(recruitmentId: Int, applicationId: Int)
        case showToast(message: String)
    }

    // MARK: - Properties
    var sendAction: (Action) -> Void = { _ in }
    @State private var viewModel: RecruitMyPostApplicantViewModel

    // MARK: - Initializer
    init(viewModel: RecruitMyPostApplicantViewModel) {
        self.viewModel = viewModel
    }

    // MARK: - Body
    var body: some View {
        Group {
            if let application = viewModel.application {
                contentView(application)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appColor(.newBackground).ignoresSafeArea())
        .loadingOverlay(viewModel.isLoading)
        .onFirstAppear {
            viewModel.execute(.onFirstAppear)
        }
        .onChange(of: viewModel.errorMessage) {
            guard let message = viewModel.errorMessage else {
                return
            }
            sendAction(.showToast(message: message))
            viewModel.execute(.didShowToast)
        }
    }
    
    // MARK: - Public
    func decide(_ decision: RecruitApplicantDecision) {
        viewModel.execute(.decide(decision))
    }
}


extension RecruitMyPostApplicantView {
    private func contentView(_ application: RecruitApplicantData) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                RecruitMyPostApplicantProfileView(application: application)
                
                VStack(alignment: .leading, spacing: 16) {
                    largeTitleView("기본 정보")

                    VStack(alignment: .leading, spacing: 12) {
                        mediumTitleView("보유기술")
                        LeftAlignedLayout(interitemSpacing: 8, interlineSpacing: 8) {
                            ForEach(application.profile.skills, id: \.self) { role in
                                RecruitMyPostApplicantRoleChipView(role: role)
                            }
                        }

                        mediumTitleView("활동 이력")
                        VStack(spacing: 12) {
                            ForEach(application.profile.activities) { activity in
                                RecruitMyPostApplicantActivityView(activity: activity)
                            }
                        }

                        mediumTitleView("자기소개")
                        RecruitMyPostApplicantTextView(text: application.profile.selfIntroduction)
                    }
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    largeTitleView("지원 내용")

                    VStack(alignment: .leading, spacing: 12) {
                        mediumTitleView("지원 동기")
                        RecruitMyPostApplicantTextView(text: application.motivation)

                        mediumTitleView("활동 가능 시간")
                        RecruitMyPostApplicantTextView(text: application.availableTime)
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .padding(.bottom, 24)
        }
        .scrollIndicators(.hidden)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            RecruitMyPostApplicantBottomActionView(
                application: application,
                isLoading: viewModel.isLoading,
                onDecisionTapped: { decision in
                    sendAction(.showDecisionModal(decision))
                },
                onDirectChatTapped: {
                    sendAction(.showDirectChat(
                        recruitmentId: viewModel.recruitmentId,
                        applicationId: application.applicationId
                    ))
                }
            )
            .padding(.horizontal, 32)
            .padding(.vertical, 16)
            .background(Color.appColor(.newBackground))
        }
    }

    @ViewBuilder
    private func largeTitleView(_ title: String) -> some View {
        Text(title)
            .font(.appFont(.pretendardSemiBold, size: 16))
            .foregroundStyle(Color.appColor(.neutral800))
    }

    @ViewBuilder
    private func mediumTitleView(_ title: String) -> some View {
        Text(title)
            .font(.appFont(.pretendardMedium, size: 14))
            .foregroundStyle(Color.appColor(.neutral800))
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
