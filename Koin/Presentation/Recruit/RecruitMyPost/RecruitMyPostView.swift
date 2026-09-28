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
        .loadingOverlay(viewModel.isLoading)
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
    private func contentView(data: RecruitMyPostSummary) -> some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    RecruitMyPostSummaryView(model: data) {
                        // TODO
                    }

                    applicantListHeader
                        .padding(.top, 24)
                        .padding(.leading, 4)

                    if data.applications.isEmpty {
                        Spacer(minLength: 0)

                        RecruitMyPostEmptyView()
                            .frame(maxWidth: .infinity)

                        Spacer(minLength: 0)
                    } else {
                        LazyVStack(spacing: 12) {
                            ForEach(data.applications) { applicant in
                                RecruitMyPostApplicantRowView(
                                    model: applicant,
                                    onApplicationTapped: {}, // TODO
                                    onDirectChatTapped: {} // TODO
                                )
                            }
                        }
                        .padding(.top, 24)
                    }
                }
                .padding(.horizontal, 24)
                .frame(minHeight: max(proxy.size.height - 44, 0), alignment: .top)
                .padding(.top, 20)
                .padding(.bottom, 24)
            }
            .scrollIndicators(.hidden)
        }
    }

    private var applicantListHeader: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("지원자 목록")
                .font(.appFont(.pretendardSemiBold, size: 16))
                .foregroundStyle(Color.appColor(.neutral800))
                .frame(height: 26)

            Text("총 \(viewModel.data?.applications.count ?? 0)명")
                .font(.appFont(.pretendardRegular, size: 12))
                .foregroundStyle(Color.appColor(.neutral500))
                .frame(height: 19)
        }
    }
}
