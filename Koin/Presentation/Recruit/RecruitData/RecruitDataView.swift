//
//  RecruitDataView.swift
//  koin
//
//  Created by 홍기정 on 9/12/26.
//

import SwiftUI

struct RecruitDataView: ActionBindableView {
    enum Action {
        case showApply
        case showApplicant
        case didDelete
        case showLoginToast
        case showProfileRequiredToast
        case showToast(message: String)
        case isAuthor(Bool)
    }
    
    // MARK: - Properties
    var sendAction: ((Action) -> Void) = { _ in }
    @State private var viewModel: RecruitDataViewModel
    
    var id: Int? {
        viewModel.data?.id
    }
    var data: RecruitData? {
        viewModel.data
    }
    
    // MARK: - Initializer
    init(
        viewModel: RecruitDataViewModel
    ) {
        self.viewModel = viewModel
    }
    
    // MARK: - Body
    var body: some View {
        RecruitDataContentView(
            data: viewModel.data,
            onButtonTapped: {
                didTapButton()
            }
        )
        .loadingOverlay(viewModel.isLoading)
        .background(Color.appColor(.newBackground).ignoresSafeArea())
        .onAppear {
            viewModel.execute(.load)
        }
        .onChange(of: viewModel.didDelete) {
            handleDelete()
        }
        .onChange(of: viewModel.data?.isAuthor) {
            sendAction(.isAuthor(viewModel.data?.isAuthor == true))
        }
        .onChange(of: viewModel.errorMessage) {
            if let message = viewModel.errorMessage {
                sendAction(.showToast(message: message))
                viewModel.execute(.didShowToast)
            }
        }
    }
    
    // MARK: - Public
    func didTapDelete() {
        viewModel.execute(.delete)
    }

    func reload() {
        viewModel.execute(.load)
    }

    func didSubmitApplication() {
        viewModel.execute(.applicationSubmitted)
    }
}

extension RecruitDataView {
    private func didTapButton() {
        guard let data = viewModel.data else {
            return
        }
        
        if data.isAuthor {
            viewModel.execute(.logEvent(EventParameter.EventLabel.Campus.teamRecruitmentPostApplicantCheck, .click, data.title))
            sendAction(.showApplicant)
            return
        }
        if data.canApply {
            viewModel.execute(.logEvent(EventParameter.EventLabel.Campus.teamRecruitmentPostApply, .click, data.title))
            sendAction(.showApply)
            return
        }
        
        guard let applyBlockReason = data.applyBlockReason else {
            return
        }
        switch applyBlockReason {
        case .loginRequired:
            sendAction(.showLoginToast)
        case .profileRequired:
            sendAction(.showProfileRequiredToast)
        default:
            sendAction(.showToast(message: applyBlockReason.toastMessage))
        }
    }
}

extension RecruitDataView {
    private func handleDelete() {
        guard viewModel.didDelete else {
            return
        }
        sendAction(.showToast(message: "삭제되었습니다"))
        sendAction(.didDelete)
    }
}
