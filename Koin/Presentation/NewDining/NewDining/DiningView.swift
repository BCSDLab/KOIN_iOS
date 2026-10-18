//
//  DiningView.swift
//  koin
//
//  Created by 홍기정 on 10/5/26.
//

import SwiftUI
import SwiftUIIntrospect
import UIKit

struct DiningView: ActionBindableView {
    enum Action {
        case showToastMessage(String)
        case showZoomedImage(imageUrl: String)
    }
    var sendAction: ((Action) -> Void) = { _ in }
    
    // MARK: - Properties
    @State private var viewModel: NewDiningViewModel
    
    // MARK: - Initializer
    init(viewModel: NewDiningViewModel) {
        self.viewModel = viewModel
    }
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            dateListView
            
            typeView
            
            tabView
                .background(Color.appColor(.neutral200))
        }
        .ignoresSafeArea(edges: .bottom)
        .onFirstAppear {
            viewModel.execute(.onFirstAppear)
        }
        .refreshable {
            viewModel.execute(.refresh)
        }
        .onChange(of: viewModel.toastMessage) {
            if let toastMessage = viewModel.toastMessage {
                sendAction(.showToastMessage(toastMessage))
                viewModel.execute(.didShowToast)
            }
        }
    }
}

extension DiningView {
    @ViewBuilder
    private var dateListView: some View {
        DiningDateListView(
            dates: viewModel.dates,
            selectedDate: viewModel.selectedDate,
            action: { date in
                viewModel.execute(.changeSelectedDate(date))
            }
        )
    }
}

extension DiningView {
    @ViewBuilder
    private var typeView: some View {
        DiningTypeView(
            types: DiningType.allCases,
            selectedType: viewModel.selectedDiningType
        ) { type in
            viewModel.execute(.changeSelectedDiningType(type))
        }
        .applySketchShadow(
            color: .appColor(.neutral800),
            alpha: 0.02,
            x: 0,
            y: 1,
            blur: 1
        )
        .applySketchShadow(
            color: .appColor(.neutral800),
            alpha: 0.04,
            x: 0,
            y: 2,
            blur: 4
        )
    }
}

extension DiningView {
    private var selectedDiningType: Binding<DiningType?> {
        Binding {
            viewModel.selectedDiningType
        } set: { type in
            if let type {
                viewModel.execute(.changeSelectedDiningType(type))
            }
        }
    }
    
    @ViewBuilder
    private var tabView: some View {
        TabView(selection: selectedDiningType) {
            ForEach(viewModel.diningLists, id: \.diningType) { list in
                listView(list: list)
                    .tag(list.diningType)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .introspect(
            .scrollView,
            on: .iOS(.v17, .v18, .v26, .v27)
        ) { scrollView in
            scrollView.contentInsetAdjustmentBehavior = .never
        }
    }
    
    @ViewBuilder
    private func listView(list: DiningList) -> some View {
        DiningMenuListView(
            list: list,
            onImageTapped: { imageUrl in
                sendAction(.showZoomedImage(imageUrl: imageUrl))
            },
            onShareTapped: { item in
                viewModel.execute(.didTapShare(item))
            }
        )
    }
}

