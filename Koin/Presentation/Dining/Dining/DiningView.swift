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
        case showReportBarButton
        case showReportBarButtonTooltip
        case showReportModal
        case didFinishReporting
        case showZoomedImage(imageUrl: String)
        case presentNotiBottomSheet(initialValue: DiningNoti)
    }
    var sendAction: ((Action) -> Void) = { _ in }
    
    // MARK: - Properties
    @State private var viewModel: DiningViewModel
    var currentDiningItems: [DiningItem] {
        viewModel.currentDiningItems
    }
    
    // MARK: - Initializer
    init(viewModel: DiningViewModel) {
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
            viewModel.execute(.logEvent(EventParameter.EventLabel.Campus.Dining.menuTime, .click, viewModel.selectedDiningType.name))
        }
        .onChange(of: viewModel.toastMessage) {
            if let toastMessage = viewModel.toastMessage {
                sendAction(.showToastMessage(toastMessage))
                viewModel.execute(.didShowToast)
            }
        }
        .onChange(of: viewModel.reportAbTest) {
            if viewModel.reportAbTest == .nav {
                sendAction(.showReportBarButton)
            }
            if viewModel.reportAbTest == .nav && viewModel.shouldShowReportTooltip {
                sendAction(.showReportBarButtonTooltip)
            }
        }
        .onChange(of: viewModel.didFinishReporting) {
            sendAction(.didFinishReporting)
        }
        .onChange(of: viewModel.diningNoti) {
            if let diningNoti = viewModel.diningNoti,
               viewModel.shouldPresentNotiBottomSheet {
                sendAction(.presentNotiBottomSheet(initialValue: diningNoti))
            }
        }
    }
    
    // MARK: - Public
    func makeLogAnalyticsEvent(
        label: EventLabelType,
        category: EventParameter.EventCategory,
        value: Any
    ) {
        viewModel.execute(.logEvent(label, category, value))
    }
    
    func didTapCloseReportTooltip() {
        viewModel.execute(.didTapCloseReportTooltip)
    }
    
    func didTapReport(
        selectedItem: DiningItem,
        evidenceImage imageData: Data
    ) {
        IndicatorView.show()
        viewModel.execute(.didTapReport(selectedItem: selectedItem, imageData: imageData))
    }
    
    func didTapSoldOutSwitch(isOn: Bool) {
        viewModel.execute(.didTapSoldOutSwitch(isOn))
    }
    
    func didTapImageUploadSwitch(isOn: Bool) {
        viewModel.execute(.didTapImageUploadSwitch(isOn))
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
            on: .iOS(.v18, .v26, .v27)
        ) { scrollView in
            scrollView.contentInsetAdjustmentBehavior = .never
        }
    }
    
    @ViewBuilder
    private func listView(list: DiningList) -> some View {
        DiningMenuListView(
            list: list,
            onImageTapped: { item in
                if let imageUrl = item.image.imageUrl {
                    sendAction(.showZoomedImage(imageUrl: imageUrl))
                }
                viewModel.execute(.logEvent(EventParameter.EventLabel.Campus.Dining.menuImage, .click, "\(viewModel.selectedDiningType.name)_\(item.place.name)"))
            },
            onScrolledDown: {
                viewModel.execute(.logEvent(EventParameter.EventLabel.Campus.Dining.menuTime, .scroll, list.diningType.name))
            },
            shouldShowShareTooltip: viewModel.shouldShowShareTooltip,
            onShareTapped: { item in
                viewModel.execute(.didTapShare(item))
                viewModel.execute(.logEvent(EventParameter.EventLabel.Campus.Dining.menuShare, .click, "공유하기"))
            },
            onCloseShareTooltipTapped: {
                viewModel.execute(.didTapCloseShareTooltip)
            },
            shouldShowReportButton: viewModel.reportAbTest == .card,
            shouldShowReportTooltip: viewModel.reportAbTest == .card && viewModel.shouldShowReportTooltip,
            onReportTapped: { 
                sendAction(.showReportModal)
            },
            onCloseReportTooltipTapped: {
                viewModel.execute(.didTapCloseReportTooltip)
            }
        )
    }
}

