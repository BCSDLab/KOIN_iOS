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
        case .showMyPosts:
            navigateToMyPosts()
        case .showMyApplications:
            navigateToMyApplications()
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
    
    private func navigateToMyPosts() {
        // TODO: navigate
    }
    
    private func navigateToMyApplications() {
        // TODO: navigate
    }

    private func makeProfilePostViewController(
        mode: RecruitProfilePostViewModel.Mode
    ) -> RecruitProfilePostViewController {
        let userRepository = DefaultUserRepository(service: DefaultUserService())
        let recruitRepository = MockRecruitRepository()
        let fetchDeptListUseCase = MockFetchDeptListUseCase()
        let fetchUserDataUseCase = DefaultFetchUserDataUseCase(userRepository: userRepository)
        let postBasicInfoUseCase = DefaultPostBasicInfoUseCase(repository: recruitRepository)
        let postRecruitProfileUseCase = DefaultPostRecruitProfileUseCase(repository: recruitRepository)
        let viewModel = RecruitProfilePostViewModel(
            fetchDeptListUseCase: fetchDeptListUseCase,
            fetchUserDataUseCase: fetchUserDataUseCase,
            postBasicInfoUseCase: postBasicInfoUseCase,
            postRecruitProfileUseCase: postRecruitProfileUseCase,
            mode: mode
        )
        return RecruitProfilePostViewController(viewModel: viewModel) { [weak self] profile in
            self?.rootView.updateProfile(profile)
        }
    }
}
