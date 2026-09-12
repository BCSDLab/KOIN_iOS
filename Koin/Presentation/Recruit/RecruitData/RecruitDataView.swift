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
}

extension RecruitDataView {
    private func didTapButton() {
        guard let data = viewModel.data else {
            return
        }
        guard UserDataManager.shared.isLoggedIn else {
            sendAction(.showLoginToast)
            return
        }
        let id = data.id
        
        if data.isAuthor {
            sendAction(.showApplicant)
        } else if data.canApply {
            sendAction(.showApply)
        }
    }
    
    private func handleDelete() {
        guard let data = viewModel.data,
              viewModel.didDelete else {
            return
        }
        let id = data.id
        sendAction(.showToast(message: "삭제되었습니다"))
        sendAction(.didDelete)
    }
}
