//
//  ProfileView.swift
//  koin
//
//  Created by 홍기정 on 7/11/26.
//

import SwiftUI

struct ProfileView: ActionBindableView {
    enum Action {
        case showLogin
        case showLogout
        case showSetting
        case showTimeTable(MainTimetableFrame?)
    }
    
    // MARK: - Properties
    var sendAction: (Action) -> Void = { _ in }
    @State private var viewModel: ProfileViewModel
    
    // MARK: - Initializer
    init(viewModel: ProfileViewModel) {
        self.viewModel = viewModel
    }
    
    // MARK: - Public
    func logout() {
        viewModel.execute(.logout)
    }
    func makeLogAnalyticsEvent(
        label: EventLabelType,
        value: Any
    ) {
        viewModel.execute(.logEvent(label, value))
    }
    
    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Spacer(minLength: 20)
                
                ProfileUserInfoView(
                    loginButtonTapped: {
                        sendAction(.showLogin)
                        viewModel.execute(.logEvent(EventParameter.EventLabel.Home.DA2.accountMainProfileLoginEntryClick, "로그인"))
                    },
                    logoutButtonTapped: {
                        sendAction(.showLogout)
                        viewModel.execute(.logEvent(EventParameter.EventLabel.Home.DA2.accountMainProfileLogoutClick, "로그아웃"))
                    },
                    settingButtonTapped: {
                        sendAction(.showSetting)
                        viewModel.execute(.logEvent(EventParameter.EventLabel.Home.DA2.accountMainProfileAccountConfigEntryClick, "설정"))
                    },
                    userInfo: viewModel.userInfo
                )
                
                Spacer(minLength: 30)
                
                TimeTableView(
                    lectures: viewModel.lectures,
                    timeTableTapped: {
                        sendAction(.showTimeTable(viewModel.mainFrame))
                        viewModel.execute(.logEvent(EventParameter.EventLabel.Home.DA1.timetableMainProfileTimetableEntryEntryClick, "내 시간표"))
                    }
                )
                
                Spacer()
            }
            .animation(.easeInOut(duration: 0.1), value: viewModel.lectures)
            .animation(.easeInOut(duration: 0.1), value: viewModel.userInfo)
            .padding(EdgeInsets(top: 0, leading: 30, bottom: 0, trailing: 30))
        }
        .background(Color.appColor(.newBackground))
        .onAppear {
            viewModel.execute(.viewDidAppear)
        }
    }
}
