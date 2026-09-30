//
//  RecruitMyPostListView.swift
//  koin
//
//  Created by 홍기정 on 9/24/26.
//

import SwiftUI

struct RecruitMyPostListView: ActionBindableView {

    enum Action {
        case showFilterBottomSheet(
            filterState: RecruitMyPostFilter,
            onApplyTapped: ([FilterGroupModel]) -> Void
        )
        case showToast(message: String)
        case showRecruitData(id: Int)
        case showChat(chatRoomId: Int)
        case showApplicants(recruitId: Int)
        case showCloseModal(recruitId: Int)
    }

    // MARK: - Properties
    var sendAction: (Action) -> Void = { _ in }
    @State private var viewModel: RecruitMyPostListViewModel

    // MARK: - Initializer
    init(viewModel: RecruitMyPostListViewModel) {
        self.viewModel = viewModel
    }

    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            RecruitMyPostListHeaderView(
                totalCount: viewModel.recruitList?.totalCount ?? 0,
                onFilterButtonTapped: {
                    sendAction(.showFilterBottomSheet(
                        filterState: viewModel.filterState,
                        onApplyTapped: { groupModels in
                            guard let filter = RecruitMyPostFilter(from: groupModels) else {
                                return
                            }
                            viewModel.execute(.updateFilter(filter))
                        }
                    ))
                }
            )
            .padding(.top, 20)
            .padding(.bottom, 12)

            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(viewModel.recruits) { recruit in
                        RecruitMyPostListRowView(
                            model: recruit,
                            onShowDetail: {
                                sendAction(.showRecruitData(id: recruit.id))
                            },
                            onShowChat: { chatRoomId in
                                sendAction(.showChat(chatRoomId: chatRoomId))
                            },
                            onShowApplicants: {
                                sendAction(.showApplicants(recruitId: recruit.id))
                            },
                            onCloseRecruit: {
                                sendAction(.showCloseModal(recruitId: recruit.id))
                            }
                        )
                        .frame(maxWidth: .infinity)
                        .onAppear {
                            loadNextPageIfNeeded(recruitId: recruit.id)
                        }
                    }
                }
                .animation(
                    .spring(duration: 0.3),
                    value: viewModel.recruits.map(\.id)
                )
                .frame(maxWidth: .infinity)
                
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .frame(height: 24)
                    .padding(.top, 12)
                    .isHidden(!(viewModel.recruitList?.hasNextPage ?? false && viewModel.isLoading))
                
                Spacer(minLength: 24)
            }
            .padding(.horizontal, 22)
            .background {
                RecruitMyPostListEmptyView()
                    .isHidden(!(viewModel.recruitList?.isEmpty ?? true))
            }
            .refreshable {
                viewModel.execute(.refresh)
            }
            .scrollIndicators(.hidden)
        }
        .background(Color.appColor(.newBackground))
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
        .onChange(of: viewModel.successMessage) {
            guard let message = viewModel.successMessage else {
                return
            }
            sendAction(.showToast(message: message))
            viewModel.execute(.didShowToast)
        }
    }
}

extension RecruitMyPostListView {
    private func loadNextPageIfNeeded(recruitId: Int) {
        guard viewModel.recruits.last?.id == recruitId,
              viewModel.recruitList?.hasNextPage ?? false,
              !viewModel.isLoading else {
            return
        }
        viewModel.execute(.loadNextPage)
    }

    func delete(id: Int) {
        viewModel.execute(.delete(id: id))
    }

    func close(id: Int) {
        viewModel.execute(.close(id: id))
    }
}
