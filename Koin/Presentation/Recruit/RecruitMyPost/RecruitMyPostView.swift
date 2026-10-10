//
//  RecruitMyPostView.swift
//  koin
//
//  Created by 홍기정 on 9/27/26.
//

import SwiftUI

struct RecruitMyPostView: ActionBindableView {

    enum Action {
        case showToast(message: String)
        case showApplicant(recruitmentId: Int, applicationId: Int)
        case showDirectChat(recruitmentId: Int, applicationId: Int)
        case showChat(recruitmentId: Int, chatRoomId: Int)
    }

    // MARK: - Properties
    var sendAction: (Action) -> Void = { _ in }
    @State private var viewModel: RecruitMyPostViewModel

    // MARK: - Initializer
    init(viewModel: RecruitMyPostViewModel) {
        self.viewModel = viewModel
    }

    // MARK: - Body
    var body: some View {
        Group {
            if let data = viewModel.data {
                contentView(data: data)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .loadingOverlay(viewModel.isLoading && viewModel.data == nil)
        .background(Color.appColor(.newBackground).ignoresSafeArea())
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
}

extension RecruitMyPostView {
    private func contentView(data: RecruitMyPostData) -> some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    RecruitMyPostSummaryView(model: data) {
                        guard let chatRoomId = data.chatRoomId else { return }
                        sendAction(.showChat(recruitmentId: data.id, chatRoomId: chatRoomId))
                    }

                    applicantListHeader
                        .padding(.top, 24)
                        .padding(.leading, 4)

                    if data.applicants.isEmpty {
                        Spacer(minLength: 0)

                        RecruitMyPostEmptyView()
                            .frame(maxWidth: .infinity)

                        Spacer(minLength: 0)
                    } else {
                        LazyVStack(spacing: 12) {
                            ForEach(data.applicants) { applicant in
                                RecruitMyPostApplicantRowView(
                                    model: applicant,
                                    onApplicationTapped: {
                                        viewModel.execute(.logEvent(
                                            EventParameter.EventLabel.Campus.teamRecruitmentCreatedPostApplicantSelect,
                                            .click,
                                            "지원자 선택"
                                        ))
                                        sendAction(.showApplicant(
                                            recruitmentId: data.id,
                                            applicationId: applicant.applicationId
                                        ))
                                    },
                                    onDirectChatTapped: {
                                        viewModel.execute(.logEvent(
                                            EventParameter.EventLabel.Campus.teamRecruitmentCreatedPostApplicantChat,
                                            .click,
                                            "채팅"
                                        ))
                                        sendAction(.showDirectChat(
                                            recruitmentId: data.id,
                                            applicationId: applicant.applicationId
                                        ))
                                    }
                                )
                                .onAppear {
                                    loadNextPageIfNeeded(applicationId: applicant.applicationId)
                                }
                            }
                        }
                        .padding(.top, 24)

                        ProgressView()
                            .frame(maxWidth: .infinity, alignment: .center)
                            .frame(height: 24)
                            .padding(.top, 12)
                            .isHidden(!(data.hasNextPage && viewModel.isLoading))
                    }
                }
                .padding(.horizontal, 24)
                .frame(minHeight: max(proxy.size.height - 44, 0), alignment: .top)
                .padding(.top, 20)
                .padding(.bottom, 24)
            }
            .scrollIndicators(.hidden)
            .refreshable {
                viewModel.execute(.refresh)
            }
        }
    }

    private var applicantListHeader: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("지원자 목록")
                .font(.appFont(.pretendardSemiBold, size: 16))
                .foregroundStyle(Color.appColor(.neutral800))
                .frame(height: 26)

            Text("총 \(viewModel.data?.totalCount ?? 0)명")
                .font(.appFont(.pretendardRegular, size: 12))
                .foregroundStyle(Color.appColor(.neutral500))
                .frame(height: 19)
        }
    }
}

extension RecruitMyPostView {
    private func loadNextPageIfNeeded(applicationId: Int) {
        guard let data = viewModel.data,
              data.applicants.last?.applicationId == applicationId,
              data.hasNextPage,
              !viewModel.isLoading else {
            return
        }
        viewModel.execute(.loadNextPage)
    }
}
