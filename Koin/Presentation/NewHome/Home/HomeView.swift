//
//  HomeView.swift
//  koin
//
//  Created by 홍기정 on 6/1/26.
//

import SwiftUI

@MainActor
struct HomeView: View, ActionBindableView {
    enum Action {
        case showDining
        case showBusTimetable
        case showCallVan
        case showBusSearch
        case showQRCode
        case showShop
        case showForceUpdate(String)
        case showForceModifyUser
        case showToast(String)
    }

    @State private var viewModel: NewHomeViewModel
    var sendAction: (Action) -> Void = { _ in }

    init(viewModel: NewHomeViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ScrollView(.vertical) {
            VStack(spacing: 0) {
                HomeHeaderView(header: viewModel.header)

                DiningView(
                    diningItems: viewModel.diningItems,
                    onTapAll: {
                        sendAction(.showDining)
                    },
                    onTapMenu: { _ in
                        sendAction(.showDining)
                    }
                )

                MobilityView(
                    callVanRecruitingCount: viewModel.callVanRecruitingCount,
                    onTapShuttleTicket: {
                        sendAction(.showQRCode)
                    },
                    onTapCallVan: {
                        sendAction(.showCallVan)
                    },
                    onTapBusTimetable: {
                        sendAction(.showBusTimetable)
                    },
                    onTapBusRoute: {
                        sendAction(.showBusSearch)
                    }
                )

                ShopView(
                    eventCount: viewModel.eventCount,
                    openShopCount: viewModel.openShopCount,
                    totalShopCount: viewModel.totalShopCount,
                    onTapAll: {
                        sendAction(.showShop)
                    },
                    onTapShopCard: {
                        sendAction(.showShop)
                    }
                )
            }
            .frame(maxWidth: .infinity, alignment: .top)
            .padding(.bottom, 40)
        }
        .scrollIndicators(.hidden)
        .background(Color.appColor(.newBackground))
        .onFirstAppear {
            viewModel.execute(.viewDidLoad)
        }
        .onChange(of: viewModel.forceUpdateVersion) { _, version in
            guard let version else { return }
            sendAction(.showForceUpdate(version))
        }
        .onChange(of: viewModel.forceModifyUserRequired) { _, isRequired in
            guard isRequired else { return }
            sendAction(.showForceModifyUser)
        }
        .onChange(of: viewModel.toastMessage) { _, message in
            guard let message else { return }
            sendAction(.showToast(message))
            viewModel.execute(.markToastPresented)
        }
        .refreshable {

            viewModel.execute(.refresh)
            try? await Task.sleep(nanoseconds: 200_000_000)
        }
        .loadingOverlay(viewModel.isLoading)
    }
}
