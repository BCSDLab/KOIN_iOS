//
//  RecruitProfileHostingController.swift
//  koin
//
//  Created by 홍기정 on 9/13/26.
//

import SwiftUI

final class RecruitProfileHostingController: UIHostingController<RecruitProfileView>, HostingControllerProtocol {
    
    // MARK: - Initializer
    override init(rootView: RecruitProfileView) {
        super.init(rootView: rootView)
        bindAction(to: rootView)
    }

    @MainActor @preconcurrency required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "팀원 모집 프로필"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar(style: .newBackground)
    }

    // MARK: - Execute
    func execute(action: RecruitProfileView.Action) {
        switch action {
        case .showProfilePost:
            navigateToProfilePost()
        case .showProfileModify(let profile):
            navigateToProfileModify(profile: profile)
        case .showMyPost:
            navigateToMyPost()
        case .showMyApplication:
            navigateToMyApplication()
        case let .showToast(message):
            showToastMessage(message: message)
        }
    }
}

extension RecruitProfileHostingController {
    private func navigateToProfilePost() {
        let controller = makeProfilePostViewController(mode: .post)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    private func navigateToProfileModify(profile: RecruitProfile) {
        let controller = makeProfilePostViewController(mode: .modify(profile))
        navigationController?.pushViewController(controller, animated: true)
    }
    
    private func navigateToMyPost() {
        let repository = DefaultRecruitRepository(service: DefaultRecruitService())
        let fetchUseCase = DefaultFetchRecruitMyPostListUseCase(repository: repository)
        let closeUseCase = DefaultCloseRecruitMyPostUseCase(repository: repository)
        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
        let viewModel = RecruitMyPostListViewModel(
            fetchRecruitMyPostListUseCase: fetchUseCase,
            closeRecruitMyPostUseCase: closeUseCase,
            logAnalyticsEventUseCase: logAnalyticsEventUseCase
        )
        let controller = RecruitMyPostListHostingController(
            rootView: RecruitMyPostListView(viewModel: viewModel)
        )
        navigationController?.pushViewController(controller, animated: true)
    }
    
    private func navigateToMyApplication() {
        let repository = DefaultRecruitRepository(service: DefaultRecruitService())
        let useCase = DefaultFetchRecruitMyApplicationListUseCase(repository: repository)
        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
        let viewModel = RecruitMyApplicationListViewModel(
            fetchRecruitMyApplicationListUseCase: useCase,
            logAnalyticsEventUseCase: logAnalyticsEventUseCase
        )
        let controller = RecruitMyApplicationListHostingController(
            rootView: RecruitMyApplicationListView(viewModel: viewModel)
        )
        navigationController?.pushViewController(controller, animated: true)
    }

    private func makeProfilePostViewController(
        mode: RecruitProfilePostViewModel.Mode
    ) -> RecruitProfilePostViewController {
        let userRepository = DefaultUserRepository(service: DefaultUserService())
        let recruitRepository = DefaultRecruitRepository(service: DefaultRecruitService())
        let fetchDeptListUseCase = DefaultFetchDeptListUseCase(timetableRepository: DefaultTimetableRepository(service: DefaultTimetableService()))
        let fetchBasicInfoUseCase = DefaultFetchBasicInfoUseCase(repository: userRepository)
        let modifyBasicInfoUseCase = DefaultModifyBasicInfoUseCase(repository: userRepository)
        let upsertMyRecruitProfileUseCase = DefaultUpsertMyRecruitProfileUseCase(repository: recruitRepository)
        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
        let viewModel = RecruitProfilePostViewModel(
            fetchDeptListUseCase: fetchDeptListUseCase,
            fetchBasicInfoUseCase: fetchBasicInfoUseCase,
            modifyBasicInfoUseCase: modifyBasicInfoUseCase,
            upsertMyRecruitProfileUseCase: upsertMyRecruitProfileUseCase,
            logAnalyticsEventUseCase: logAnalyticsEventUseCase,
            mode: mode
        )
        return RecruitProfilePostViewController(viewModel: viewModel) { [weak self] profile in
            self?.rootView.updateProfile(profile)
        }
    }
}
